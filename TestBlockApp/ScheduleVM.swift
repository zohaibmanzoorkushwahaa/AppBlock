//
//  ScheduleVM.swift
//  TestBlockApp
//
//  Created by Muhammad Irfan Zafar on 26/08/2024.
//

import Foundation
import FamilyControls
import SwiftUI

class ScheduleVM: ObservableObject {
    @AppStorage("selection", store: UserDefaults(suiteName: Bundle.main.appGroupName))
    var selection = FamilyActivitySelection()
}
