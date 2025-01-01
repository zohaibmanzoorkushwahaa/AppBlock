//
//  Bundle-Ext.swift
//  TestBlockApp
//
//  Created by Muhammad Irfan Zafar on 26/08/2024.
//

import Foundation

extension Bundle {

    var appGroupName: String {
        /// plist for APP_GROUP_NAME
        guard let value = Bundle.main.infoDictionary?["APP_GROUP_NAME"] as? String else {
            fatalError("APP_NAME not set in Info.plist")
        }
        return value
    }
}
