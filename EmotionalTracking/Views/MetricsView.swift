import SwiftUI

struct MetricsView: View {
    @State private var viewModel = MetricsViewModel()
    @State private var selectedPeriod: TimePeriod = .sevenDays
    
    enum TimePeriod {
        case sevenDays
        case thirtyDays
    }
    
    var selectedData: [DailyEntry] {
        switch selectedPeriod {
        case .sevenDays:
            return viewModel.lastSevenDaysEntries
        case .thirtyDays:
            return viewModel.lastThirtyDaysEntries
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Period selector
                            Picker("Período", selection: $selectedPeriod) {
                                Text("Últimos 7 días").tag(TimePeriod.sevenDays)
                                Text("Últimos 30 días").tag(TimePeriod.thirtyDays)
                            }
                            .pickerStyle(.segmented)
                            .padding()
                            
                            if selectedData.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "chart.bar")
                                        .font(.system(size: 48))
                                        .foregroundColor(.gray.opacity(0.5))
                                    
                                    Text("Sin datos suficientes")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 40)
                            } else {
                                VStack(spacing: 16) {
                                    // Overall Average
                                    VStack(spacing: 8) {
                                        Text("Promedio emocional")
                                            .font(.headline)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        HStack(alignment: .center, spacing: 16) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.accentColor.opacity(0.1))
                                                
                                                VStack {
                                                    Text(String(format: "%.1f", viewModel.getOverallAverage(for: selectedData)))
                                                        .font(.system(size: 28, weight: .bold))
                                                    
                                                    Text("/ 10")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            .frame(width: 100, height: 100)
                                            
                                            VStack(alignment: .leading, spacing: 12) {
                                                StatisticCard(
                                                    label: "Más alto",
                                                    value: Double(selectedData.compactMap { $0.averageScore }.max() ?? 0),
                                                    icon: "arrow.up"
                                                )
                                                
                                                StatisticCard(
                                                    label: "Más bajo",
                                                    value: Double(selectedData.compactMap { $0.averageScore }.min() ?? 0),
                                                    icon: "arrow.down"
                                                )
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.05))
                                    )
                                    
                                    Divider()
                                        .padding(.vertical, 8)
                                    
                                    // Factors Analysis
                                    Text("Por factor")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                    
                                    ForEach(viewModel.factors) { factor in
                                        let trendData = viewModel.getTrendData(for: factor.id)
                                        
                                        AdvancedLineChart(
                                            data: trendData.map { ($0.0, Double($0.1)) },
                                            title: factor.name,
                                            factorName: factor.name
                                        )
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Métricas")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadData()
            }
        }
    }
}

// #Preview disabled - requires SwiftData context
// #Preview {
//     MetricsView()
// }
