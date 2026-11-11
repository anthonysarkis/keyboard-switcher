import AppKit

struct IconFile {
    let name: String
    let pixels: Int
}

enum IconError: Error {
    case noBitmap(String)
    case noPNG(String)
    case iconutilFailed
}

enum IconDesign {
    static let canvasSide: CGFloat = 1024
    static let bodyFrame = CGRect(x: 100, y: 100, width: 824, height: 824)
    static let bodyCornerRadius: CGFloat = 185
    static let shadowBlur: CGFloat = 18
    static let shadowDrop: CGFloat = 8
    static let keyboardFrame = CGRect(x: 232, y: 330, width: 560, height: 364)
    static let keyboardCornerRadius: CGFloat = 64
    static let keyboardLineWidth: CGFloat = 34
    static let keySide: CGFloat = 62
    static let keyGap: CGFloat = 30
    static let keyCornerRadius: CGFloat = 14
    static let topRowInset: CGFloat = 70
    static let rowKeyCounts = [5, 4]
    static let spaceBarSize = CGSize(width: 300, height: 46)
    static let spaceBarCornerRadius: CGFloat = 20

    static var bodyBaseColor: NSColor { NSColor(red: 0.2, green: 0.4, blue: 0.92, alpha: 1) }
    static var bodyTopColor: NSColor { NSColor(red: 0.38, green: 0.6, blue: 1, alpha: 1) }
    static var bodyBottomColor: NSColor { NSColor(red: 0.16, green: 0.32, blue: 0.85, alpha: 1) }
    static var shadowColor: NSColor { NSColor(white: 0, alpha: 0.3) }
}

let iconFiles = [
    IconFile(name: "icon_16x16", pixels: 16),
    IconFile(name: "icon_16x16@2x", pixels: 32),
    IconFile(name: "icon_32x32", pixels: 32),
    IconFile(name: "icon_32x32@2x", pixels: 64),
    IconFile(name: "icon_128x128", pixels: 128),
    IconFile(name: "icon_128x128@2x", pixels: 256),
    IconFile(name: "icon_256x256", pixels: 256),
    IconFile(name: "icon_256x256@2x", pixels: 512),
    IconFile(name: "icon_512x512", pixels: 512),
    IconFile(name: "icon_512x512@2x", pixels: 1024),
]

func drawIcon(scale: CGFloat) {
    drawBody(scale: scale)
    drawKeyboard(scale: scale)
}

func drawBody(scale: CGFloat) {
    let bodyFrame = scaled(IconDesign.bodyFrame, by: scale)
    let cornerRadius = IconDesign.bodyCornerRadius * scale
    let body = NSBezierPath(roundedRect: bodyFrame, xRadius: cornerRadius, yRadius: cornerRadius)

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = IconDesign.shadowColor
    shadow.shadowBlurRadius = IconDesign.shadowBlur * scale
    shadow.shadowOffset = NSSize(width: 0, height: -IconDesign.shadowDrop * scale)
    shadow.set()
    IconDesign.bodyBaseColor.setFill()
    body.fill()
    NSGraphicsContext.restoreGraphicsState()

    let gradient = NSGradient(starting: IconDesign.bodyTopColor, ending: IconDesign.bodyBottomColor)
    gradient?.draw(in: body, angle: -90)
}

func drawKeyboard(scale: CGFloat) {
    let keyboardFrame = scaled(IconDesign.keyboardFrame, by: scale)
    let cornerRadius = IconDesign.keyboardCornerRadius * scale
    let outline = NSBezierPath(roundedRect: keyboardFrame, xRadius: cornerRadius, yRadius: cornerRadius)
    outline.lineWidth = IconDesign.keyboardLineWidth * scale
    NSColor.white.setStroke()
    outline.stroke()

    NSColor.white.setFill()
    let keySide = IconDesign.keySide * scale
    let keyGap = IconDesign.keyGap * scale
    var rowBottom = keyboardFrame.maxY - IconDesign.topRowInset * scale - keySide
    for keyCount in IconDesign.rowKeyCounts {
        drawKeyRow(keyCount: keyCount, bottom: rowBottom, centeredIn: keyboardFrame, scale: scale)
        rowBottom -= keyGap + keySide
    }
    let spaceBarTop = rowBottom + keySide
    drawSpaceBar(top: spaceBarTop, centeredIn: keyboardFrame, scale: scale)
}

func drawKeyRow(keyCount: Int, bottom: CGFloat, centeredIn keyboardFrame: CGRect, scale: CGFloat) {
    let keySide = IconDesign.keySide * scale
    let keyGap = IconDesign.keyGap * scale
    let keyCornerRadius = IconDesign.keyCornerRadius * scale
    let keyCountAsLength = CGFloat(keyCount)
    let rowWidth = keyCountAsLength * keySide + (keyCountAsLength - 1) * keyGap
    let rowLeft = keyboardFrame.midX - rowWidth / 2

    for keyIndex in 0..<keyCount {
        let keyPosition = CGFloat(keyIndex)
        let keyLeft = rowLeft + keyPosition * (keySide + keyGap)
        let keyFrame = CGRect(x: keyLeft, y: bottom, width: keySide, height: keySide)
        let key = NSBezierPath(roundedRect: keyFrame, xRadius: keyCornerRadius, yRadius: keyCornerRadius)
        key.fill()
    }
}

func drawSpaceBar(top: CGFloat, centeredIn keyboardFrame: CGRect, scale: CGFloat) {
    let width = IconDesign.spaceBarSize.width * scale
    let height = IconDesign.spaceBarSize.height * scale
    let cornerRadius = IconDesign.spaceBarCornerRadius * scale
    let spaceBarFrame = CGRect(x: keyboardFrame.midX - width / 2, y: top - height, width: width, height: height)
    let spaceBar = NSBezierPath(roundedRect: spaceBarFrame, xRadius: cornerRadius, yRadius: cornerRadius)
    spaceBar.fill()
}

func scaled(_ frame: CGRect, by scale: CGFloat) -> CGRect {
    CGRect(x: frame.minX * scale, y: frame.minY * scale, width: frame.width * scale, height: frame.height * scale)
}

func renderPNG(_ iconFile: IconFile, into folder: URL) throws {
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: iconFile.pixels, pixelsHigh: iconFile.pixels,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    ) else { throw IconError.noBitmap(iconFile.name) }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    let pixels = CGFloat(iconFile.pixels)
    let scale = pixels / IconDesign.canvasSide
    drawIcon(scale: scale)
    NSGraphicsContext.restoreGraphicsState()

    guard let pngData = bitmap.representation(using: .png, properties: [:]) else { throw IconError.noPNG(iconFile.name) }
    let fileURL = folder.appending(path: "\(iconFile.name).png")
    try pngData.write(to: fileURL)
}

func packIcns(from iconsetFolder: URL, to icnsFile: URL) throws {
    let iconutil = Process()
    iconutil.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
    iconutil.arguments = ["--convert", "icns", iconsetFolder.path, "--output", icnsFile.path]
    try iconutil.run()
    iconutil.waitUntilExit()
    guard iconutil.terminationStatus == 0 else { throw IconError.iconutilFailed }
}

let argumentsAfterScriptName = CommandLine.arguments.dropFirst()
let outputPath = argumentsAfterScriptName.first ?? "build"
let outputFolder = URL(fileURLWithPath: outputPath)
let iconsetFolder = outputFolder.appending(path: "AppIcon.iconset")
let icnsFile = outputFolder.appending(path: "AppIcon.icns")

try? FileManager.default.removeItem(at: iconsetFolder)
try FileManager.default.createDirectory(at: iconsetFolder, withIntermediateDirectories: true)
for iconFile in iconFiles {
    try renderPNG(iconFile, into: iconsetFolder)
}
try packIcns(from: iconsetFolder, to: icnsFile)
print("Made \(icnsFile.path)")
