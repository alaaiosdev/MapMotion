import SwiftUI

struct LogoView: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.8),
                    Color.purple.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Map pin with motion lines
            ZStack {
                // Motion lines
                ForEach(0..<3) { index in
                    Circle()
                        .strokeBorder(Color.white.opacity(0.8), lineWidth: 2)
                        .frame(width: 60.0 + Double(index) * 20)
                        .scaleEffect(0.8)
                }
                
                // Location pin
                Image(systemName: "location.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40)
                    .foregroundColor(.white)
                    .offset(y: -5)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
            }
        }
    }
}

#Preview {
    Group {
        LogoView()
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        
        LogoView()
            .frame(width: 1024, height: 1024)
            .clipShape(RoundedRectangle(cornerRadius: 200))
    }
} 