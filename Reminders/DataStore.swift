//
//  DataStore.swift
//  Reminders
//
//  Created by Justin Loew on 3/1/15.
//  Copyright (c) 2015 Sapphirine. All rights reserved.
//

import Foundation
import EventKit

private let _dataStoreSharedInstance = DataStore()

class DataStore {
	
	class var sharedInstance: DataStore {
		return _dataStoreSharedInstance
	}
	
	let eventStore: EKEventStore
	
	var source: EKSource!
	
	/// A list of all the calendars in the current source.
	var calendars: [EKCalendar] {
		let calendarSet = source.calendarsForEntityType(EKEntityTypeReminder) as! Set<EKCalendar>
		// turn the set into an array
		var calendarArray = [EKCalendar]()
		for var src = calendarSet.startIndex; src != calendarSet.endIndex; src++ {
			calendarArray.append(calendarSet[src])
		}
		// sort the array
		calendarArray.sort({ $0.title > $1.title})
		return calendarArray
	}
	
	private init() {
		eventStore = EKEventStore()
		if hasPermission() {
			setUpSource()
		}
	}
	
	/// Choose the best source available to us.
	private func setUpSource() {
		let sources = eventStore.sources() as! [EKSource]
		for src in sources {
			if src.sourceType.value == EKSourceTypeCalDAV.value {
				// iCloud
				self.source = src
			} else if src.sourceType.value == EKSourceTypeLocal.value {
				// fallback
				if self.source == nil {
					self.source = src
				}
			}
		}
	}
	
	/// Return `true` if we have authorization to access user calendars.
	func hasPermission() -> Bool {
		let permissionStatus = EKEventStore.authorizationStatusForEntityType(EKEntityTypeReminder)
		switch permissionStatus {
		case .Authorized:
			return true
		case .Denied, .Restricted, .NotDetermined:
			return false
		}
	}
	
	/// If we do not yet have authorization to access user calendars, ask for permission.
	func requestPermissionIfNecessary(onSuccess: (() -> Void)?) {
		if !hasPermission() {
			self.eventStore.requestAccessToEntityType(EKEntityTypeReminder) { (accessGranted, error) -> Void in
				if error != nil {
					println("Error while requesting calendar access: \(error)")
				} else {
					if accessGranted {
						println("Access to calendars granted.")
						self.setUpSource()
						if let completionHandler = onSuccess {
							completionHandler()
						}
					} else {
						println("Access to calendars denied.")
					}
				}
			}
		}
	}
	
	/// Return `true` if the user has marked any reminders as completed.
	/// TODO: - optimize this, or cache the return value, or something.
	func hasCompletedReminders() -> Bool {
		return completedReminders().count > 0
	}
	
	private var _completedReminders: [EKReminder]!
	/// Get a sorted array of all the reminders that the user has marked as completed.
	func completedReminders() -> [EKReminder] {
		let predicate = eventStore.predicateForCompletedRemindersWithCompletionDateStarting(nil, ending: nil, calendars: eventStore.calendarsForEntityType(EKEntityTypeReminder))
		eventStore.fetchRemindersMatchingPredicate(predicate, completion: { (objects) -> Void in
			var reminders = objects as! [EKReminder]
			reminders.sort({ $0.title > $1.title })
			self._completedReminders = reminders
		})
		
		// fuck it ship it
		while self._completedReminders == nil {
			// delay
		}
		return self._completedReminders
	}
	
}
