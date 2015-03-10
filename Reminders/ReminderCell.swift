//
//  ReminderCell.swift
//  Reminders
//
//  Created by Marie Lin on 2015-3-5.
//  Copyright (c) 2015 Sapphirine. All rights reserved.
//

import UIKit

class ReminderCell: UITableViewCell {
    @IBOutlet weak var reminderName: UITextField!
    @IBOutlet weak var alarmDate: UILabel!
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.reminderName.userInteractionEnabled = editing
    }
    
}