import Foundation

extension String {
    var xmlEscaped: String {
        let ampersandsEscaped = replacingOccurrences(of: "&", with: "&amp;")
        let lessThanSignsEscaped = ampersandsEscaped.replacingOccurrences(of: "<", with: "&lt;")
        return lessThanSignsEscaped.replacingOccurrences(of: ">", with: "&gt;")
    }
}
