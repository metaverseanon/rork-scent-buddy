import SwiftUI

struct SplashScreenView: View {
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    
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
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                
                Text("ScentBuddy")
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundStyle(.white)
                    .opacity(logoOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.8, bounce: 0.3)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
    }
}
