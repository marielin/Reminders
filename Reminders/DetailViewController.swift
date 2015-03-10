//
//  DetailViewController.swift
//  Reminders
//
//  Created by Marie Lin on 2015-2-28.
//  Copyright (c) 2015 Sapphirine. All rights reserved.
//

import UIKit
import EventKit

class DetailViewController: UITableViewController {
	
	var calendar: EKCalendar!
    var reminders = [EKReminder]()
    var listTitle = String()
	
	let dataStore = DataStore.sharedInstance
    
    var eventStore: EKEventStore! {
        get {
            return self.dataStore.eventStore
        }
        set {
            self.dataStore.eventStore = newValue
        }
    }
	
	var masterVC: MasterViewController! {
		if let parent = self.presentingViewController {
			if let master = parent as? MasterViewController {
				return master
			}
		}
		return nil
	}
    
    let dateFormatter = NSDateFormatter()
    let timeFormatter = NSDateFormatter()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = listTitle
        
        let eventStore = EKEventStore()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "createNewReminderPressed:")
        self.navigationItem.rightBarButtonItem = addButton

        timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.doesRelativeDateFormatting = true;
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func createReminder(#name: String) {
        let reminder = EKReminder(eventStore: self.eventStore)
		reminder.calendar = self.calendar
        reminder.title = name
        
        // save changes
        var error = NSErrorPointer()
        eventStore.saveReminder(reminder, commit: true, error: error)
        if error != nil {
            println("Error creating new reminder: \(error)")
        } else {
            println("Successfully saved new reminder.")
        }
    }
    
    func insertNewObject(reminder: EKReminder) {
		// save the new reminder
		var error = NSErrorPointer()
		dataStore.eventStore.saveReminder(reminder, commit: true, error: error)
		if error != nil {
			println("Error saving reminder: \(error)")
		} else {
			println("Successfully saved reminder.")
		}
		
        reminders.insert(reminder, atIndex: reminders.count)
        let indexPath = NSIndexPath(forRow: reminders.count - 1, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func createNewReminderPressed(sender: AnyObject!) {
		let newReminder = EKReminder(eventStore: eventStore)
		newReminder.calendar = self.calendar
        insertNewObject(newReminder)
        let newIndexPath = NSIndexPath(forRow: reminders.count - 1, inSection: 0)
        let newCell = self.tableView.cellForRowAtIndexPath(newIndexPath) as! ReminderCell
        newCell.setEditing(true, animated: true)
        newCell.reminderName.becomeFirstResponder()
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showReminderDetails" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = reminders[indexPath.row] as EKReminder
                let destination = (segue.destinationViewController as! ReminderViewController)
                destination.reminder = object
//                destination.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {        
        let cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell", forIndexPath: indexPath) as! ReminderCell
        
        let object = reminders[indexPath.row] as EKReminder
        cell.reminderName!.text = object.title
        if object.hasAlarms == true {
            let alarmDate: NSDate = object.alarms[0].absoluteDate
            if alarmDate.timeIntervalSinceNow < 60.0 * 60.0 * 24.0 {
                cell.alarmDate!.text = timeFormatter.stringFromDate(alarmDate)
            } else {
                cell.alarmDate!.text = dateFormatter.stringFromDate(alarmDate)
            }
        } else {
            cell.alarmDate!.text = ""
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        
        var markCompletedAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Complete" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
//            self.reminders.removeAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.markCompletedReminderForCellAtIndexPath(indexPath)
        })
//        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
//            self.deleteReminderForCellAtIndexPath(indexPath)
//        })
        
        markCompletedAction.backgroundColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0)
        // deleteAction.backgroundColor = UIColor.redColor() // is default
        
//        return [markCompletedAction, deleteAction]
        return [markCompletedAction] // disables delete action, which may not be a necessary inclusion
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
//			self.deleteReminderForCellAtIndexPath(indexPath)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    override func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as! ReminderCell? {
            cell.reminderName.userInteractionEnabled = true
        }
    }
    
    func markCompletedReminderForCellAtIndexPath(indexPath: NSIndexPath) {
        // delete the reminder
        let cell = tableView.cellForRowAtIndexPath(indexPath)! as! ReminderCell
        var reminder = getReminderForName(cell.reminderName!.text!)
        var error = NSErrorPointer()
        reminder.completed = true
        eventStore.saveReminder(reminder, commit: true, error: error)
        if error != nil {
            println("Error marking reminder as completed: \(error)")
        } else {
            println("Successfully completed reminder.")
        }
		
		// update state and UI
        reminders.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
	
//	func deleteReminderForCellAtIndexPath(indexPath: NSIndexPath) {
//		// delete the reminder
//            let cell = tableView.cellForRowAtIndexPath(indexPath)!
//            var reminder = getReminderForName(cell.textLabel!.text!)
//            var error = NSErrorPointer()
//            dataStore.eventStore.removeReminder(reminder, commit: true, error: error)
//            if error != nil {
//                println("Error deleting reminder: \(error)")
//            } else {
//                println("Successfully deleted reminder.")
//            }
//            
//            reminders.removeAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//	}
	
	func getReminderForName(name: String) -> EKReminder! {
		for reminder in self.reminders {
			if reminder.title == name {
				return reminder
			}
		}
		return nil
	}
    
    func cellForTextField(textField: UITextField) -> ReminderCell? {
        for i in 0 ..< self.reminders.count {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! ReminderCell
            if textField == cell.reminderName {
                return cell
            }
        }
        return nil
    }

    // MARK: - UITextFieldDelegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        let cell = self.cellForTextField(textField)
        return cell != nil ? cell!.editing : false
    }
    
    /// Save the new Reminder List
    func textFieldDidEndEditing(textField: UITextField) {
        if let cell = self.cellForTextField(textField) {
			let indexPath = tableView.indexPathForCell(cell)!
			let rem = self.reminders[indexPath.row]
			rem.title = cell.reminderName.text
			
			// save the changes
			let error = NSErrorPointer()
			eventStore.saveReminder(rem, commit: true, error: error)
			if error != nil {
				println("Error saving changes to reminder: \(error)")
			} else {
				println("Successfully saved changes to reminder.")
			}
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let cell = self.cellForTextField(textField)
        cell?.setEditing(false, animated: true)
        return false
    }
    
}

