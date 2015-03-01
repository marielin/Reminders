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
    
    var reminders = [EKReminder]()
    var listTitle = String()
	
	let dataStore = DataStore.sharedInstance
	
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
        
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.doesRelativeDateFormatting = true;
        
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
		
        reminders.insert(reminder, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell", forIndexPath: indexPath) as! UITableViewCell
        
        let object = reminders[indexPath.row] as EKReminder
        cell.textLabel!.text = object.title
        if object.hasAlarms == true {
            let alarmDate: NSDate = object.alarms[0].absoluteDate
            if alarmDate.timeIntervalSinceNow < 60*60*24 {
                cell.detailTextLabel!.text = timeFormatter.stringFromDate(alarmDate)
            } else {
                cell.detailTextLabel!.text = dateFormatter.stringFromDate(alarmDate)
            }
        } else {
            cell.detailTextLabel!.text = ""
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        
        var markCompletedAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Complete" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            self.reminders.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        })
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
        })
        
        markCompletedAction.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        // deleteAction.backgroundColor = UIColor.redColor() // is default
        
        return [deleteAction, markCompletedAction]
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // delete the reminder
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            var reminder = getReminderForName(cell.textLabel!.text!)
            var error = NSErrorPointer()
            dataStore.eventStore.removeReminder(reminder, commit: true, error: error)
            if error != nil {
                println("Error deleting reminder: \(error)")
            } else {
                println("Successfully deleted reminder.")
            }
            
            reminders.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
	
	func getReminderForName(name: String) -> EKReminder! {
		for reminder in self.reminders {
			if reminder.title == name {
				return reminder
			}
		}
		return nil
	}


}

