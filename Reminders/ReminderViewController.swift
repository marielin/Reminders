//
//  ReminderViewController.swift
//  Reminders
//
//  Created by Marie Lin on 2015-2-28.
//  Copyright (c) 2015 Sapphirine. All rights reserved.
//

import UIKit
import EventKit

class ReminderViewController: UITableViewController {

    var reminder = EKReminder()
    var isEditingAlarm: Bool = false

    let dateFormatter = NSDateFormatter()

    let noAlarmCellStructure = [["ReminderNameCell"], ["ReminderRemindCell", "ReminderAlarmCell", "ReminderRepeatCell"], ["ReminderNotesCell"]]
    let isAlarmCellStructure = [["ReminderNameCell"], ["ReminderRemindCell"], ["ReminderNotesCell"]]
    let editingAlarmCellStructure = [["ReminderNameCell"], ["ReminderRemindCell", "ReminderAlarmCell", "ReminderAlarmPickerCell", "ReminderRepeatCell"], ["ReminderNotesCell"]]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            if reminder.hasAlarms == true {
                return 3
            } else {
                return 1
            }
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let object: EKReminder = reminder

        var identifier = String()

        if isEditingAlarm == true { // if the user is editing alarms
            identifier = editingAlarmCellStructure[indexPath.section][indexPath.row]
        } else if reminder.alarms != nil {
            identifier = isAlarmCellStructure[indexPath.section][indexPath.row]
        } else {
            identifier = noAlarmCellStructure[indexPath.section][indexPath.row]
        }

        var cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UITableViewCell

        if indexPath.section == 0 {
            var cell = cell as! ReminderNameCell
            cell.reminderName.text == reminder.title
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                var cell = cell as! ReminderRemindCell
                cell.isReminder.enabled == reminder.hasAlarms
            } else if indexPath.row == 1 {
                var cell = cell // as ReminderAlarmCell
                cell.detailTextLabel!.text = dateFormatter.stringFromDate(reminder.alarms[0].absoluteDate)
            } else if (isEditingAlarm == true && indexPath.row == 3) || (isEditingAlarm == false && indexPath.row == 2) {
                var cell = cell // as ReminderRepeatCell
                // cell.detailTextLabel?.text = reminder.recurrenceRules
                cell.detailTextLabel?.text = "To-do"
            }
        } else { // indexPath.section == 2
//            var cell = cell as! ReminderNotesCell
            // cell.notes.text = reminder.notes
        }


        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            reminders.removeAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        } else if editingStyle == .Insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//        }
    }


}
