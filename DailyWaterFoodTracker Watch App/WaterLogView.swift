import SwiftUI

struct WaterLogView: View {
    @ObservedObject var appData: AppData
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("Log Water")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { amount in
                    Button(action: {
                        appData.addWater(amount)
                        dismiss()
                    }) {
                        Text("+\(Int(amount * 1000)) ml")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(Color.teal.opacity(0.3))
                            .foregroundColor(.teal)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .background(Color.black)
    }
}
