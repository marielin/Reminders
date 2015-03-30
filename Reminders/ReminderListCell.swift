//
//  ReminderListCell.swift
//  Reminders
//
//  Created by Marie Lin on 2015-2-28.
//  Copyright (c) 2015 Sapphirine. All rights reserved.
//

import Foundation
import UIKit

class ReminderListCell : UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var reminderListColor: UILabel!
    @IBOutlet weak var reminderListName: UITextField!
	var reminderList: ReminderList!
	
	override func setEditing(editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		self.reminderListName.userInteractionEnabled = editing
	}
	
}