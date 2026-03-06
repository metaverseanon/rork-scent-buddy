import SwiftUI
import SwiftData

struct WearDiaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WearEntry.date, order: .reverse) private var wearEntries: [WearEntry]
    @Query private var perfumes: [Perfume]
    @State private var showingLogWear: Bool = false
    @State private var selectedMonth: Date = Date()
    @State private var scentOfTheDay: ScentOfTheDay?

    private let service = ScentOfTheDayService()
    private let calendar = Calendar.current

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let scent = scentOfTheDay {
                    scentOfTheDayCard(scent)
                }

                statsSection

                calendarSection

                recentWears
            }
            .padding(.horizontal)
        }
        .background(AppearanceManager.shared.theme.backgroundColor)
        .navigationTitle("Wear Diary")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingLogWear = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showingLogWear) {
            LogWearView()
        }
        .task {
            scentOfTheDay = service.suggest(from: perfumes, wearEntries: wearEntries)
        }
    }

    private func scentOfTheDayCard(_ scent: ScentOfTheDay) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(.orange.gradient)
                    .clipShape(Circle())

                Text("SCENT OF THE DAY")
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
                    .tracking(1)
            }

            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.8), .pink.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                    .overlay {
                        Image(systemName: "drop.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.5))
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(scent.perfumeName)
                        .font(.title3.bold())
                    Text(scent.perfumeBrand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: scent.icon)
                            .font(.caption)
                        Text(scent.reason)
                            .font(.caption)
                    }
                    .foregroundStyle(.orange)
                }

                Spacer()
            }

            Button {
                logScentOfTheDay(scent)
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Wearing It Today")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(.orange.gradient)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 12))
            }
        }
        .padding(16)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 20))
        .padding(.top, 8)
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            DiaryStatCard(
                value: "\(wearEntries.count)",
                label: "Total Wears",
                icon: "calendar.badge.clock",
                color: .purple
            )
            DiaryStatCard(
                value: "\(uniquePerfumesWorn)",
                label: "Unique Scents",
                icon: "sparkles",
                color: .teal
            )
            DiaryStatCard(
                value: currentStreak,
                label: "Streak",
                icon: "flame.fill",
                color: .orange
            )
        }
    }

    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button {
                    withAnimation { changeMonth(-1) }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.bold())
                }

                Spacer()

                Text(selectedMonth, format: .dateTime.month(.wide).year())
                    .font(.headline)

                Spacer()

                Button {
                    withAnimation { changeMonth(1) }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.body.bold())
                }
            }

            CalendarGridView(
                dayNumbers: dayNumbers,
                emptySlots: emptySlots,
                didWearOn: didWearOn,
                isCurrentDay: isCurrentDay
            )
        }
        .padding(16)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var recentWears: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Wears")
                    .font(.headline)
                Spacer()
            }

            if wearEntries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "book.closed")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No entries yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Start logging what you wear each day")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                ForEach(wearEntries.prefix(20)) { entry in
                    WearEntryRow(entry: entry)
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation { modelContext.delete(entry) }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .padding(.bottom, 20)
    }

    private var uniquePerfumesWorn: Int {
        Set(wearEntries.map { $0.perfumeName }).count
    }

    private var currentStreak: String {
        var streak = 0
        var checkDate = Date()
        let today = calendar.startOfDay(for: Date())

        let hasEntryToday = wearEntries.contains {
            calendar.isDate($0.date, inSameDayAs: today)
        }
        if !hasEntryToday {
            checkDate = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        }

        while true {
            let dayStart = calendar.startOfDay(for: checkDate)
            let hasEntry = wearEntries.contains {
                calendar.isDate($0.date, inSameDayAs: dayStart)
            }
            if hasEntry {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: dayStart) ?? dayStart
            } else {
                break
            }
        }

        return "\(streak)d"
    }

    private var dayNumbers: [Int] {
        let count = daysInMonth()
        return (1...count).map { $0 }
    }

    private var emptySlots: [Int] {
        let count = firstWeekdayOfMonth()
        guard count > 0 else { return [] }
        return (0..<count).map { $0 }
    }

    private func changeMonth(_ delta: Int) {
        selectedMonth = calendar.date(byAdding: .month, value: delta, to: selectedMonth) ?? selectedMonth
    }

    private func daysInMonth() -> Int {
        calendar.range(of: .day, in: .month, for: selectedMonth)?.count ?? 30
    }

    private func firstWeekdayOfMonth() -> Int {
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        guard let firstDay = calendar.date(from: components) else { return 0 }
        return (calendar.component(.weekday, from: firstDay) + 6) % 7
    }

    private func didWearOn(day: Int) -> Bool {
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        guard var dayComponents = Optional(components) else { return false }
        dayComponents.day = day
        guard let date = calendar.date(from: dayComponents) else { return false }
        return wearEntries.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func isCurrentDay(_ day: Int) -> Bool {
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        return components.year == todayComponents.year
            && components.month == todayComponents.month
            && day == todayComponents.day
    }

    private func logScentOfTheDay(_ scent: ScentOfTheDay) {
        let entry = WearEntry(
            perfumeName: scent.perfumeName,
            perfumeBrand: scent.perfumeBrand,
            date: Date(),
            occasion: "Everyday",
            mood: "Confident"
        )
        modelContext.insert(entry)
        scentOfTheDay = nil
    }
}

struct DiaryStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 12))
    }
}

struct CalendarGridView: View {
    let dayNumbers: [Int]
    let emptySlots: [Int]
    let didWearOn: (Int) -> Bool
    let isCurrentDay: (Int) -> Bool

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdays = [(0, "S"), (1, "M"), (2, "T"), (3, "W"), (4, "T"), (5, "F"), (6, "S")]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(weekdays, id: \.0) { _, day in
                Text(day)
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }

            ForEach(emptySlots, id: \.self) { _ in
                Color.clear.frame(height: 36)
            }

            ForEach(dayNumbers, id: \.self) { day in
                CalendarDayCell(
                    day: day,
                    woreOnDay: didWearOn(day),
                    isToday: isCurrentDay(day)
                )
            }
        }
    }
}

struct CalendarDayCell: View {
    let day: Int
    let woreOnDay: Bool
    let isToday: Bool

    var body: some View {
        Text("\(day)")
            .font(.caption)
            .fontWeight(isToday ? .bold : .regular)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background {
                if woreOnDay {
                    Circle().fill(.tint.opacity(0.2))
                } else if isToday {
                    Circle().stroke(.tint, lineWidth: 1.5)
                }
            }
            .foregroundStyle(woreOnDay ? Color.accentColor : Color.primary)
    }
}

struct WearEntryRow: View {
    let entry: WearEntry

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 10)
                .fill(entryGradient)
                .frame(width: 46, height: 46)
                .overlay {
                    Image(systemName: "drop.fill")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.5))
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.perfumeName)
                    .font(.subheadline.bold())
                Text(entry.perfumeBrand)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(entry.date, format: .dateTime.month(.abbreviated).day())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 2) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 8))
                    Text(entry.occasion)
                        .font(.caption2)
                }
                .foregroundStyle(.tint)
            }
        }
        .padding(12)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }

    private var entryGradient: LinearGradient {
        let hash = abs(entry.perfumeName.hashValue)
        let gradients: [LinearGradient] = [
            LinearGradient(colors: [.purple.opacity(0.7), .indigo.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.pink.opacity(0.6), .orange.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.blue.opacity(0.6), .teal.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.orange.opacity(0.7), .red.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.mint.opacity(0.6), .green.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
        ]
        return gradients[hash % gradients.count]
    }
}
