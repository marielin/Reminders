//
//  MasterViewController.swift
//  Reminders
//
//  Created by Marie Lin on 2015-2-28.
//  Copyright (c) 2015 Sapphirine. All rights reserved.
//

import UIKit
import EventKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    
    // the list of reminder lists
    var reminderLists = [ReminderList]()
    
    // placeholder variable
    var hasCompletedReminders = true
	
	var eventStore: EKEventStore!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

		//TODO: this
//        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
//        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
        
        // test code
        insertNewObject(ReminderList(name: "Test List", color: UIColor.redColor()))
        // end test code
		
		self.eventStore = EKEventStore()
		requestPermissionIfNecessary()
		if hasPermission() {
			reloadReminders()
		}
    }
	
	func reloadReminders() {
		// remove all existing reminder lists
		var indexPaths = [NSIndexPath]()
		for i in 0 ..< self.reminderLists.count {
			self.tableView.deleteRowsAtIndexPaths([NSIndexPath(index: i)], withRowAnimation: .Automatic)
		}
		self.reminderLists = [ReminderList]()
		
		// load all reminder lists from the database
		let sources = eventStore.sources() as! [EKSource]
		// get the reminder lists
		for source in sources {
			for calendar in source.calendarsForEntityType(EKEntityTypeReminder) as! Set<EKCalendar> {
				if (calendar.allowedEntityTypes & EKEntityMaskReminder) != 0 {
					let color = UIColor(CGColor: calendar.CGColor)!
					var reminderList = ReminderList(name: calendar.title, color: color)
					let predicate = eventStore.predicateForIncompleteRemindersWithDueDateStarting(nil, ending: nil, calendars: [calendar])
					self.fetchRemindersForPredicate(predicate, reminderList: reminderList)
				}
			}
		}
	}
	
	func fetchRemindersForPredicate(predicate: NSPredicate, reminderList: ReminderList) {
		eventStore.fetchRemindersMatchingPredicate(predicate) { (objects) -> Void in
			let reminders = objects as! [EKReminder]
			reminderList.reminders = reminders
			self.insertNewObject(reminderList)
		}
	}
	
	func hasPermission() -> Bool {
		let permissionStatus = EKEventStore.authorizationStatusForEntityType(EKEntityTypeReminder)
		switch permissionStatus {
		case .Authorized:
			return true
		case .Denied, .Restricted, .NotDetermined:
			return false
		}
	}
	
	func requestPermissionIfNecessary() {
		if !hasPermission() {
			self.eventStore.requestAccessToEntityType(EKEntityTypeReminder) { (accessGranted, error) -> Void in
				if error != nil {
					println("Error while requesting calendar access: \(error)")
				} else {
					if accessGranted {
						println("Access to calendars granted.")
						self.reloadReminders()
					} else {
						println("Access to calendars denied.")
					}
				}
			}
		}
	}

    func insertNewObject(sender: ReminderList) {
        reminderLists.append(sender)
        let indexPath = NSIndexPath(forRow: reminderLists.count - 1, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showReminderList" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = reminderLists[indexPath.row] as ReminderList
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.reminders = object.reminders
                controller.listTitle = object.name
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        if hasCompletedReminders == false {
//            return 1
//        } else {
//            return 2
//        }
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
			// user's reminder lists
            return reminderLists.count
        } else {
			// All Reminders and Completed
            return 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReminderListCell", forIndexPath: indexPath) as! ReminderListCell

        let object = reminderLists[indexPath.row]
        cell.reminderListName.text = object.name
        cell.reminderListColor.textColor = reminderLists[indexPath.row].color
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            reminderLists.removeAtIndex(indexPath.row)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
	
}

