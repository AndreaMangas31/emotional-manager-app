import SwiftUI

struct SimpleChart: View {
    let data: [(Date, Int)]
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .font(.headline)
                .foregroundColor(.primary)
            
            if data.isEmpty {
                VStack {
                    Image(systemName: "chart.line.xaxis")
                        .font(.system(size: 32))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Sin datos disponibles")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(Array(data.suffix(14)), id: \.0) { date, value in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(colorForScore(value))
                                .frame(height: CGFloat(value) * 2)
                            
                            Text("\(value)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 100)
                .padding(.vertical, 12)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
    
    private func colorForScore(_ score: Int) -> Color {
        switch score {
        case 8...10:
            return .green.opacity(0.7)
        case 6...7:
            return .blue.opacity(0.7)
        case 4...5:
            return .orange.opacity(0.7)
        default:
            return Color.red.opacity(0.7)
        }
    }
}

#Preview {
    let data: [(Date, Int)] = [
        (Date().addingTimeInterval(-86400 * 13), 5),
        (Date().addingTimeInterval(-86400 * 12), 6),
        (Date().addingTimeInterval(-86400 * 11), 7),
        (Date().addingTimeInterval(-86400 * 10), 8),
        (Date().addingTimeInterval(-86400 * 9), 7),
        (Date().addingTimeInterval(-86400 * 8), 6),
        (Date().addingTimeInterval(-86400 * 7), 8),
        (Date().addingTimeInterval(-86400 * 6), 9),
        (Date().addingTimeInterval(-86400 * 5), 7),
        (Date().addingTimeInterval(-86400 * 4), 8),
        (Date().addingTimeInterval(-86400 * 3), 6),
        (Date().addingTimeInterval(-86400 * 2), 7),
        (Date().addingTimeInterval(-86400), 8),
        (Date(), 9)
    ]
    
    SimpleChart(data: data, label: "Ultimas dos semanas")
        .padding()
}
