import SwiftUI

struct FoodLogView: View {
    @ObservedObject var appData: AppData
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("Log Food")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                ForEach([100, 200, 300, 400, 500], id: \.self) { amount in
                    Button(action: {
                        appData.addCalories(amount)
                        dismiss()
                    }) {
                        Text("+\(amount) kcal")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.3))
                            .foregroundColor(.orange)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .background(Color.black)
    }
}
