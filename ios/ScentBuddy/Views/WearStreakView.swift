import SwiftUI
import SwiftData

struct WearStreakView: View {
    let wearEntries: [WearEntry]
    @State private var animateFlame: Bool = false
    @State private var showDetail: Bool = false

    private let calendar = Calendar.current
    private var theme: AppTheme { AppearanceManager.shared.theme }

    private var streakData: StreakInfo {
        computeStreak()
    }

    var body: some View {
        Button {
            showDetail = true
        } label: {
            streakCard
        }
        .buttonStyle(ScaleButtonStyle())
        .sheet(isPresented: $showDetail) {
            StreakDetailSheet(streakData: streakData, wearEntries: wearEntries)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                animateFlame = true
            }
        }
    }

    private var streakCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: streakData.current > 0
                                    ? [.orange, .red.opacity(0.8)]
                                    : [.gray.opacity(0.3), .gray.opacity(0.15)],
                                center: .center,
                                startRadius: 2,
                                endRadius: 28
                            )
                        )
                        .frame(width: 56, height: 56)
                        .scaleEffect(animateFlame && streakData.current > 0 ? 1.06 : 1.0)

                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundStyle(streakData.current > 0 ? .white : .gray)
                        .scaleEffect(animateFlame && streakData.current > 0 ? 1.1 : 0.95)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("\(streakData.current)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .contentTransition(.numericText())
                        Text(streakData.current == 1 ? "day" : "days")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                            .offset(y: 2)
                    }

                    Text(streakData.motivationText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if streakData.current > 0 {
                    VStack(spacing: 2) {
                        Text("Best")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        Text("\(streakData.longest)")
                            .font(.callout.bold())
                            .foregroundStyle(.orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.orange.opacity(0.1))
                    .clipShape(Capsule())
                }
            }

            Divider()
                .padding(.vertical, 12)

            weekTracker
        }
        .padding(16)
        .background(theme.cardColor)
        .clipShape(.rect(cornerRadius: 20))
    }

    private var weekTracker: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.offset) { day in
                VStack(spacing: 6) {
                    Text(day.label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)

                    ZStack {
                        Circle()
                            .fill(day.status.fillColor)
                            .frame(width: 32, height: 32)

                        if day.status == .completed {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        } else if day.status == .today {
                            Circle()
                                .stroke(.orange, style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                                .frame(width: 32, height: 32)
                            Text("?")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.orange)
                        } else if day.status == .missed {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.secondary.opacity(0.5))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private struct WeekDay {
        let offset: Int
        let label: String
        let status: DayStatus
    }

    private enum DayStatus {
        case completed, missed, today, future

        var fillColor: Color {
            switch self {
            case .completed: return .orange
            case .missed: return Color(.systemGray5)
            case .today: return .clear
            case .future: return Color(.systemGray6)
            }
        }
    }

    private var weekDays: [WeekDay] {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today) ?? today
        let labels = ["S", "M", "T", "W", "T", "F", "S"]

        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek) ?? today
            let isToday = calendar.isDateInToday(date)
            let isFuture = date > today
            let hasEntry = wearEntries.contains { calendar.isDate($0.date, inSameDayAs: date) }

            let status: DayStatus
            if isToday {
                status = hasEntry ? .completed : .today
            } else if isFuture {
                status = .future
            } else {
                status = hasEntry ? .completed : .missed
            }

            return WeekDay(offset: offset, label: labels[offset], status: status)
        }
    }

    private func computeStreak() -> StreakInfo {
        var current = 0
        var checkDate = calendar.startOfDay(for: Date())

        let hasEntryToday = wearEntries.contains {
            calendar.isDate($0.date, inSameDayAs: checkDate)
        }
        if !hasEntryToday {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }

        while true {
            let hasEntry = wearEntries.contains {
                calendar.isDate($0.date, inSameDayAs: checkDate)
            }
            if hasEntry {
                current += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }

        var longest = current
        var tempStreak = 0
        let sortedDates = Set(wearEntries.map { calendar.startOfDay(for: $0.date) }).sorted(by: >)
        for i in 0..<sortedDates.count {
            if i == 0 {
                tempStreak = 1
            } else {
                let diff = calendar.dateComponents([.day], from: sortedDates[i], to: sortedDates[i - 1]).day ?? 0
                if diff == 1 {
                    tempStreak += 1
                } else {
                    tempStreak = 1
                }
            }
            longest = max(longest, tempStreak)
        }

        return StreakInfo(current: current, longest: longest, loggedToday: hasEntryToday)
    }
}

struct StreakInfo {
    let current: Int
    let longest: Int
    let loggedToday: Bool

    var motivationText: String {
        if current == 0 {
            return "Log a wear to start your streak!"
        }
        if !loggedToday {
            return "Don't break your streak! Log today."
        }
        switch current {
        case 1: return "You're off! Keep it going tomorrow."
        case 2...4: return "Nice start! Building momentum."
        case 5...6: return "Almost a full week!"
        case 7: return "One full week! Legendary."
        case 8...13: return "Unstoppable! \(current) days strong."
        case 14...29: return "Two weeks+! Absolute dedication."
        case 30...99: return "A whole month of scents!"
        default: return "You're a fragrance machine!"
        }
    }
}

struct StreakDetailSheet: View {
    let streakData: StreakInfo
    let wearEntries: [WearEntry]
    @Environment(\.dismiss) private var dismiss

    private let calendar = Calendar.current
    private var theme: AppTheme { AppearanceManager.shared.theme }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    streakHero

                    statsRow

                    milestoneSection

                    last30DaysGrid
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(theme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Wear Streak")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var streakHero: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: streakData.current > 0
                                ? [.orange, .red.opacity(0.6), .clear]
                                : [.gray.opacity(0.2), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)

                Image(systemName: "flame.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        streakData.current > 0
                            ? AnyShapeStyle(.linearGradient(
                                colors: [.yellow, .orange, .red],
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                            : AnyShapeStyle(.gray.opacity(0.4))
                    )
                    .symbolEffect(.bounce, options: .speed(0.5).repeat(2), value: streakData.current)
            }

            Text("\(streakData.current)")
                .font(.system(size: 52, weight: .black, design: .rounded))

            Text(streakData.current == 1 ? "Day Streak" : "Day Streak")
                .font(.title3.bold())
                .foregroundStyle(.secondary)

            Text(streakData.motivationText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatPill(icon: "flame.fill", label: "Current", value: "\(streakData.current)", color: .orange)
            StatPill(icon: "trophy.fill", label: "Longest", value: "\(streakData.longest)", color: .yellow)
            StatPill(icon: "calendar", label: "This Month", value: "\(wearsThisMonth)", color: .teal)
        }
    }

    private var milestoneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Milestones")
                .font(.headline)

            let milestones: [(Int, String, String)] = [
                (3, "Hatching", "flame"),
                (7, "Week Warrior", "star.fill"),
                (14, "Fortnight Flair", "sparkles"),
                (30, "Monthly Master", "crown.fill"),
                (60, "Scent Sage", "leaf.fill"),
                (100, "Century Club", "trophy.fill"),
                (365, "Legendary Nose", "diamond.fill"),
            ]

            ForEach(milestones, id: \.0) { days, title, icon in
                let achieved = streakData.longest >= days
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundStyle(achieved ? .orange : .secondary.opacity(0.4))
                        .frame(width: 32, height: 32)
                        .background(achieved ? .orange.opacity(0.15) : Color(.systemGray6))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline.bold())
                            .foregroundStyle(achieved ? .primary : .secondary)
                        Text("\(days) day streak")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if achieved {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Text("\(max(0, days - streakData.longest)) to go")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(12)
                .background(theme.cardColor)
                .clipShape(.rect(cornerRadius: 12))
            }
        }
    }

    private var last30DaysGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 30 Days")
                .font(.headline)

            let today = calendar.startOfDay(for: Date())
            let days: [Date] = (0..<30).compactMap {
                calendar.date(byAdding: .day, value: -$0, to: today)
            }.reversed()

            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(days, id: \.self) { date in
                    let hasEntry = wearEntries.contains {
                        calendar.isDate($0.date, inSameDayAs: date)
                    }
                    let isToday = calendar.isDateInToday(date)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(hasEntry ? .orange : Color(.systemGray6))
                        .frame(height: 28)
                        .overlay {
                            if isToday {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(.primary.opacity(0.3), lineWidth: 1)
                            }
                        }
                }
            }
            .padding(12)
            .background(theme.cardColor)
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var wearsThisMonth: Int {
        let components = calendar.dateComponents([.year, .month], from: Date())
        return wearEntries.filter {
            let entryComponents = calendar.dateComponents([.year, .month], from: $0.date)
            return entryComponents.year == components.year && entryComponents.month == components.month
        }.count
    }
}

struct StatPill: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.bold())
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }
}
