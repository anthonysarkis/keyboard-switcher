import Foundation

enum ImageDataURI {
    static func png(_ pngData: Data) -> String {
        let encodedData = pngData.base64EncodedString()
        return "data:image/png;base64,\(encodedData)"
    }
}
