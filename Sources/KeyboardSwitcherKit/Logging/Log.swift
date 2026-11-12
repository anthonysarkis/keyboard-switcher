import os

enum Log {
    private static let subsystem = "com.anthonysarkis.keyboard-switcher"

    static let switching = Logger(subsystem: subsystem, category: "switching")
    static let browsers = Logger(subsystem: subsystem, category: "browsers")
    static let rules = Logger(subsystem: subsystem, category: "rules")
    static let settings = Logger(subsystem: subsystem, category: "settings")
    static let badges = Logger(subsystem: subsystem, category: "badges")
    static let websiteIcons = Logger(subsystem: subsystem, category: "website-icons")
}
