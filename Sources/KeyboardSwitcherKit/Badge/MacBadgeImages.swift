import AppKit
import KeyboardSwitcherCore

public final class MacBadgeImages: BadgeImageMaking {
    private static let frameworkPath = "/System/Library/PrivateFrameworks/KeyboardLayouts.framework/KeyboardLayouts"
    private static let iconManagerClassName = "KLInputSourceIconManager"

    private let iconManagerType: any InputSourceIconManaging.Type

    public init?() {
        guard let iconManagerType = Self.loadIconManagerType() else { return nil }
        self.iconManagerType = iconManagerType
    }

    public func badgeImages(for keyboards: [Keyboard]) -> [String: NSImage] {
        let keyboardIDs = keyboards.map(\.id)
        let iconManager = iconManagerType.init(enabledInputSourceIDs: keyboardIDs, primaryLocale: .current)
        var images: [String: NSImage] = [:]
        for keyboardID in keyboardIDs {
            images[keyboardID] = iconManager.image(
                forInputSource: keyboardID,
                language: nil,
                forceToFillBackground: false,
                useRoundCorner: true
            )
        }
        return images
    }

    private static func loadIconManagerType() -> (any InputSourceIconManaging.Type)? {
        guard dlopen(frameworkPath, RTLD_LAZY) != nil,
              let iconManagerClass = NSClassFromString(iconManagerClassName),
              answersEveryCall(iconManagerClass)
        else { return nil }

        class_addProtocol(iconManagerClass, InputSourceIconManaging.self)
        return iconManagerClass as? any InputSourceIconManaging.Type
    }

    private static func answersEveryCall(_ iconManagerClass: AnyClass) -> Bool {
        var callCount: UInt32 = 0
        guard let callDescriptions = protocol_copyMethodDescriptionList(InputSourceIconManaging.self, true, true, &callCount) else {
            return false
        }
        defer { free(callDescriptions) }

        let declaredCallCount = Int(callCount)
        let declaredCalls = UnsafeBufferPointer(start: callDescriptions, count: declaredCallCount)
        return declaredCalls.allSatisfy { declaredCall in
            guard let selector = declaredCall.name else { return false }
            return class_respondsToSelector(iconManagerClass, selector)
        }
    }
}
