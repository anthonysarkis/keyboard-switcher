import CoreServices

nonisolated struct TabAddressCodes {
    let currentTab: FourCharCode
    let address: FourCharCode

    init(family: SupportedBrowser.Family) {
        switch family {
        case .chromium:
            currentTab = FourCharCode(text: "acTa")
            address = FourCharCode(text: "URL ")
        case .safari:
            currentTab = FourCharCode(text: "cTab")
            address = FourCharCode(text: "pURL")
        }
    }
}
