import SwiftUI

struct TemperatureGauge: View {
    let score: Double
    
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
    
    var temperatureLevel: Double {
        (score - 1) / 9
    }
    
    var temperatureText: String {
        switch score {
        case 1...2:
            return "Excelente"
        case 3...4:
            return "Muy bien"
        case 5...6:
            return "Neutral"
        case 7...8:
            return "Preocupante"
        default:
            return "Crítico 🔥"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Temperatura emocional")
                .font(.headline)
            
            // Termómetro visual
            VStack(spacing: 8) {
                // Bulbo del termómetro
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    temperatureColor.opacity(0.3),
                                    temperatureColor
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    VStack(spacing: 4) {
                        Text(String(format: "%.1f", score))
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("°C")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                
                // Barra de temperatura
                VStack(spacing: 6) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.cyan, .yellow, .orange, .red]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: temperatureLevel * 260)
                    }
                    .frame(height: 12)
                    
                    HStack {
                        Text("Bien")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Mal 🔥")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Estado
                Text(temperatureText)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(temperatureColor)
                    .padding(.top, 4)
            }
            
            // Animación si está en zona crítica
            if score >= 8.5 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.red)
                    Text("¡Ten cuidado de tu bienestar!")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(6)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

// #Preview disabled - requires model context
// #Preview {
//     VStack(spacing: 20) {
//         TemperatureGauge(score: 2)
//         TemperatureGauge(score: 5)
//         TemperatureGauge(score: 9)
//     }
//     .padding()
// }
