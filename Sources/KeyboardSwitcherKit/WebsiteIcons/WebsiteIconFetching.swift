import Foundation

public protocol WebsiteIconFetching: AnyObject, Sendable {
    func iconData(for website: String) async -> Data?
}
