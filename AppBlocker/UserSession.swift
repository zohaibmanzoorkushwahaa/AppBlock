//
//  SessionManager.swift
//  AppBlocker
//
//  Created by Muhammad Irfan Zafar on 23/08/2024.
//

import Foundation
import FamilyControls
import DeviceActivity

struct CodableDeviceActivityName: Codable {
    let rawValue: String
    
    init(_ name: DeviceActivityName) {
        self.rawValue = name.rawValue
    }
    
    func toDeviceActivityName() -> DeviceActivityName {
        return DeviceActivityName(rawValue)
    }
}

struct CodableDeviceActivityEventName: Codable {
    let rawValue: String
    
    init(_ name: DeviceActivityEvent.Name) {
        self.rawValue = name.rawValue
    }
    
    func toDeviceActivityEventName() -> DeviceActivityEvent.Name {
        return DeviceActivityEvent.Name(rawValue)
    }
}

struct UserSession: Codable, Identifiable {
    let id: UUID
    var name: String
    var discouragedSelections: FamilyActivitySelection
    var startTime: Date
    var endTime: Date
    var isActive: Bool
    var activityName: CodableDeviceActivityName
    var eventName: CodableDeviceActivityEventName
    
    init(name: String, discouragedSelections: FamilyActivitySelection, startTime: Date, endTime: Date, isActive: Bool = false) {
        self.id = UUID()
        self.name = name
        self.discouragedSelections = discouragedSelections
        self.startTime = startTime
        self.endTime = endTime
        self.isActive = isActive
        self.activityName = CodableDeviceActivityName(DeviceActivityName(name))
        self.eventName = CodableDeviceActivityEventName(DeviceActivityEvent.Name("\(name)Event"))
    }
}
