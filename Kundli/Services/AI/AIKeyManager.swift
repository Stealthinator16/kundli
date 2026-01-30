//
//  AIKeyManager.swift
//  Kundli
//
//  Secure storage for Claude API key using Keychain.
//

import Foundation
import Security

final class AIKeyManager {
    static let shared = AIKeyManager()

    private let service = "com.kundli.ai"
    private let account = "claude-api-key"

    private init() {}

    // MARK: - Public Methods

    func saveAPIKey(_ key: String) throws {
        let data = Data(key.utf8)

        // Delete existing key first
        deleteAPIKey()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status: status)
        }
    }

    func getAPIKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }

        return key
    }

    @discardableResult
    func deleteAPIKey() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    var hasAPIKey: Bool {
        getAPIKey() != nil
    }

    func validateAPIKeyFormat(_ key: String) -> Bool {
        // Claude API keys typically start with "sk-ant-" and have a specific format
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.hasPrefix("sk-ant-") && trimmed.count > 20
    }
}

// MARK: - Keychain Error

extension AIKeyManager {
    enum KeychainError: LocalizedError {
        case saveFailed(status: OSStatus)
        case deleteFailed(status: OSStatus)

        var errorDescription: String? {
            switch self {
            case .saveFailed(let status):
                return "Failed to save API key to Keychain (status: \(status))"
            case .deleteFailed(let status):
                return "Failed to delete API key from Keychain (status: \(status))"
            }
        }
    }
}
