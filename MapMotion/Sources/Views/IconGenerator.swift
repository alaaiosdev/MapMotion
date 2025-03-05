import SwiftUI

struct IconGenerator: View {
    let iconSizes: [(name: String, size: CGFloat, scale: Int)] = [
        ("AppIcon-20", 20, 1),
        ("AppIcon-20@2x", 20, 2),
        ("AppIcon-20@3x", 20, 3),
        ("AppIcon-29", 29, 1),
        ("AppIcon-29@2x", 29, 2),
        ("AppIcon-29@3x", 29, 3),
        ("AppIcon-40", 40, 1),
        ("AppIcon-40@2x", 40, 2),
        ("AppIcon-40@3x", 40, 3),
        ("AppIcon-60@2x", 60, 2),
        ("AppIcon-60@3x", 60, 3),
        ("AppIcon-76", 76, 1),
        ("AppIcon-76@2x", 76, 2),
        ("AppIcon-83.5@2x", 83.5, 2),
        ("AppIcon-1024", 1024, 1)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                ForEach(iconSizes, id: \.name) { icon in
                    VStack {
                        AppIconView()
                            .frame(width: icon.size * CGFloat(icon.scale),
                                   height: icon.size * CGFloat(icon.scale))
                            .clipShape(RoundedRectangle(cornerRadius: icon.size * 0.225))
                        Text("\(icon.name)")
                            .font(.caption)
                        Text("\(Int(icon.size * CGFloat(icon.scale)))pt")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    IconGenerator()
} 