import Foundation
import Observation
import SwiftData

@Observable
class FinanceViewModel {
    var modelContext: ModelContext?

    var userProfile: UserProfile?
    var transactions: [Transaction] = []
    var recurringTransactions: [RecurringTransaction] = []

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        fetchData()
    }

    func fetchData() {
        guard let modelContext = modelContext else { return }

        let profileDescriptor = FetchDescriptor<UserProfile>()
        userProfile = (try? modelContext.fetch(profileDescriptor))?.first

        let txDescriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date)])
        transactions = (try? modelContext.fetch(txDescriptor)) ?? []

        let recurringDescriptor = FetchDescriptor<RecurringTransaction>()
        recurringTransactions = (try? modelContext.fetch(recurringDescriptor)) ?? []
    }

    // Computed Balance
    var currentBalance: Double {
        let initial = userProfile?.initialBalance ?? 0.0
        let txBalance = transactions.reduce(0) { total, tx in
            tx.type == TransactionType.income.rawValue ? total + tx.amount : total - tx.amount
        }
        return initial + txBalance
    }

    // Monthly Net from recurring
    var monthlyNet: Double {
        recurringTransactions.reduce(0) { total, rt in
            rt.type == TransactionType.income.rawValue ? total + rt.amount : total - rt.amount
        }
    }

    // 12-month projection
    var projection12M: Double {
        currentBalance + (monthlyNet * 12)
    }

    var expensesMonthly: Double {
        recurringTransactions.filter { $0.type == TransactionType.expense.rawValue }.reduce(0) { $0 + $1.amount }
    }

    var optimizedMonthlyNet: Double {
        monthlyNet + (expensesMonthly * 0.1) // 10% optimization
    }

    var optimizedProjection12M: Double {
        currentBalance + (optimizedMonthlyNet * 12)
    }

    var extraGain12M: Double {
        optimizedProjection12M - projection12M
    }

    // Methods
    func addTransaction(amount: Double, category: String, type: TransactionType) {
        let newTx = Transaction(amount: amount, category: category, type: type)
        modelContext?.insert(newTx)
        try? modelContext?.save()
        fetchData()
    }

    func addRecurring(amount: Double, category: String, type: TransactionType) {
        let newRT = RecurringTransaction(amount: amount, category: category, type: type)
        modelContext?.insert(newRT)
        try? modelContext?.save()
        fetchData()
    }

    func setupProfile(username: String, initialBalance: Double) {
        let profile = UserProfile(username: username, initialBalance: initialBalance, goalName: "Nuova Serra", goalTarget: 25000.0)
        modelContext?.insert(profile)
        try? modelContext?.save()
        fetchData()
    }

    func logout() {
        // Clear all data
        try? modelContext?.delete(model: UserProfile.self)
        try? modelContext?.delete(model: Transaction.self)
        try? modelContext?.delete(model: RecurringTransaction.self)
        try? modelContext?.save()
        userProfile = nil
        transactions = []
        recurringTransactions = []
        fetchData()
    }

    // Data for charts
    func getProjectionData() -> [(month: Int, balance: Double)] {
        var data: [(month: Int, balance: Double)] = []
        for i in 0...12 {
            data.append((month: i, balance: currentBalance + (monthlyNet * Double(i))))
        }
        return data
    }

    func getOptimizedData() -> [(month: Int, balance: Double)] {
        var data: [(month: Int, balance: Double)] = []
        for i in 0...12 {
            data.append((month: i, balance: currentBalance + (optimizedMonthlyNet * Double(i))))
        }
        return data
    }
}
