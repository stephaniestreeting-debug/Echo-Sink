import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import Foundation

let size = 1024
let ctx = CGContext(
    data: nil,
    width: size,
    height: size,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
)!

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: r, green: g, blue: b, alpha: a)
}

let rect = CGRect(x: 0, y: 0, width: size, height: size)

// Background: deep teal-navy vertical gradient (the "depth" of the sink)
let bgColors = [color(0.086, 0.184, 0.212), color(0.043, 0.098, 0.114)] as CFArray
let bgGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: bgColors, locations: [0, 1])!
ctx.drawLinearGradient(bgGradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: 0, y: 0), options: [])

// Concentric ripples radiating from the center — something has settled here
let center = CGPoint(x: CGFloat(size) * 0.5, y: CGFloat(size) * 0.5)
let rippleRadii: [CGFloat] = [430, 340, 250, 165]
for (i, radius) in rippleRadii.enumerated() {
    let alpha = 0.14 + (CGFloat(rippleRadii.count - i) * 0.06)
    ctx.setStrokeColor(color(0.31, 0.85, 0.77, alpha))
    ctx.setLineWidth(7)
    ctx.strokeEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
}

// The settled mark at dead center — the draft, at rest
let dotRadius: CGFloat = 78
ctx.setFillColor(color(0.965, 0.945, 0.902))
ctx.fillEllipse(in: CGRect(x: center.x - dotRadius, y: center.y - dotRadius, width: dotRadius * 2, height: dotRadius * 2))

let outputPath = CommandLine.arguments[1]
let cfURL = URL(fileURLWithPath: outputPath) as CFURL
let destination = CGImageDestinationCreateWithURL(cfURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(destination, ctx.makeImage()!, nil)
CGImageDestinationFinalize(destination)
print("wrote \(outputPath)")
