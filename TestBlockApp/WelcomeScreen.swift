//
//  WelcomeScreen.swift
//  TestBlockApp
//
//  Created by Muhammad Irfan Zafar on 26/08/2024.
//

import SwiftUI
import FamilyControls
import UserNotifications

struct WelcomeScreen: View {
    @StateObject var familyControlsManager = FamilyControlsManager.shared
    
    @StateObject private var manager = ShieldManager()
    @State var showFamilyPicker: Bool = false
    @State private var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
    
    @State private var showAlert = false
    @State private var sessionStartAlert = false
    @State private var sessionEndAlert = false
    
    @State private var scheduleStartTime: Date = Date().addingTimeInterval(1 * 60) // 15 minutes from now
    @State private var scheduleEndTime: Date = Date().addingTimeInterval(15 * 60) // 17 minutes from now
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.indigo
                    .ignoresSafeArea()
                VStack {
                    welcomeText
                    showAppsButton
                    startPlayView()
                    Spacer()
                    scheduleView
                    
                    HStack {
                        Button {
                            manager.saveSchedule(start: scheduleStartTime, end: scheduleEndTime)
                        } label: {
                            Label("Start Schedule", systemImage: "calendar.badge.clock")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.cyan)
                        Spacer()
                        Button {
                            let content = UNMutableNotificationContent()
                                          content.title = "Notification title."
                                          content.subtitle = "Notification content."
                                          content.sound = UNNotificationSound.default
                                          
//                                            content.body = "Some message"
                                          // show this notification five seconds from now
                                          let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                                          
                                          
                                          // choose a random identifier
                                          let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                                          
                                          // add our notification request
                                          UNUserNotificationCenter.current().add(request)
                        } label: {
                            Label("TEST NOTIFICATIOn", systemImage: "calendar.badge.clock")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.cyan)
                       
                    }
                    
                }
                .familyActivityPicker(isPresented: $showFamilyPicker, selection: $manager.discouragedSelections)
                .alert("Important Message", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                    
                } message: {
                    Text("You dont have Screen Time Permission. Please go to the setting my Give Permission.")
                }
                .alert("Started", isPresented: $sessionStartAlert) {
                    Button("OK", role: .cancel) { }
                    
                } message: {
                    Text("Your Session has been started.")
                }
                .alert("Ended", isPresented: $sessionEndAlert) {
                    Button("OK", role: .cancel) { }
                    
                } message: {
                    Text("Your Session has been ended.")
                }
                
            }
        }
        .onAppear {
            handleRequestAuthorization()
        }
        
    }
    
    
}

private extension WelcomeScreen {
    var welcomeText: some View {
        Text("Welcome to App Blocker")
            .padding(.vertical)
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)
        
    }
    var showAppsButton: some View {
        Button {
            if familyControlsManager.hasScreenTimePermission {
                showFamilyPicker = true
            } else {
                showAlert = true
            }
        } label: {
            Label("Show Apps", systemImage: "plus.circle")
                .font(.title)
            
        }
        .buttonStyle(.borderedProminent)
        .tint(.cyan)
        .padding()
    }
    @MainActor
    func handleRequestAuthorization() {
        FamilyControlsManager.shared.requestAuthorization()
    }
    
    func startPlayView() -> some View {
        HStack {
            Button {
                manager.shieldActivities()
                sessionStartAlert = true
            } label: {
                Label("Start Session", systemImage: "play")
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
            Button {
                manager.clearStore()
                sessionEndAlert = true
            } label: {
                Label("Stop Session", systemImage: "stop")
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
        }
    }
    
    var scheduleView: some View {
            HStack {
                VStack {
                    HStack {

                        DatePicker("Start Time", selection: $scheduleStartTime, displayedComponents: .hourAndMinute)
               
                            .onChange(of: scheduleStartTime) { newStartTime in
                                              // Ensure start time is at least 15 minutes from now
                                              if newStartTime < Date().addingTimeInterval(2 * 60) {
                                                  scheduleStartTime = Date().addingTimeInterval(2 * 60)
                                              }
                                              
                                              // Update end time to 15 minutes after the start time + 2 minutes buffer
                                              scheduleEndTime = Calendar.current.date(byAdding: .minute, value: 2 , to: scheduleStartTime) ?? Date()
                                          }
                    }
                    .padding(.horizontal)
                    .background(Color.cyan)
                    .cornerRadius(6)
                    HStack {
                        DatePicker("End Time", selection: $scheduleEndTime, displayedComponents: .hourAndMinute)
                            .onChange(of: scheduleEndTime) { newEndTime in
                                                 // Ensure end time is at least 15 minutes after start time
                                                 if newEndTime <= scheduleStartTime.addingTimeInterval(15 * 60) {
                                                     scheduleEndTime = scheduleStartTime.addingTimeInterval(15 * 60)
                                                 }
                                             }
                        
                    }
                    .padding(.horizontal)
                    .background(Color.cyan)
                    .cornerRadius(6)
                    Spacer()
                }
                Spacer()
            }
            .padding()
            .foregroundColor(.white)
        
    }
}

#Preview {
    WelcomeScreen()
}
