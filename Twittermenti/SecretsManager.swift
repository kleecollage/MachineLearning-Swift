//
//  SecretsManager.swift
//  Twittermenti
//
//  Created by Antonio Hernández Santander on 28/01/26.
//  Copyright © 2026 London App Brewery. All rights reserved.
//

import Foundation

class SecretsManager {
    static let shared = SecretsManager()
    
    private var secrets: [String: Any]?
    
    private init() {
        loadSecrets()
    }
    
    private func loadSecrets() {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let xml = FileManager.default.contents(atPath: path),
              let plist = try? PropertyListSerialization.propertyList(from: xml, format: nil) as? [String: Any] else {
            fatalError("ERROR: Secrets.plist file not found.")
        }
        secrets = plist
    }
    
    func getValue(forKey key: String) -> String? {
        return secrets?[key] as? String
    }
}
