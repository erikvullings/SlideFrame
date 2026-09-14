import AppKit

let size = CGSize(width: 1024, height: 1024)
let image = NSImage(size: size)
image.lockFocus()

let background = NSBezierPath(
    roundedRect: CGRect(x: 52, y: 52, width: 920, height: 920),
    xRadius: 210,
    yRadius: 210
)
NSGradient(
    starting: NSColor(calibratedRed: 0.08, green: 0.40, blue: 0.98, alpha: 1),
    ending: NSColor(calibratedRed: 0.02, green: 0.20, blue: 0.62, alpha: 1)
)?.draw(in: background, angle: -35)

let aperture = NSBezierPath(rect: CGRect(x: 190, y: 270, width: 644, height: 362))
NSColor.white.setStroke()
aperture.lineWidth = 26
aperture.stroke()

for point in [
    CGPoint(x: 190, y: 270),
    CGPoint(x: 834, y: 270),
    CGPoint(x: 190, y: 632),
    CGPoint(x: 834, y: 632)
] {
    NSBezierPath(
        roundedRect: CGRect(x: point.x - 24, y: point.y - 24, width: 48, height: 48),
        xRadius: 9,
        yRadius: 9
    ).fill()
}

let badge = NSBezierPath(
    roundedRect: CGRect(x: 357, y: 430, width: 310, height: 92),
    xRadius: 46,
    yRadius: 46
)
NSColor(calibratedWhite: 0.08, alpha: 0.78).setFill()
badge.fill()

let text = "16:9"
let attributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.monospacedDigitSystemFont(ofSize: 48, weight: .semibold),
    .foregroundColor: NSColor.white
]
let textSize = text.size(withAttributes: attributes)
text.draw(
    at: CGPoint(x: 512 - textSize.width / 2, y: 476 - textSize.height / 2),
    withAttributes: attributes
)

image.unlockFocus()
guard
    let tiff = image.tiffRepresentation,
    let bitmap = NSBitmapImageRep(data: tiff),
    let png = bitmap.representation(using: .png, properties: [:])
else {
    fatalError("Could not render icon")
}
try png.write(to: URL(fileURLWithPath: "SlideFrame/Assets.xcassets/AppIcon.appiconset/AppIcon1024.png"))
