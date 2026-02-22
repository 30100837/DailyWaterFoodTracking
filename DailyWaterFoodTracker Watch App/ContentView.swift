import SwiftUI

struct CircularProgressView: View {
    var progress: Double
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.teal.opacity(0.2), lineWidth: 8)
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(Color.teal, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
            Text("\(Int(progress * 100))%")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.teal)
        }
        .frame(width: 50, height: 50)
    }
}

struct ContentView: View {
    @StateObject private var appData = AppData()
    @State private var showResetConfirm = false

    var motivationalMessage: String {
        let progress = appData.waterConsumed / appData.waterTarget
        switch progress {
        case 0..<0.25: return "Let's get started! 💪"
        case 0.25..<0.5: return "Good start! Keep going! 🌊"
        case 0.5..<0.75: return "Halfway there! ⭐"
        case 0.75..<1.0: return "Almost there! 🔥"
        default: return "Goal reached! 🎉"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {

                    Text("Daily Tracker")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Calories Card
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Calories")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Text("\(appData.totalCalories) kcal")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(LinearGradient(colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(14)

                    // Water Card
                    HStack {
                        CircularProgressView(progress: appData.waterConsumed / appData.waterTarget)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Water")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Text(String(format: "%.1f / %.1fL", appData.waterConsumed, appData.waterTarget))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.teal)
                            Text(motivationalMessage)
                                .font(.caption2)
                                .foregroundColor(.teal.opacity(0.8))
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(LinearGradient(colors: [Color.teal.opacity(0.3), Color.teal.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(14)

                    if let comparison = appData.getComparisonText() {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.green)
                                .font(.caption2)
                            Text(comparison)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                    }

                    // Log Food Button
                    NavigationLink(destination: FoodLogView(appData: appData)) {
                        Label("Log Food", systemImage: "fork.knife")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(10)
                    }

                    // Log Water Button
                    NavigationLink(destination: WaterLogView(appData: appData)) {
                        Label("Log Water", systemImage: "drop.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color.teal.opacity(0.2))
                            .foregroundColor(.teal)
                            .cornerRadius(10)
                    }

                    // Reset Button
                    Button(action: { showResetConfirm = true }) {
                        Label("Reset All", systemImage: "arrow.counterclockwise")
                            .font(.caption)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(10)
                    }
                    .alert("Reset All Data?", isPresented: $showResetConfirm) {
                        Button("Reset", role: .destructive) { appData.resetAll() }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This will reset today's calories and water to zero.")
                    }
                }
                .padding()
            }
            .background(Color.black)
            .onAppear { appData.checkReset() }
        }
    }
}
