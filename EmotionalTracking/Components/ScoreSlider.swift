import SwiftUI

struct ScoreSlider: View {
    let label: String
    let factorId: UUID
    @Binding var score: Int
    var onScoreChange: (Int) -> Void = { _ in }
    
    var temperatureColor: Color {
        switch score {
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(label)
                    .font(.system(.body, design: .default))
                    .fontWeight(.medium)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(temperatureColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text("\(score)")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(temperatureColor)
                }
            }
            
            Slider(value: Binding(
                get: { Double(score) },
                set: { newValue in
                    score = Int(newValue)
                    onScoreChange(score)
                }
            ), in: 1...10, step: 1)
                .tint(temperatureColor)
            
            HStack {
                Text("Muy bueno")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Muy malo")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

#Preview {
    @State var score = 5
    return ScoreSlider(label: "Soledad", factorId: UUID(), score: $score)
        .padding()
}
