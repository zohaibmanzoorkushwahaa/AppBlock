//
//  ShieldManager.swift
//  AppBlocker
//
//  Created by Muhammad Irfan Zafar on 23/08/2024.
//

import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity

class ShieldManager: ObservableObject {
    @Published var discouragedSelections = FamilyActivitySelection()
    @Published var sessions: [UserSession] = []
    
    private let userDefaultsKey = "UserSessions"
    private let store = ManagedSettingsStore()
    //     Used to encode codable to UserDefaults
    private let encoder = PropertyListEncoder()
    
    // Used to decode codable from UserDefaults
    private let decoder = PropertyListDecoder()
    
    private let deviceActivityCenter = DeviceActivityCenter()
    
    init() {
        loadSessions()
    }
    
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
        store.clearAllSettings()
    }
    
    func createSession(name: String, startTime: Date, endTime: Date, selections: FamilyActivitySelection) {
        let newSession = UserSession(name: name, discouragedSelections: selections, startTime: startTime, endTime: endTime, isActive: false)

        sessions.append(newSession)
    }
    
    private func applyShieldSettings(for session: UserSession) {
        // Apply the shield settings based on the selected session
        let applications = session.discouragedSelections.applicationTokens
        let categories = session.discouragedSelections.categoryTokens

        store.shield.applications = applications.isEmpty ? nil : applications
        store.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories)
        store.shield.webDomainCategories = categories.isEmpty ? nil : .specific(categories)
    }
}

extension ShieldManager {
    
    
    
    private func startDeviceActivity(session: UserSession) {
        // Define the schedule
        let schedule = DeviceActivitySchedule(
            intervalStart: Calendar.current.dateComponents([.hour, .minute], from: session.startTime),
            intervalEnd: Calendar.current.dateComponents([.hour, .minute], from: session.endTime),
            repeats: true,
            warningTime: DateComponents(minute: 5) // Customize this value as needed
        )

        // Define the event (if necessary)
        let events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]

        // Start monitoring the activity
        do {
            try deviceActivityCenter.startMonitoring(
                session.activityName.toDeviceActivityName(),
                during: schedule,
                events: events
            )
            print("Started monitoring for activity: \(session.activityName)")
        } catch {
            print("Unexpected error: \(error).")
        }
    }

    
    func saveSession(name: String, startTime: Date, endTime: Date) {
        let newSession = UserSession(name: name, discouragedSelections: discouragedSelections, startTime: startTime, endTime: endTime)
        sessions.append(newSession)
        saveSessions()
    }
    
    func activateSession(session: UserSession) {
        // Deactivate all other sessions
        for i in 0..<sessions.count {
            sessions[i].isActive = false
        }
        
        // Activate the selected session
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
             sessions[index].isActive = true
             let selectedSession = sessions[index]
             discouragedSelections = selectedSession.discouragedSelections
             
             // Start device activity monitoring
             startDeviceActivity(session: selectedSession)
         }
        
        saveSessions()
    }
    
    func stopDeviceActivity(session: UserSession) {
        deviceActivityCenter.stopMonitoring([.init(session.activityName.toDeviceActivityName().rawValue)])
        // Update the session status
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index].isActive = false
        }
           
        saveSessions()
    }
    
    private func saveSessions() {
        if let encoded = try? encoder.encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? decoder.decode([UserSession].self, from: data) {
            sessions = decoded
        }
        
    }
}
