import SwiftUI

struct PerfumeThumb: View {
    let url: String?
    var size: CGFloat = 48

    var body: some View {
        if let url, let parsed = URL(string: url) {
            Color(.secondarySystemBackground)
                .frame(width: size, height: size)
                .overlay {
                    AsyncImage(url: parsed) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .allowsHitTesting(false)
                        } else if phase.error != nil {
                            fallbackIcon
                        } else {
                            ProgressView()
                                .controlSize(.mini)
                        }
                    }
                }
                .clipShape(.rect(cornerRadius: size > 60 ? 14 : 10))
        } else {
            fallbackIcon
                .frame(width: size, height: size)
                .background(Color(.tertiarySystemFill))
                .clipShape(.rect(cornerRadius: size > 60 ? 14 : 10))
        }
    }

    private var fallbackIcon: some View {
        Image(systemName: "drop.fill")
            .font(.system(size: size * 0.35))
            .foregroundStyle(.secondary)
    }
}
