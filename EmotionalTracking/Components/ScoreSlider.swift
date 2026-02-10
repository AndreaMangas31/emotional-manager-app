import SwiftUI

struct ScoreSlider: View {
    let label: String
    let factorId: UUID
    @Binding var score: Int
    var onScoreChange: (Int) -> Void = { _ in }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(label)
                    .font(.system(.body, design: .default))
                    .fontWeight(.medium)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Text("\(score)")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(.accentColor)
                }
            }
            
            Slider(value: Binding(
                get: { Double(score) },
                set: { newValue in
                    score = Int(newValue)
                    onScoreChange(score)
                }
            ), in: 1...10, step: 1)
                .tint(.accentColor)
            
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
