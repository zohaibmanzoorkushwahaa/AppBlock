//
//  PermissionView.swift
//  AppBlocker
//
//  Created by Muhammad Irfan Zafar on 23/08/2024.
//

import SwiftUI

struct PermissionView: View {
    var body: some View {
        VStack {
            permissionButtonView()
        }
    }
    
    private func permissionButtonView() -> some View {
        HStack {
            Button {
                Task {
                    await handleRequestAuthorization()
                }
            } label: {
                Text("Request For Permission")
            }
            .buttonStyle(.borderless)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: 128)
    }
    
    @MainActor
    func handleRequestAuthorization() {
        FamilyControlsManager.shared.requestAuthorization()
    }
}

#Preview {
    PermissionView()
}
