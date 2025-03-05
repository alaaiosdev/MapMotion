import SwiftUI

struct AppIconView: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.5, blue: 0.9),  // Deeper blue
                    Color(red: 0.4, green: 0.2, blue: 0.8)   // Rich purple
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Central design
            ZStack {
                // Outer circle
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 75, height: 75)
                
                // Inner circle with pin
                Circle()
                    .fill(.white)
                    .frame(width: 65, height: 65)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                // Location pin
                Image(systemName: "location.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35)
                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                    .offset(y: -2)
                
                // Motion arcs
                ForEach(0..<3) { index in
                    Circle()
                        .trim(from: 0.6, to: 0.9)
                        .stroke(.white.opacity(0.8), lineWidth: 3)
                        .frame(width: 85 + Double(index) * 15, height: 85 + Double(index) * 15)
                        .rotationEffect(.degrees(-45))
                }
            }
        }
    }
}

#Preview {
    Group {
        // iPhone app icon sizes
        AppIconView()
            .frame(width: 60, height: 60) // @2x
            .clipShape(RoundedRectangle(cornerRadius: 13))
        
        AppIconView()
            .frame(width: 1024, height: 1024) // App Store
            .clipShape(RoundedRectangle(cornerRadius: 180))
            .previewDisplayName("App Store")
    }
} 