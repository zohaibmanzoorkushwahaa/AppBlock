//
//  TestBlockAppApp.swift
//  TestBlockApp
//
//  Created by Muhammad Irfan Zafar on 26/08/2024.
//

import SwiftUI
import UserNotifications

@main
struct TestBlockAppApp: App {
    let persistenceController = PersistenceController.shared

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            WelcomeScreen()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)

        }
    }
}
