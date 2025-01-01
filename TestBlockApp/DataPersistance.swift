//
//  DataPersistance.swift
//  TestBlockApp
//
//  Created by Muhammad Irfan Zafar on 26/08/2024.
//

import Foundation
import FamilyControls

class DataPersistence {
    
    public static let shared = DataPersistence()
    
    // Used to encode codable to UserDefaults
    private let encoder = PropertyListEncoder()
    
    // Used to decode codable from UserDefaults
    private let decoder = PropertyListDecoder()
    
    private let sharedApplicationsDataKey = "SharedTimeKey"
    private let isMonitoringKey = "IsMonitoring"
    
    private init() { }
    
    func saveSelection(selection: FamilyActivitySelection) {
        
        let sharedUserDefaults = UserDefaults(suiteName: "group.com.arhamsoft.zmk.TestBlockApp.sharedData")
        sharedUserDefaults?.set(try? encoder.encode(selection), forKey: sharedApplicationsDataKey)
        sharedUserDefaults?.synchronize()
    }
    
    func savedGroupSelection() -> FamilyActivitySelection? {
        let sharedUserDefaults = UserDefaults(suiteName: "group.com.arhamsoft.zmk.TestBlockApp.sharedData")
        
        guard let data = sharedUserDefaults?.data(forKey: sharedApplicationsDataKey) else { return nil }
        
        return try? decoder.decode(FamilyActivitySelection.self, from: data)
    }
    
    func saveMonitoringState(isMonitoring: Bool) {
        UserDefaults.standard.set(isMonitoring, forKey: isMonitoringKey)
    }
    
    func getMonitoringState() -> Bool {
        return UserDefaults.standard.bool(forKey: isMonitoringKey)
    }
}

// MARK: - FamilyActivitySelection Parser
extension FamilyActivitySelection: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
            let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
// MARK: - Date Parser
extension Date: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode(Date.self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
            let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
