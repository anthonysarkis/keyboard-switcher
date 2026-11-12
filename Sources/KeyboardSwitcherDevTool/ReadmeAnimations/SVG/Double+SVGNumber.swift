import Foundation

extension Double {
    var svgRounded: Double {
        (self * 100).rounded() / 100
    }

    var svgNumber: String {
        var text = String(format: "%.2f", self)
        while text.hasSuffix("0") {
            text.removeLast()
        }
        if text.hasSuffix(".") {
            text.removeLast()
        }
        return text == "-0" ? "0" : text
    }
}
