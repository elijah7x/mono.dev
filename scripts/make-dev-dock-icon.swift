// Renders src-tauri/icons/dev-dock.png: the app icon as Icon Services draws it
// for the given bundle, with a DEV pill in the bottom-right corner.
//
//   swift scripts/make-dev-dock-icon.swift <App.app> src-tauri/icons/dev-dock.png
//
// Re-run it after the app icon changes.
import AppKit

let args = CommandLine.arguments
guard args.count == 3 else {
    FileHandle.standardError.write(Data("usage: make-dev-dock-icon.swift <App.app> <out.png>\n".utf8))
    exit(2)
}

let px = 512
let s = CGFloat(px) / 1024
let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
    samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

NSWorkspace.shared.icon(forFile: args[1])
    .draw(in: NSRect(x: 0, y: 0, width: px, height: px), from: .zero, operation: .sourceOver, fraction: 1)

let pill = NSRect(x: 520 * s, y: 56 * s, width: 420 * s, height: 204 * s)
let path = NSBezierPath(roundedRect: pill, xRadius: pill.height / 2, yRadius: pill.height / 2)
let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.35)
shadow.shadowBlurRadius = 14 * s
shadow.shadowOffset = NSSize(width: 0, height: -6 * s)
NSGraphicsContext.saveGraphicsState()
shadow.set()
NSColor(srgbRed: 1.0, green: 0.23, blue: 0.19, alpha: 1).setFill()
path.fill()
NSGraphicsContext.restoreGraphicsState()
NSColor.white.withAlphaComponent(0.9).setStroke()
path.lineWidth = 9 * s
path.stroke()

let text = NSAttributedString(string: "DEV", attributes: [
    .font: NSFont.systemFont(ofSize: 136 * s, weight: .heavy),
    .foregroundColor: NSColor.white,
    .kern: 5 * s,
])
let textSize = text.size()
text.draw(at: NSPoint(x: pill.midX - textSize.width / 2, y: pill.midY - textSize.height / 2))

NSGraphicsContext.restoreGraphicsState()
try rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: args[2]))
