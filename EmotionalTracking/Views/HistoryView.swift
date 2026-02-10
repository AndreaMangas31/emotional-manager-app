import SwiftUI

struct HistoryView: View {
    @State private var viewModel = HistoryViewModel()
    @State private var selectedDate: Date?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.entries.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Sin registros")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Completa tu primer registro para ver el historial")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.entries) { entry in
                            NavigationLink(destination: EntryDetailView(entry: entry, viewModel: viewModel, factors: viewModel.factors)) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(entry.date.formattedDate)
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "heart.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.red)
                                            
                                            Text(String(format: "%.1f", entry.averageScore))
                                                .font(.system(.callout, design: .default))
                                                .fontWeight(.semibold)
                                        }
                                    }
                                    
                                    HStack(spacing: 12) {
                                        ForEach(Array(entry.factorScores.prefix(3)), id: \.key) { factorId, score in
                                            VStack(spacing: 2) {
                                                Text(viewModel.getFactorName(for: factorId))
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                                
                                                Text("\(score)")
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.accentColor)
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                        
                                        if entry.factorScores.count > 3 {
                                            VStack(spacing: 2) {
                                                Text(" ")
                                                    .font(.caption2)
                                                
                                                Text("+\(entry.factorScores.count - 3)")
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .onDelete(perform: deleteEntry)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Historial")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadData()
            }
        }
    }
    
    private func deleteEntry(at offsets: IndexSet) {
        for index in offsets {
            let entry = viewModel.entries[index]
            viewModel.deleteEntry(entry)
        }
    }
}

struct EntryDetailView: View {
    let entry: DailyEntry
    let viewModel: HistoryViewModel
    let factors: [EmotionalFactor]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.date.formattedDate)
                            .font(.system(size: 24, weight: .bold))
                        
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            
                            Text(String(format: "Promedio: %.1f", entry.averageScore))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.05))
                    )
                    
                    VStack(spacing: 12) {
                        Text("Detalles")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(factors) { factor in
                            if let score = entry.getScore(for: factor.id) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(factor.name)
                                            .font(.body)
                                        
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.gray.opacity(0.2))
                                            
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(colorForScore(score))
                                                .frame(width: (Double(score) / 10) * 200)
                                        }
                                        .frame(height: 6)
                                    }
                                    
                                    Text("\(score)")
                                        .font(.system(.title3, design: .default))
                                        .fontWeight(.bold)
                                        .frame(width: 40, alignment: .trailing)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.05))
                    )
                    
                    if !entry.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notas")
                                .font(.headline)
                            
                            Text(entry.notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.05))
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Detalles del registro")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func colorForScore(_ score: Int) -> Color {
        // Escala invertida: 1-3 = bueno (verde), 8-10 = malo (rojo)
        switch score {
        case 1...3:
            return .green.opacity(0.7)
        case 4...5:
            return .blue.opacity(0.7)
        case 6...7:
            return .orange.opacity(0.7)
        default:
            return Color.red.opacity(0.7)
        }
    }
}

// #Preview disabled - requires SwiftData context
// #Preview {
//     HistoryView()
// }
