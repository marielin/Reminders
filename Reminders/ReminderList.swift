//
//  ReminderList.swift
//  Reminders
//
//  Created by Marie Lin on 2015-2-28.
//  Copyright (c) 2015 Sapphirine. All rights reserved.
//

import UIKit
import EventKit

class ReminderList : Comparable {
	
	/// The calendar represented by this ReminderList.
	var calendar: EKCalendar!
    
    /// The array of reminders in the list.
    var reminders = [EKReminder]()
    
    /// The name of the reminder list.
    var name = String()
    
    /// The color of the reminder list.
    var color = UIColor()
    
    // who the reminder is shared with
    // var sharedWith =
    
    /// Initialize the list with a title and a color.
    init(name: String, color: UIColor) {
        self.name = name
        self.color = color
    }
	
	/// Initialize the list from an existing calendar.
	init(calendar: EKCalendar) {
		self.calendar = calendar
		self.name = calendar.title
		self.color = UIColor(CGColor: calendar.CGColor)!
	}
	
}

/// Check whether two ReminderLists are equatable based on their names.
func ==(lhs: ReminderList, rhs: ReminderList) -> Bool {
	return lhs.name == rhs.name
}

/// Compare two ReminderLists based on their names.
func <(lhs: ReminderList, rhs: ReminderList) -> Bool {
	return lhs.name < rhs.name
}
