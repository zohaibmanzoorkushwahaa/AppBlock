//
//  ContentView.swift
//  AppBlocker
//
//  Created by Muhammad Irfan Zafar on 23/08/2024.
//

import SwiftUI

import SwiftUI
import FamilyControls
import ManagedSettings

struct ContentView: View {
    
    @StateObject private var manager = ShieldManager()
    @State private var showActivityPicker = false
    @State private var showCreateSessionSheet = false
    @State private var sessionName: String = ""
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
    
    var body: some View {
        VStack {
            Text("App Blocker")
                .font(.largeTitle)
                .bold()
            
            Spacer()
            
            Button {
                showCreateSessionSheet = true
            } label: {
                Label("Create Session", systemImage: "plus.circle")
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
            
            List {
                ForEach(manager.sessions) { session in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(session.name)
                                .font(.headline)
                            Text("\(session.discouragedSelections.applicationTokens.count) Apps Blocked")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if session.isActive {
                            Button("Deactivate") {
                                manager.stopDeviceActivity(session: session)
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.red)
                        } else {
                            Button("Activate") {
                                manager.activateSession(session: session)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
            }
            .listStyle(.inset)
            
            Spacer()
            
            HStack {
                Button {
                    manager.shieldActivities()
                } label: {
                    Label("Start Blocking", systemImage: "play")
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    manager.clearStore()
                } label: {
                    Label("Stop Blocking", systemImage: "stop")
                }
                .buttonStyle(.borderedProminent)
            }
            
            Spacer()
        }
        .familyActivityPicker(isPresented: $showActivityPicker, selection: $selectedApps)
        .sheet(isPresented: $showCreateSessionSheet) {
            VStack {
                Text("Create New Session")
                    .font(.title)
                    .bold()
                
                TextField("Session Name", text: $sessionName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                DatePicker("Start Time", selection: $startTime, displayedComponents: [.hourAndMinute])
                    .padding()
                
                DatePicker("End Time", selection: $endTime, displayedComponents: [.hourAndMinute])
                    .padding()
                
                Button("Select Apps") {
                    showActivityPicker = true
                }
                .buttonStyle(.bordered)
                .padding()
                
                HStack {
                    Button("Save") {
                        // Save the session
                        manager.createSession(name: sessionName, startTime: startTime, endTime: endTime, selections: selectedApps)
                        // Reset fields
                        sessionName = ""
                        startTime = Date()
                        endTime = Date()
                        selectedApps = FamilyActivitySelection()
                        showCreateSessionSheet = false
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Cancel") {
                        // Reset fields and dismiss
                        sessionName = ""
                        startTime = Date()
                        endTime = Date()
                        selectedApps = FamilyActivitySelection()
                        showCreateSessionSheet = false
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
