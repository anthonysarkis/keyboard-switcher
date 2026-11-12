import Foundation
import KeyboardSwitcherKit

public final class FakeWebsiteIcons: WebsiteIconFetching {
    public var answers: [String: Data]
    public private(set) var requests: [String] = []
    public var holdsAnswers = false
    private var heldAnswers: [CheckedContinuation<Void, Never>] = []
    private var requestWaiters: [CheckedContinuation<Void, Never>] = []

    public init(answers: [String: Data] = [:]) {
        self.answers = answers
    }

    public func waitForRequest() async {
        guard requests.isEmpty else { return }
        await withCheckedContinuation { requestWaiter in requestWaiters.append(requestWaiter) }
    }

    public func releaseAnswers() {
        holdsAnswers = false
        let waitingAnswers = heldAnswers
        heldAnswers = []
        for waitingAnswer in waitingAnswers {
            waitingAnswer.resume()
        }
    }

    public func iconData(for website: String) async -> Data? {
        requests.append(website)
        let waiters = requestWaiters
        requestWaiters = []
        for requestWaiter in waiters {
            requestWaiter.resume()
        }
        if holdsAnswers {
            await withCheckedContinuation { waitingAnswer in heldAnswers.append(waitingAnswer) }
        }
        return answers[website]
    }
}
