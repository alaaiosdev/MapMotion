import SwiftUI
import UIKit

struct IconExporter {
    static func generateIcon(size: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        
        return renderer.image { context in
            // Draw gradient background
            let colors = [
                UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1),
                UIColor(red: 0.4, green: 0.2, blue: 0.8, alpha: 1)
            ]
            
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: colors.map { $0.cgColor } as CFArray,
                                    locations: [0, 1])!
            
            context.cgContext.drawLinearGradient(gradient,
                                               start: CGPoint(x: 0, y: 0),
                                               end: CGPoint(x: size, y: size),
                                               options: [])
            
            // Draw circles and pin
            let center = CGPoint(x: size/2, y: size/2)
            
            // Outer circle
            context.cgContext.setFillColor(UIColor.white.withAlphaComponent(0.15).cgColor)
            context.cgContext.addArc(center: center,
                                   radius: size * 0.375,
                                   startAngle: 0,
                                   endAngle: .pi * 2,
                                   clockwise: true)
            context.cgContext.fillPath()
            
            // Inner circle
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.addArc(center: center,
                                   radius: size * 0.325,
                                   startAngle: 0,
                                   endAngle: .pi * 2,
                                   clockwise: true)
            context.cgContext.fillPath()
            
            // Draw motion arcs
            context.cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.8).cgColor)
            context.cgContext.setLineWidth(max(1, size * 0.03))
            
            for i in 0..<3 {
                let radius = size * (0.425 + Double(i) * 0.075)
                context.cgContext.addArc(center: center,
                                       radius: radius,
                                       startAngle: .pi * 0.7,
                                       endAngle: .pi * 1.3,
                                       clockwise: false)
                context.cgContext.strokePath()
            }
            
            // Draw location pin
            if let pinImage = UIImage(systemName: "location.fill")?.withTintColor(UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1)) {
                let pinSize = size * 0.35
                let pinRect = CGRect(x: center.x - pinSize/2,
                                   y: center.y - pinSize/2,
                                   width: pinSize,
                                   height: pinSize)
                pinImage.draw(in: pinRect)
            }
        }
    }
    
    static func saveIcon(name: String, size: CGFloat) {
        let image = generateIcon(size: size)
        
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let iconPath = documentsPath.appendingPathComponent("AppIcon-\(name).png")
            
            if let data = image.pngData() {
                try? data.write(to: iconPath)
                print("Saved icon: \(iconPath.path)")
            }
        }
    }
    
    static func generateAllIcons() {
        let sizes: [(name: String, size: CGFloat)] = [
            ("20", 20),
            ("20@2x", 40),
            ("20@3x", 60),
            ("29", 29),
            ("29@2x", 58),
            ("29@3x", 87),
            ("40", 40),
            ("40@2x", 80),
            ("40@3x", 120),
            ("60@2x", 120),
            ("60@3x", 180),
            ("76", 76),
            ("76@2x", 152),
            ("83.5@2x", 167),
            ("1024", 1024)
        ]
        
        for size in sizes {
            saveIcon(name: size.name, size: size.size)
        }
    }
}

// Helper view to use the exporter
struct IconExporterView: View {
    var body: some View {
        VStack {
            Button("Generate App Icons") {
                IconExporter.generateAllIcons()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
} 