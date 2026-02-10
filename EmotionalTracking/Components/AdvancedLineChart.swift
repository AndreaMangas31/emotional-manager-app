import SwiftUI

struct AdvancedLineChart: View {
    let data: [(Date, Double)]
    let title: String
    let factorName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            if data.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Sin datos aún")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            } else {
                // Bar chart visual
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(data.indices, id: \.self) { index in
                        let value = data[index].1
                        
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(colorForValue(value))
                                .frame(height: CGFloat(value / 10 * 140))
                            
                            Text("\(Int(value))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 180)
                .padding(.vertical, 8)
            }
            
            // Estadísticas
            HStack(spacing: 16) {
                StatItem(
                    label: "Promedio",
                    value: String(format: "%.1f", averageValue)
                )
                
                Divider()
                
                StatItem(
                    label: "Máximo",
                    value: String(Int(maxValue))
                )
                
                Divider()
                
                StatItem(
                    label: "Mínimo",
                    value: String(Int(minValue))
                )
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    private var averageValue: Double {
        guard !data.isEmpty else { return 0 }
        return data.map { $0.1 }.reduce(0, +) / Double(data.count)
    }
    
    private var maxValue: Double {
        data.map { $0.1 }.max() ?? 0
    }
    
    private var minValue: Double {
        data.map { $0.1 }.min() ?? 0
    }
    
    private func colorForValue(_ value: Double) -> Color {
        switch value {
        case 1...2:
            return .blue
        case 3...4:
            return .cyan
        case 5...6:
            return .yellow
        case 7...8:
            return .orange
        default:
            return .red
        }
    }
}

struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(.headline, design: .default))
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
    }
}

// #Preview disabled
// #Preview {
//     let sampleData: [(Date, Double)] = [
//         (Date(timeIntervalSinceNow: -604800), 6.0),
//         (Date(timeIntervalSinceNow: -518400), 5.5),
//     ]
//     
//     VStack {
//         AdvancedLineChart(
//             data: sampleData,
//             title: "Estrés - Últimos 7 días",
//             factorName: "Estrés"
//         )
//     }
//     .padding()
// }
