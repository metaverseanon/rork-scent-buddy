import SwiftUI
import SwiftData

struct WishlistView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WishlistPerfume.dateAdded, order: .reverse) private var wishlist: [WishlistPerfume]
    @State private var showingAddSheet: Bool = false

    var body: some View {
        ScrollView {
            if wishlist.isEmpty {
                emptyState
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Button {
                            showingAddSheet = true
                        } label: {
                            Label("Add to Wishlist", systemImage: "plus.circle.fill")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(.tint)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        .sensoryFeedback(.impact(weight: .medium), trigger: showingAddSheet)
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                LazyVStack(spacing: 12) {
                    ForEach(wishlist) { item in
                        WishlistCard(item: item, onDelete: { deleteItem(item) })
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
        }
        .background(AppearanceManager.shared.theme.backgroundColor.ignoresSafeArea())
        .toolbarBackground(AppearanceManager.shared.theme.backgroundColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationTitle("Wishlist")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Wishlist")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddWishlistView()
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Wishlist Empty", systemImage: "heart")
        } description: {
            Text("Keep track of perfumes you'd love to own someday.")
        } actions: {
            Button {
                showingAddSheet = true
            } label: {
                Text("Add to Wishlist")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }

    private func deleteItem(_ item: WishlistPerfume) {
        HapticManager.shared.warning()
        withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
            modelContext.delete(item)
        }
    }
}

struct WishlistCard: View {
    let item: WishlistPerfume
    let onDelete: () -> Void
    @State private var showingDeleteConfirmation: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                PerfumeThumb(url: item.imageURL, size: 56)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.name)
                            .font(.headline)
                        Spacer()
                        priorityBadge
                    }
                    Text(item.brand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(item.concentration)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            if !item.notes.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(item.notes, id: \.self) { note in
                            Text(note)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.pink.opacity(0.1))
                                .foregroundStyle(.pink)
                                .clipShape(Capsule())
                        }
                    }
                }
                .contentMargins(.horizontal, 0)
            }

            if !item.reason.isEmpty {
                Text(item.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack {
                if !item.estimatedPrice.isEmpty {
                    Label(item.estimatedPrice, systemImage: "tag")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(item.dateAdded.formatted(.dateTime.month().day().year()))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(16)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
        .transition(.asymmetric(
            insertion: .scale(scale: 0.95).combined(with: .opacity),
            removal: .scale(scale: 0.9).combined(with: .opacity)
        ))
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Remove from Wishlist", systemImage: "trash")
            }
        }
    }

    private var priorityBadge: some View {
        let (text, color): (String, Color) = switch item.priority {
        case 0: ("Low", .green)
        case 1: ("Medium", .orange)
        default: ("High", .red)
        }
        return Text(text)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
