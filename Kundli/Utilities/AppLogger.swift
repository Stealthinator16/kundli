import os

enum AppLogger {
    static let notifications = Logger(subsystem: "com.kundli.app", category: "notifications")
    static let education = Logger(subsystem: "com.kundli.app", category: "education")
    static let ai = Logger(subsystem: "com.kundli.app", category: "ai")
    static let kundli = Logger(subsystem: "com.kundli.app", category: "kundli")
    static let general = Logger(subsystem: "com.kundli.app", category: "general")
}
