import Foundation

let argumentsAfterProgramName = CommandLine.arguments.dropFirst()
let command = argumentsAfterProgramName.first
let commandArguments = argumentsAfterProgramName.dropFirst()

switch command {
case "keyboards":
    KeyboardChecks.listKeyboards()
case "switch-test":
    let passed = KeyboardChecks.switchAndRestore()
    exit(passed ? 0 : 1)
case "badges":
    let macDrawsTheBadges = BadgeCheck.compareMacAndDrawnBadges()
    exit(macDrawsTheBadges ? 0 : 1)
case "readme-images":
    let folderPath = commandArguments.first ?? "docs/images"
    let folder = URL(fileURLWithPath: folderPath)
    do {
        try ReadmeImagesCommand.run(writingTo: folder)
    } catch {
        print("README images failed: \(error)")
        exit(1)
    }
case "snapshots":
    let folderPath = commandArguments.first ?? "snapshots"
    let folder = URL(fileURLWithPath: folderPath)
    do {
        try SnapshotCommand.run(writingTo: folder)
    } catch {
        print("Snapshots failed: \(error)")
        exit(1)
    }
default:
    print(Usage.text)
    exit(2)
}
