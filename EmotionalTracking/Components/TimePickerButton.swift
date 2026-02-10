import SwiftUI

struct TimePickerButton: View {
    let hour: Int
    let minute: Int
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.accentColor)
                
                Text(String(format: "%02d:%02d", hour, minute))
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
        }
        .foregroundColor(.primary)
    }
}

#Preview {
    TimePickerButton(hour: 20, minute: 30, action: {})
        .padding()
}
