import SwiftUI

struct DailyEntryView: View {
    @State private var viewModel = DailyEntryViewModel()
    @FocusState private var notesFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                        Text("Cargando...")
                            .padding(.top)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Header
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Hoy")
                                    .font(.system(size: 32, weight: .bold))
                                
                                if let entry = viewModel.todayEntry {
                                    Text(entry.date.formattedDate)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 16)
                            
                            // Sliders para cada factor
                            VStack(spacing: 12) {
                                ForEach(viewModel.factors) { factor in
                                    ScoreSlider(
                                        label: factor.name,
                                        factorId: factor.id,
                                        score: .init(
                                            get: { viewModel.getScore(for: factor.id) },
                                            set: { viewModel.updateScore($0, for: factor.id) }
                                        ),
                                        onScoreChange: { score in
                                            viewModel.updateScore(score, for: factor.id)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                            
                            // Temperatura emocional
                            if let entry = viewModel.todayEntry, entry.averageScore > 0 {
                                TemperatureGauge(score: entry.averageScore)
                                    .padding(.horizontal)
                            }
                            
                            // Notas opcional
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notas (opcional)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextEditor(text: .init(
                                    get: { viewModel.todayEntry?.notes ?? "" },
                                    set: { viewModel.setNotes($0) }
                                ))
                                .frame(height: 80)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.05))
                                )
                                .focused($notesFieldFocused)
                            }
                            .padding(.horizontal)
                            
                            // Status
                            if let errorMessage = viewModel.errorMessage {
                                HStack {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                    
                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            } else {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    
                                    Text("Registro guardado automáticamente")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                            
                            Spacer(minLength: 30)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadTodayEntry()
            }
        }
    }
    
    private func colorForAverage(_ score: Double) -> Color {
        // Escala invertida: 1-3 = bueno (verde), 8-10 = malo (rojo)
        switch score {
        case 1...3:
            return .green
        case 4...5:
            return .blue
        case 6...7:
            return .orange
        default:
            return .red
        }
    }
    
    
    // #Preview disabled - requires SwiftData context
    // #Preview {
    //     DailyEntryView()
    // }
}
