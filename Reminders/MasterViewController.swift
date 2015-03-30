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
    
    /// The list of reminder lists
    var reminderLists = [ReminderList]()
	
	/// The global data store used to load and save reminder data.
	let dataStore = DataStore.sharedInstance
	
	/// Convenience accessor for dataStore.eventStore.
	private var eventStore: EKEventStore! {
		return dataStore.eventStore
	}
	
	var source: EKSource! {
		return self.dataStore.source
	}
	
	// MARK: - View lifecycle
	
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
		
		
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "createNewReminderListPressed:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count - 1].topViewController as? DetailViewController
        }
		
		dataStore.requestPermissionIfNecessary() {
			self.reloadReminders()
		}
		if dataStore.hasPermission() {
			reloadReminders()
		}
    }
	
	private var keyboardDidShowNotification: AnyObject!
	private var keyboardWillHideNotification: AnyObject!
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		// resize the table view so it's above the keyboard
		let nc = NSNotificationCenter.defaultCenter()
		keyboardDidShowNotification = nc.addObserverForName(UIKeyboardDidShowNotification, object: nil, queue: nil) { (note) -> Void in
			let kbSize = (note.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue().size
			let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
			self.tableView.contentInset = contentInsets
			self.tableView.scrollIndicatorInsets = contentInsets
			if let textField = self.activeTextField, cell = self.cellForTextField(textField), indexPath = self.tableView.indexPathForCell(cell) {
				self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .None, animated: true)
			}
		}
		// reclaim the space that held the keyboard
		keyboardWillHideNotification = nc.addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: nil) { (note) -> Void in
			let contentInsets = UIEdgeInsetsZero
			self.tableView.contentInset = contentInsets
			self.tableView.scrollIndicatorInsets = contentInsets
		}
	}
	
	override func viewWillDisappear(animated: Bool) {
		let nc = NSNotificationCenter.defaultCenter()
		nc.removeObserver(keyboardDidShowNotification)
		keyboardDidShowNotification = nil
		nc.removeObserver(keyboardWillHideNotification)
		keyboardWillHideNotification = nil
		super.viewWillDisappear(animated)
	}
	
	// MARK: -
	
	func reloadReminders() {
		self.reminderLists = [ReminderList]()
		
		self.beginUpdatesCount++ // don't refresh until we're done with all sources
		// load all reminder lists from the database
		let sources = eventStore.sources() as! [EKSource]
		// get the reminder lists
		for source in sources {
			for calendar in source.calendarsForEntityType(EKEntityTypeReminder) as! Set<EKCalendar> {
				if (calendar.allowedEntityTypes & EKEntityMaskReminder) != 0 {
					self.beginUpdatesCount++
					var reminderList = ReminderList(calendar: calendar)
					let predicate = eventStore.predicateForIncompleteRemindersWithDueDateStarting(nil, ending: nil, calendars: [calendar])
					self.fetchRemindersForPredicate(predicate, reminderList: reminderList)
				}
			}
		}
		self.beginUpdatesCount--
	}
	private var beginUpdatesCount = 0
	
	private func fetchRemindersForPredicate(predicate: NSPredicate, reminderList: ReminderList) {
		eventStore.fetchRemindersMatchingPredicate(predicate) { (objects) -> Void in
			let reminders = objects as! [EKReminder]
			reminderList.reminders = reminders
			self.reminderLists.append(reminderList)
			
            self.beginUpdatesCount--
			if self.beginUpdatesCount == 0 {
				sort(&self.reminderLists)
				self.tableView.reloadData()
			}
		}
	}

    func insertNewObject(sender: ReminderList) {
        reminderLists.append(sender)
        let indexPath = NSIndexPath(forRow: reminderLists.count, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
	}
    
    func insertNewObjects(lists: [ReminderList]) {
        var indexPaths = [NSIndexPath]()
        for i in reminderLists.count ..< reminderLists.count + lists.count {
            indexPaths.append(NSIndexPath(forRow: i, inSection: 0))
        }
        reminderLists += lists
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }
	
	/// Given a text field, find the ReminderListCell that owns it.
	private func cellForTextField(textField: UITextField) -> ReminderListCell? {
		return textField.superview?.superview as? ReminderListCell
	}
	
	/// Find the calendar with a title matching a given name.
	private func calendarForName(name: String) -> EKCalendar! {
		let calendars = source.calendarsForEntityType(EKEntityTypeReminder) as! Set<EKCalendar>
		for cal in calendars {
			if cal.title == name {
				return cal
			}
		}
		return nil
	}
	
	/// Create a new calendar containing no reminders, insert it into the table view, and begin editing its title.
	func createNewReminderListPressed(sender: AnyObject!) {
		let newCalendar = EKCalendar(forEntityType: EKEntityTypeReminder, eventStore: eventStore)!
		newCalendar.title = ""
		newCalendar.CGColor = UIColor.greenColor().CGColor
		newCalendar.source = self.source
		let newReminderList = ReminderList(calendar: newCalendar)
		insertNewObject(newReminderList)
		let newIndexPath = NSIndexPath(forRow: reminderLists.count, inSection: 0)
		let newCell = self.tableView.cellForRowAtIndexPath(newIndexPath) as! ReminderListCell
		newCell.setEditing(true, animated: true)
		newCell.reminderListName.becomeFirstResponder()
	}
	
	/// Create an empty new list of reminders and save it to the database.
	func createReminderList(#name: String, color: UIColor) {
		let calendar = EKCalendar(forEntityType: EKEntityTypeReminder, eventStore: self.eventStore)
		calendar.title = name
		calendar.CGColor = color.CGColor
		calendar.source = self.source
		
		// save changes
		var error = NSErrorPointer()
		eventStore.saveCalendar(calendar, commit: true, error: error)
		if error != nil {
			println("Error creating new calendar: \(error)")
		} else {
			println("Successfully saved new calendar.")
		}
	}

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showReminderList" {
            if let indexPath = tableView.indexPathForSelectedRow() {
                let object = reminderLists[indexPath.row - 1] as ReminderList
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
				controller.calendar = object.calendar
                controller.reminders = object.reminders
                controller.listTitle = object.name
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if dataStore.hasCompletedReminders() {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
			// all reminders and reminder lists
            return reminderLists.count + 1
        } else if section == 1 {
			// completed reminders
            return 1
        } else {
            println("Error: tableView:numberOfRowsInSection: unknown section index")
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var identifier = String()
        
		if indexPath.section == 0 {
			if indexPath.row == 0 {
				identifier = "AllRemindersCell"
			} else {
				identifier = "ReminderListCell"
			}
        } else {
            identifier = "CompletedRemindersCell"
        }
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! UITableViewCell
        
        if indexPath.section == 0 && indexPath.row > 0 {
            var cell = cell as! ReminderListCell
            let object = reminderLists[indexPath.row - 1]
			cell.reminderList = object
            cell.reminderListName.text = object.name
            cell.reminderListColor.textColor = object.color
        }

        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if indexPath.section == 0 {
			if indexPath.row == 0 {
				// All reminders cell
				return false
			} else {
				// reminder lists
                return false // disables delete slide action for reminder lists, want to avoid accidental mass deletions
			}
		} else {
			// completed reminders
			return false
		}
    }
	
	override func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
		if let cell = tableView.cellForRowAtIndexPath(indexPath) as! ReminderListCell? {
			cell.reminderListName.userInteractionEnabled = true
		}
	}
	
	override func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
		if let cell = tableView.cellForRowAtIndexPath(indexPath) as! ReminderListCell? {
			cell.reminderListName.userInteractionEnabled = false
		}
	}

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
			let cell = tableView.cellForRowAtIndexPath(indexPath) as! ReminderListCell
			// delete the calendar
			let calendar = calendarForName(cell.reminderListName.text)
			var error = NSErrorPointer()
			eventStore.removeCalendar(calendar, commit: true, error: error)
			if error != nil {
				println("Error removing calendar: \(error)")
			} else {
				println("Successfully removed calendar.")
			}
			
            reminderLists.removeAtIndex(indexPath.row - 1)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
	}
	
	private var activeTextField: UITextField?
}


extension MasterViewController : UITextFieldDelegate {
	func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
		let cell = cellForTextField(textField)
		return cell?.editing ?? false
	}
	
	func textFieldDidBeginEditing(textField: UITextField) {
		activeTextField = textField
		if let cell = cellForTextField(textField), indexPath = tableView.indexPathForCell(cell) {
			tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .None, animated: true)
		}
	}
	
	// Save the new Reminder List
	func textFieldDidEndEditing(textField: UITextField) {
		activeTextField = nil
		if let cell = cellForTextField(textField), indexPath = tableView.indexPathForCell(cell) {
			if cell.reminderList.name != textField.text {
				cell.reminderList.name = textField.text
				let calendar = cell.reminderList.calendar
				calendar.title = textField.text
				calendar.CGColor = cell.reminderListColor.textColor.CGColor
				// save changes
				var error = NSErrorPointer()
				eventStore.saveCalendar(calendar, commit: true, error: error)
				if error != nil {
					println("Error creating new calendar: \(error)")
				} else {
					println("Successfully saved new calendar.")
				}
			}
		}
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		let cell = cellForTextField(textField)
		cell?.setEditing(false, animated: true)
		return false
	}
}
