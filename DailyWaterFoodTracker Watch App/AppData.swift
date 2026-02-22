import SwiftUI
import Foundation
import Combine

class AppData: ObservableObject {
    @Published var totalCalories: Int = 0
    @Published var waterConsumed: Double = 0.0
    @Published var waterTarget: Double = 2.5
    @Published var previousDayCalories: Int = 0
    @Published var previousDayWater: Double = 0.0
    @Published var foodEntries: [FoodEntry] = []

    private let caloriesKey = "totalCalories"
    private let waterKey = "waterConsumed"
    private let targetKey = "waterTarget"
    private let lastResetKey = "lastResetDate"
    private let previousCaloriesKey = "previousDayCalories"
    private let previousWaterKey = "previousDayWater"
    private let foodEntriesKey = "foodEntries"

    init() { loadData() }

    func loadData() {
        totalCalories = UserDefaults.standard.integer(forKey: caloriesKey)
        waterConsumed = UserDefaults.standard.double(forKey: waterKey)
        waterTarget = UserDefaults.standard.double(forKey: targetKey)
        previousDayCalories = UserDefaults.standard.integer(forKey: previousCaloriesKey)
        previousDayWater = UserDefaults.standard.double(forKey: previousWaterKey)
        if waterTarget == 0.0 { waterTarget = 2.5 }
        if let data = UserDefaults.standard.data(forKey: foodEntriesKey),
           let decoded = try? JSONDecoder().decode([FoodEntry].self, from: data) {
            foodEntries = decoded
        }
    }

    private func saveCalories() { UserDefaults.standard.set(totalCalories, forKey: caloriesKey) }
    private func saveWater() { UserDefaults.standard.set(waterConsumed, forKey: waterKey) }
    private func saveTarget() { UserDefaults.standard.set(waterTarget, forKey: targetKey) }
    private func savePreviousDay() {
        UserDefaults.standard.set(previousDayCalories, forKey: previousCaloriesKey)
        UserDefaults.standard.set(previousDayWater, forKey: previousWaterKey)
    }
    private func saveFoodEntries() {
        if let encoded = try? JSONEncoder().encode(foodEntries) {
            UserDefaults.standard.set(encoded, forKey: foodEntriesKey)
        }
    }

    func addCalories(_ calories: Int, category: String = "Meal") {
        DispatchQueue.main.async {
            self.totalCalories += calories
            self.foodEntries.append(FoodEntry(id: UUID(), calories: calories, category: category, timestamp: Date()))
            self.saveCalories()
            self.saveFoodEntries()
        }
    }

    func addWater(_ amount: Double) {
        DispatchQueue.main.async {
            self.waterConsumed += amount
            self.saveWater()
        }
    }

    func setTarget(_ target: Double) {
        DispatchQueue.main.async {
            self.waterTarget = target
            self.saveTarget()
        }
    }

    func resetAll() {
        DispatchQueue.main.async {
            self.previousDayCalories = self.totalCalories
            self.previousDayWater = self.waterConsumed
            self.savePreviousDay()
            self.totalCalories = 0
            self.waterConsumed = 0.0
            self.foodEntries = []
            self.saveCalories()
            self.saveWater()
            self.saveFoodEntries()
            UserDefaults.standard.set(Date(), forKey: self.lastResetKey)
        }
    }

    func checkReset() {
        let lastReset = UserDefaults.standard.object(forKey: lastResetKey) as? Date ?? Date.distantPast
        if !Calendar.current.isDateInToday(lastReset) { resetAll() }
    }

    func getComparisonText() -> String? {
        guard previousDayCalories > 0 || previousDayWater > 0 else { return nil }
        let calorieDiff = totalCalories - previousDayCalories
        let waterDiff = waterConsumed - previousDayWater
        var components: [String] = []
        if abs(calorieDiff) > 0 { components.append("\(calorieDiff > 0 ? "+" : "")\(calorieDiff) cal vs yesterday") }
        if abs(waterDiff) > 0.1 { components.append("\(waterDiff > 0 ? "+" : "")\(String(format: "%.1f", waterDiff))L water") }
        return components.isEmpty ? nil : components.joined(separator: " • ")
    }
}

struct FoodEntry: Codable, Identifiable {
    let id: UUID
    let calories: Int
    let category: String
    let timestamp: Date

    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}
