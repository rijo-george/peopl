import SwiftUI

struct PersonDetailView: View {
    @EnvironmentObject var store: PeoplStore
    @EnvironmentObject var theme: ThemeManager
    let person: Person

    private var tc: ThemeColors { theme.colors }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 14) {
                // Initials circle
                ZStack {
                    Circle()
                        .fill(tc.detailAccent.opacity(0.2))
                        .frame(width: 50, height: 50)
                    Text(person.displayInitials)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(tc.detailAccent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(person.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(tc.textPrimary)
                    if !person.company.isEmpty {
                        Text(person.company)
                            .font(.system(size: 13))
                            .foregroundColor(tc.textSecondary)
                    }
                }

                Spacer()

                // Weather badge
                let w = store.weather(for: person.id)
                let wc = w.colorRGB
                VStack(spacing: 2) {
                    Image(systemName: w.icon)
                        .font(.system(size: 22))
                        .foregroundColor(Color(red: wc.r, green: wc.g, blue: wc.b))
                    Text(w.label)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color(red: wc.r, green: wc.g, blue: wc.b))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(tc.detailBg)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Contact info
                    if !person.email.isEmpty || !person.phone.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            if !person.email.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(tc.textSecondary)
                                    Link(person.email, destination: URL(string: "mailto:\(person.email)")!)
                                        .font(.system(size: 13))
                                        .foregroundColor(tc.accent)
                                }
                            }
                            if !person.phone.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "phone.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(tc.textSecondary)
                                    Link(person.phone, destination: URL(string: "tel:\(person.phone)")!)
                                        .font(.system(size: 13))
                                        .foregroundColor(tc.accent)
                                }
                            }
                        }
                    }

                    // Tags
                    if !person.tags.isEmpty {
                        FlowLayout(spacing: 4) {
                            ForEach(person.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 11, weight: .medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(tc.accent.opacity(0.15))
                                    .foregroundColor(tc.accent)
                                    .cornerRadius(4)
                            }
                        }
                    }

                    // Birthday & dates
                    if !person.birthday.isEmpty || !person.dates.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DATES")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(tc.textSecondary)

                            if !person.birthday.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "birthday.cake.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(.pink)
                                    Text("Birthday: \(formatMonthDay(person.birthday))")
                                        .font(.system(size: 12))
                                        .foregroundColor(tc.textPrimary)
                                }
                            }

                            ForEach(person.dates) { nd in
                                HStack(spacing: 6) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 11))
                                        .foregroundColor(tc.listAccent)
                                    Text("\(nd.label): \(formatMonthDay(nd.date))")
                                        .font(.system(size: 12))
                                        .foregroundColor(tc.textPrimary)
                                }
                            }
                        }
                    }

                    // Notes
                    if !person.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("NOTES")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(tc.textSecondary)
                            Text(person.notes)
                                .font(.system(size: 13))
                                .foregroundColor(tc.textPrimary.opacity(0.85))
                                .textSelection(.enabled)
                        }
                    }

                    // Interaction timeline
                    let interactions = store.interactions(for: person.id)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("INTERACTIONS")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(tc.textSecondary)
                            Text("(\(interactions.count))")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(tc.textSecondary)
                        }

                        if interactions.isEmpty {
                            Text("No interactions yet -- press [I] to log one")
                                .font(.system(size: 12))
                                .foregroundColor(tc.textSecondary.opacity(0.5))
                                .padding(.vertical, 8)
                        } else {
                            ForEach(interactions) { interaction in
                                InteractionRow(interaction: interaction)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .background(tc.surface)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(tc.borderInactive, lineWidth: 1)
        )
    }

    private func formatMonthDay(_ string: String) -> String {
        let parts = string.split(separator: "-")
        let month: Int
        let day: Int
        if parts.count == 2, let m = Int(parts[0]), let d = Int(parts[1]) {
            month = m; day = d
        } else if parts.count == 3, let m = Int(parts[1]), let d = Int(parts[2]) {
            month = m; day = d
        } else {
            return string
        }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM d"
        var comps = DateComponents()
        comps.month = month
        comps.day = day
        comps.year = 2000
        if let d = Calendar.current.date(from: comps) {
            return fmt.string(from: d)
        }
        return string
    }
}

// MARK: - Interaction Row

struct InteractionRow: View {
    @EnvironmentObject var theme: ThemeManager
    let interaction: Interaction

    private var tc: ThemeColors { theme.colors }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            let ch = Channel.from(interaction.channel)
            Image(systemName: ch.icon)
                .font(.system(size: 12))
                .foregroundColor(tc.detailAccent)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(ch.displayName)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(tc.textPrimary)
                    Text(interaction.dateDisplay)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(tc.textSecondary)
                }
                if !interaction.note.isEmpty {
                    Text(interaction.note)
                        .font(.system(size: 12))
                        .foregroundColor(tc.textPrimary.opacity(0.8))
                        .textSelection(.enabled)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(tc.surface.opacity(0.5))
        .cornerRadius(6)
    }
}

// MARK: - Flow Layout for tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            if index < result.positions.count {
                let pos = result.positions[index]
                subview.place(at: CGPoint(x: bounds.minX + pos.x, y: bounds.minY + pos.y),
                              proposal: .unspecified)
            }
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (positions, CGSize(width: maxX, height: y + rowHeight))
    }
}
