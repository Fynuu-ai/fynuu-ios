//
//  KeychainHelper.swift
//  fynuu
//
//  Created by Keetha Nikhil on 21/02/26.
//
import Security
import Foundation

enum KeychainHelper {
    private static let service = Bundle.main.bundleIdentifier ?? "com.fynuu"

    static func save(key: String, value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    /*
     How to use::
     // Read
     let apiKey = KeychainHelper.read(key: "groq_api_key")

     // Save
     KeychainHelper.save(key: "groq_api_key", value: "gsk_xxx")

     // Delete (e.g. on sign out)
     KeychainHelper.delete(key: "groq_api_key")
     */
}
