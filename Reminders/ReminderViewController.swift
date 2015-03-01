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

    let noAlarmCellStructure = [["ReminderNameCell"], ["ReminderRemindCell", "ReminderNotesCell"]]
    let isAlarmCellStructure = [["ReminderNameCell"], ["ReminderRemindCell", "ReminderAlarmCell", "ReminderRepeatCell", "ReminderNotesCell"]]
    let editingAlarmCellStructure = [["ReminderNameCell"], ["ReminderRemindCell", "ReminderAlarmCell", "ReminderAlarmPickerCell", "ReminderRepeatCell", "ReminderNotesCell"]]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.doesRelativeDateFormatting = true;
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
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if isEditingAlarm == true {
                return 5
            } else if reminder.hasAlarms == true {
                return 4
            } else {
                return 2
            }
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
            println(cell.reminderName.text)
            cell.reminderName.text = reminder.title
        } else {
            if indexPath.row == 0 {
                var cell = cell as! ReminderRemindCell
                cell.isReminder.enabled == reminder.hasAlarms
            }
            
            else if reminder.hasAlarms == true {
                if indexPath.row == 1 { // ReminderAlarmCell
                    cell.detailTextLabel!.text = dateFormatter.stringFromDate(reminder.alarms[0].absoluteDate)
//                    cell.detailTextLabel!.text = dateFormatter.string
                } else if isEditingAlarm == true {
                    if indexPath.row == 2 { // ReminderNotesCell
                        
                    } else if indexPath.row == 3 { // as ReminderRepeatCell
//                        cell.detailTextLabel?.text = reminder.recurrenceRules
                        cell.detailTextLabel?.text = "To-do"
                    } else {
//                        var cell = cell as! ReminderNotesCell
//                        cell.notes.text = reminder.notes
                    }
                } else if isEditingAlarm == false {
//                    var cell = cell as! ReminderNotesCell
//                    cell.notes.text = reminder.notes
                }
            } else {
//              var cell = cell as! ReminderNotesCell
//              cell.notes.text = reminder.notes
            }
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
