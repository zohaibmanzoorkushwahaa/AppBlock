//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitor
//
//  Created by Muhammad Irfan Zafar on 26/08/2024.
//

import DeviceActivity
import ManagedSettings
import UserNotifications
import FamilyControls
import SwiftUI


// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    let store = ManagedSettingsStore(named: .daily)
    private let userDefaultsKey = "ScreenTimeSelection"
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        scheduleNotification(with: "interval did start")
        if let selection = getSavedFamilyActivitySelection()
        {
            let applications = selection.applicationTokens
            let categories = selection.categoryTokens
            
            store.shield.applications = applications.isEmpty ? nil : applications
            store.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories)
            store.shield.webDomainCategories = categories.isEmpty ? nil : .specific(categories)
        }

       debugPrint("intervalDidStart")
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        scheduleNotification(with: "interval did End")
        // Handle the end of the interval.
        let store = ManagedSettingsStore(named: .init(activity.rawValue))
        store.clearAllSettings()
        debugPrint("intervalDidEnd")
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        scheduleNotification(with: "eventDidReachThreshold")
        debugPrint("eventDidReachThreshold")
        // Handle the event reaching its threshold.
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        // Handle the warning before the interval starts.
        if let selection = getSavedFamilyActivitySelection() {
            scheduleNotification(with: "\(selection.applicationTokens.count)")
        }
       
        debugPrint("intervalWillStartWarning")
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        scheduleNotification(with: "intervalWillEndWarning")
        debugPrint("intervalWillEndWarning")
        
        // Handle the warning before the interval ends.
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        scheduleNotification(with: "eventWillReachThresholdWarning")
        debugPrint("eventWillReachThresholdWarning")
        // Handle the warning before the event reaches its threshold.
    }
    
    func scheduleNotification(with title: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = "Notification content."
        content.sound = UNNotificationSound.default
        
        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        
        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
    
    func getSavedFamilyActivitySelection() -> FamilyActivitySelection? {
        let defaults = UserDefaults(suiteName: "group.com.arhamsoft.zmk.TestBlockApp.sharedData")
        guard let data = defaults?.data(forKey: userDefaultsKey) else {
            return nil
        }
        var selectedApp: FamilyActivitySelection?
        let decoder = PropertyListDecoder()
        selectedApp = try? decoder.decode(FamilyActivitySelection.self, from: data)
        
        print("saved app updated: ", selectedApp?.applicationTokens.count ?? 0,"saved selected app updated: ", selectedApp?.categoryTokens.count ?? "0")
        return selectedApp
    }
}


@available(iOS 16.0, *)
extension FamilyActivitySelection {
    static func fromKey(_ key: String) -> FamilyActivitySelection {
        if let data = UserDefaults.group()?.data(forKey: key),
           let selection = try? JSONDecoder().decode(
            FamilyActivitySelection.self,
            from: data
        )  {
            return selection
        } else {
            return FamilyActivitySelection(includeEntireCategory: false)
        }
    }
}

extension UserDefaults {
    static func group() -> UserDefaults? {
        return UserDefaults(
            suiteName: "group.<TEAM_ID>.basis.controls"
        )
    }
}
