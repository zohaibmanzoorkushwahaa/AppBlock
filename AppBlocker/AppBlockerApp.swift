//
//  AppBlockerApp.swift
//  AppBlocker
//
//  Created by Muhammad Irfan Zafar on 23/08/2024.
//

import SwiftUI
import FamilyControls

@main
struct AppBlockerApp: App {
    @StateObject var familyControlsManager = FamilyControlsManager.shared
    var body: some Scene {
        WindowGroup {
            VStack {
                if !familyControlsManager.hasScreenTimePermission {
                    PermissionView()
                } else {
                    ContentView()
                }
            }
            .onReceive(familyControlsManager.authorizationCenter.$authorizationStatus) { newValue in
                DispatchQueue.main.async {
                    familyControlsManager.updateAuthorizationStatus(authStatus: newValue)
                }
            }
        }
    }
    
    func requestAuth() async {
        try? await AuthorizationCenter.shared.requestAuthorization(for: .individual)
    }
}
