import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var showingAddFactor = false
    @State private var showingTimePickerSheet = false
    @State private var newFactorName = ""
    @State private var selectedHour = 20
    @State private var selectedMinute = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                Form {
                    // MARK: - Notificaciones
                    Section(header: Text("Recordatorios diarios")) {
                        Toggle(isOn: Binding(
                            get: { viewModel.notificationSettings.isEnabled },
                            set: { isOn in
                                Task { await viewModel.toggleNotifications(isOn) }
                            }
                        )) {
                            Label("Habilitar recordatorios", systemImage: "bell.fill")
                        }
                        
                        if viewModel.notificationSettings.isEnabled {
                            TimePickerButton(
                                hour: viewModel.notificationSettings.hour,
                                minute: viewModel.notificationSettings.minute,
                                action: { showingTimePickerSheet = true }
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                        }
                    }
                    
                    // MARK: - Factores
                    Section(header: Text("Factores emocionales")) {
                        ForEach(viewModel.factors) { factor in
                            HStack {
                                Text(factor.name)
                                
                                if factor.isCustom {
                                    Spacer()
                                    
                                    Button(action: {
                                        Task { await viewModel.deleteFactor(factor) }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                            
                            TextField("Nuevo factor", text: $newFactorName)
                                .onSubmit {
                                    if !newFactorName.trimmingCharacters(in: .whitespaces).isEmpty {
                                        Task { await viewModel.addFactor(newFactorName) }
                                        newFactorName = ""
                                    }
                                }
                        }
                    }
                    
                    // MARK: - Info
                    Section(header: Text("Acerca de")) {
                        HStack {
                            Text("Versión")
                            Spacer()
                            Text("1.0")
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Herramienta personal de autoevaluación emocional")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Status messages
                if let successMessage = viewModel.successMessage {
                    VStack {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            
                            Text(successMessage)
                                .font(.caption)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                        .padding()
                        
                        Spacer()
                    }
                    .transition(.move(edge: .top))
                    .onAppear {
                        Task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            await MainActor.run {
                                withAnimation {
                                    viewModel.successMessage = nil
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingTimePickerSheet) {
                TimePickerSheet(
                    hour: $selectedHour,
                    minute: $selectedMinute,
                    onConfirm: {
                        Task {
                            await viewModel.updateNotificationTime(hour: selectedHour, minute: selectedMinute)
                            showingTimePickerSheet = false
                        }
                    }
                )
            }
            .onAppear {
                selectedHour = viewModel.notificationSettings.hour
                selectedMinute = viewModel.notificationSettings.minute
                viewModel.loadFactors()
            }
        }
    }
}

struct TimePickerSheet: View {
    @Binding var hour: Int
    @Binding var minute: Int
    var onConfirm: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    VStack(spacing: 12) {
                        Text("Hora")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("Hora", selection: $hour) {
                            ForEach(0..<24, id: \.self) { h in
                                Text(String(format: "%02d", h)).tag(h)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 150)
                    }
                    
                    VStack(spacing: 12) {
                        Text("Minuto")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("Minuto", selection: $minute) {
                            ForEach(0..<60, id: \.self) { m in
                                Text(String(format: "%02d", m)).tag(m)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 150)
                    }
                }
                .padding()
                
                Button(action: onConfirm) {
                    Text("Confirmar")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Seleccionar hora")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
        }
    }
}

// #Preview disabled - requires SwiftData context
// #Preview {
//     SettingsView()
// }
