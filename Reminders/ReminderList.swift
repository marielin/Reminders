//
//  ReminderList.swift
//  Reminders
//
//  Created by Marie Lin on 2015-2-28.
//  Copyright (c) 2015 Sapphirine. All rights reserved.
//

import Foundation
import UIKit
import EventKit

class ReminderList {
    
    // array of reminders in the list
    var reminders = [EKReminder]()
    
    // name of the reminder list
    var name = String()
    
    // color of the reminder list
    var color = UIColor()
    
    // who the reminder is shared with
    // var sharedWith =
    
    // initialize the list with a color
    init(name: String, color: UIColor) {
        self.name = name
        self.color = color
    }
}