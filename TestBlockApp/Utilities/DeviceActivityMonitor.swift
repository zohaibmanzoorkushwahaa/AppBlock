//
//  DeviceActivityMonitor.swift
//  TestBlockApp
//
//  Created by Muhammad Irfan Zafar on 26/08/2024.
//

import Foundation
import DeviceActivity
import ManagedSettings

class DeviceActivityManager: ObservableObject {
    static let shared = DeviceActivityManager()
    private init() {}

    let deviceActivityCenter = DeviceActivityCenter()
    
    /// https://github.com/DeveloperAcademy-POSTECH/MC2-Team18-sunghoyazaza
    func handleStartDeviceActivityMonitoring(
        startTime: DateComponents,
        endTime: DateComponents,
        deviceActivityName: DeviceActivityName = .daily,
        warningTime: DateComponents = DateComponents(minute: 5)
    ) {
        let schedule: DeviceActivitySchedule
        
        if deviceActivityName == .daily {
            schedule = DeviceActivitySchedule(
                intervalStart: startTime,
                intervalEnd: endTime,
                repeats: true,
                warningTime: warningTime
            )
            do {
                try deviceActivityCenter.startMonitoring(deviceActivityName, during: schedule)

            } catch {
                print("Unexpected error: \(error).")
            }
        }
    }
    
    // MARK: - Device Activity
    func handleStopDeviceActivityMonitoring() {
        deviceActivityCenter.stopMonitoring()
    }
}

// MARK: - Schedule Name List
extension DeviceActivityName {
    static let daily = Self("daily")
}

// MARK: - ManagedSettingsStore List
extension ManagedSettingsStore.Name {
    static let daily = Self("daily")
}
