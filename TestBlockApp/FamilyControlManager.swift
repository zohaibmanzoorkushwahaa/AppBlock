//
//  FamilyControlManager.swift
//  TestBlockApp
//
//  Created by Muhammad Irfan Zafar on 26/08/2024.
//

import FamilyControls
import Combine

class FamilyControlsManager: ObservableObject {
    static let shared = FamilyControlsManager()
    private init() {}
    
    // MARK: - FamilyControls
    let authorizationCenter = AuthorizationCenter.shared
    
    // MARK: - ScreenTime
    @Published var hasScreenTimePermission: Bool = false
    

    @MainActor
    func requestAuthorization() {
        if authorizationCenter.authorizationStatus == .approved {
            print("ScreenTime Permission approved")
        } else {
            Task {
                do {
                    try await authorizationCenter.requestAuthorization(for: .individual)
                    hasScreenTimePermission = true
                } catch {

                    print("Failed to enroll Aniyah with error: \(error)")
                    hasScreenTimePermission = false
                    
                }
            }
        }
    }
    
    // MARK: - ScreenTime API
    func requestAuthorizationStatus() -> AuthorizationStatus {
        authorizationCenter.authorizationStatus
    }

    // MARK: requestAuthorizationRevoke
    ///  ScreenTIme  .notDetermined
    func requestAuthorizationRevoke() {
        authorizationCenter.revokeAuthorization(completionHandler: { result in
            switch result {
            case .success:
                print("Success")
            case .failure(let failure):
                print("\(failure) - failed revoke Permission")
            }
        })
    }
    
    // MARK: - updateAuthorizationStatus
    /// hasScreenTimePermission
    func updateAuthorizationStatus(authStatus: AuthorizationStatus) {
        switch authStatus {
        case .notDetermined:
            hasScreenTimePermission = false
        case .denied:
            hasScreenTimePermission = false
        case .approved:
            hasScreenTimePermission = true
        @unknown default:
            fatalError("Fatal Error")
        }
    }
}
