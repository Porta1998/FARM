import Foundation
import SwiftData

enum TransactionType: String, Codable, CaseIterable {
    case income = "income"
    case expense = "expense"
}

@Model
class Transaction: Identifiable {
    var id: UUID = UUID()
    var amount: Double
    var category: String
    var type: String // Store as String for SwiftData compatibility
    var date: Date
    var desc: String

    init(amount: Double, category: String, type: TransactionType, date: Date = Date(), desc: String = "") {
        self.amount = amount
        self.category = category
        self.type = type.rawValue
        self.date = date
        self.desc = desc
    }
}

@Model
class RecurringTransaction: Identifiable {
    var id: UUID = UUID()
    var amount: Double
    var category: String
    var type: String
    var frequency: String = "monthly"

    init(amount: Double, category: String, type: TransactionType, frequency: String = "monthly") {
        self.amount = amount
        self.category = category
        self.type = type.rawValue
        self.frequency = frequency
    }
}

@Model
class UserProfile {
    var username: String
    var initialBalance: Double
    var goalName: String?
    var goalTarget: Double?

    init(username: String, initialBalance: Double, goalName: String? = nil, goalTarget: Double? = nil) {
        self.username = username
        self.initialBalance = initialBalance
        self.goalName = goalName
        self.goalTarget = goalTarget
    }
}
