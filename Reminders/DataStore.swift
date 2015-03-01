//
//  DataStore.swift
//  Reminders
//
//  Created by Justin Loew on 3/1/15.
//  Copyright (c) 2015 Sapphirine. All rights reserved.
//

import Foundation
import EventKit

private let _dataStoreSharedInstance = DataStore()

class DataStore {
	
	class var sharedInstance: DataStore {
		return _dataStoreSharedInstance
	}
	
	var eventStore: EKEventStore!
	
	var source: EKSource!
	
}
