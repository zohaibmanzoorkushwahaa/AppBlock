//
//  ShieldManager.swift
//  TestBlockApp
//
//  Created by Muhammad Irfan Zafar on 26/08/2024.
//

import FamilyControls
import ManagedSettings
import DeviceActivity
import UserNotifications
import SwiftUI

class ShieldManager: ObservableObject {
        
    @Published var discouragedSelections = FamilyActivitySelection()
    
    @AppStorage("selection", store: UserDefaults(suiteName: "group.com.arhamsoft.zmk.TestBlockApp.sharedData"))
    var selection = FamilyActivitySelection()
    

    let store = ManagedSettingsStore()
    
    // Used to encode codable to UserDefaults
      private let encoder = PropertyListEncoder()

      // Used to decode codable from UserDefaults
      private let decoder = PropertyListDecoder()

      private let userDefaultsKey = "ScreenTimeSelection"
    
    private let activityCenter = DeviceActivityCenter()
 
    func shieldActivities() {
        // Clear to reset previous settings
        store.clearAllSettings()
        
        let applications = discouragedSelections.applicationTokens
        let categories = discouragedSelections.categoryTokens
        
        store.shield.applications = applications.isEmpty ? nil : applications
        store.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories)
        store.shield.webDomainCategories = categories.isEmpty ? nil : .specific(categories)
    }
    
    func clearStore() {
        let store = ManagedSettingsStore(named: .daily)
        store.clearAllSettings()
    }
    func saveSchedule(start: Date, end: Date) {

        selection = discouragedSelections
        let startTime = Calendar.current.dateComponents([.hour, .minute], from: start)
        let endTime = Calendar.current.dateComponents([.hour, .minute], from: end)
        debugPrint(startTime)
        debugPrint(endTime)
        DeviceActivityManager.shared.handleStartDeviceActivityMonitoring(
            startTime: startTime,
            endTime: endTime
        )
        debugPrint(selection.applicationTokens.count)
        saveFamilyActivitySelection(selection: discouragedSelections)
    }
    
    func saveFamilyActivitySelection(selection: FamilyActivitySelection) {
          print("selected app updated: ", selection.applicationTokens.count," category: ", selection.categoryTokens.count)
          let defaults = UserDefaults(suiteName: "group.com.arhamsoft.zmk.TestBlockApp.sharedData")

        defaults?.set(
              try? encoder.encode(selection),
              forKey: userDefaultsKey
          )
          
          //check is data saved to user defaults
          getSavedFamilyActivitySelection()
      }
      
      //get saved family activity selection from UserDefault
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

