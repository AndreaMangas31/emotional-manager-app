import SwiftUI

struct StatisticCard: View {
    let label: String
    let value: Double
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                    .font(.system(size: 18))
                
                Spacer()
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(String(format: "%.1f", value))
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

#Preview {
    StatisticCard(label: "Promedio últimos 7 días", value: 7.5, icon: "chart.bar.fill")
        .padding()
}
