import SwiftUI

struct SplashScreenView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    @State private var shimmerOffset: CGFloat = -1
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("AppIconImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .clipShape(.rect(cornerRadius: 28))
                    .shadow(color: .purple.opacity(0.4), radius: 20, y: 8)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                
                Text("ScentBuddy")
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundStyle(.white)
                    .opacity(logoOpacity)
                    .offset(y: textOffset)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.9, bounce: 0.35)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.spring(duration: 0.8, bounce: 0.2).delay(0.15)) {
                textOffset = 0
            }
        }
    }
}
