import AppKit
import Carbon

public final class AppleEventTabReader: BrowserTabReading {
    private nonisolated static let replyTimeout: TimeInterval = 1
    private nonisolated static let readingQueue = DispatchQueue(
        label: "com.anthonysarkis.keyboard-switcher.tab-reading",
        qos: .userInitiated,
        attributes: .concurrent
    )

    public init() {}

    public nonisolated func currentTabAddress(in browser: SupportedBrowser) async -> TabAddressResult {
        await withCheckedContinuation { continuation in
            Self.readingQueue.async {
                let result = Self.readTabAddress(in: browser)
                continuation.resume(returning: result)
            }
        }
    }

    private nonisolated static func readTabAddress(in browser: SupportedBrowser) -> TabAddressResult {
        let event = tabAddressEvent(for: browser)
        let neverAsksForConsent = NSAppleEventDescriptor.SendOptions(rawValue: UInt(kAEDoNotPromptForUserConsent))
        let sendOptions: NSAppleEventDescriptor.SendOptions = [.waitForReply, .neverInteract, neverAsksForConsent]
        do {
            let reply = try event.sendEvent(options: sendOptions, timeout: replyTimeout)
            let replyErrorNumber = reply.paramDescriptor(forKeyword: AEKeyword(keyErrorNumber))?.int32Value ?? 0
            if replyErrorNumber != 0 {
                return result(forErrorCode: Int(replyErrorNumber))
            }
            let address = reply.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue
            guard let address, !address.isEmpty else { return .noWindow }
            return .address(address)
        } catch {
            let sendError = error as NSError
            return result(forErrorCode: sendError.code)
        }
    }

    private nonisolated static func result(forErrorCode errorCode: Int) -> TabAddressResult {
        switch errorCode {
        case Int(errAEEventNotPermitted): .denied
        case Int(errAENoSuchObject): .noWindow
        default: .failed(errorCode: errorCode)
        }
    }

    private nonisolated static func tabAddressEvent(for browser: SupportedBrowser) -> NSAppleEventDescriptor {
        let codes = TabAddressCodes(family: browser.family)
        let frontWindowIndex = NSAppleEventDescriptor(int32: 1)
        let frontWindow = objectSpecifier(of: DescType(cWindow), in: .null(), form: DescType(formAbsolutePosition), key: frontWindowIndex)
        let currentTabKey = NSAppleEventDescriptor(typeCode: codes.currentTab)
        let currentTab = objectSpecifier(of: DescType(cProperty), in: frontWindow, form: DescType(formPropertyID), key: currentTabKey)
        let addressKey = NSAppleEventDescriptor(typeCode: codes.address)
        let tabAddress = objectSpecifier(of: DescType(cProperty), in: currentTab, form: DescType(formPropertyID), key: addressKey)

        let browserTarget = NSAppleEventDescriptor(bundleIdentifier: browser.bundleIdentifier)
        let event = NSAppleEventDescriptor.appleEvent(
            withEventClass: AEEventClass(kAECoreSuite),
            eventID: AEEventID(kAEGetData),
            targetDescriptor: browserTarget,
            returnID: AEReturnID(kAutoGenerateReturnID),
            transactionID: AETransactionID(kAnyTransactionID)
        )
        event.setParam(tabAddress, forKeyword: AEKeyword(keyDirectObject))
        return event
    }

    private nonisolated static func objectSpecifier(
        of desiredClass: DescType,
        in container: NSAppleEventDescriptor,
        form: DescType,
        key: NSAppleEventDescriptor
    ) -> NSAppleEventDescriptor {
        let emptyRecord = NSAppleEventDescriptor.record()
        let specifier = emptyRecord.coerce(toDescriptorType: DescType(typeObjectSpecifier)) ?? emptyRecord
        let desiredClassDescriptor = NSAppleEventDescriptor(typeCode: desiredClass)
        let formDescriptor = NSAppleEventDescriptor(enumCode: form)
        specifier.setDescriptor(desiredClassDescriptor, forKeyword: AEKeyword(keyAEDesiredClass))
        specifier.setDescriptor(container, forKeyword: AEKeyword(keyAEContainer))
        specifier.setDescriptor(formDescriptor, forKeyword: AEKeyword(keyAEKeyForm))
        specifier.setDescriptor(key, forKeyword: AEKeyword(keyAEKeyData))
        return specifier
    }
}
