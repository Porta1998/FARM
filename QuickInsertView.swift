import SwiftUI

struct QuickInsertView: View {
    @Bindable var viewModel: FinanceViewModel
    @State private var amount: String = "0"
    @State private var selectedCategory: String = "Altro"
    @State private var type: TransactionType = .expense
    @State private var isRecurring: Bool = false

    let categories = ["Caffè", "Pranzo", "Trasporti", "Spesa", "Svago", "Altro"]

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Inserimento Rapido")
                .font(.title2.bold())
                .foregroundColor(Color(hex: "#456646"))
                .padding(.top)

            // Display Area
            VStack(alignment: .leading, spacing: 5) {
                Text("DETTAGLIO VOCE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)

                HStack(alignment: .bottom) {
                    Text("\(type == .expense ? "-" : "+")\(amount)")
                        .font(.system(size: 50, weight: .black))
                        .tracking(-2)

                    Text(selectedCategory.lowercased())
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(25)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.02), radius: 10)

            // Mode Toggle (Single vs Recurring)
            HStack(spacing: 0) {
                Button { isRecurring = false } label: {
                    Text("Singola")
                        .font(.system(size: 12, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(!isRecurring ? Color.white : Color.clear)
                        .cornerRadius(20)
                }
                Button { isRecurring = true } label: {
                    Text("Ricorrente")
                        .font(.system(size: 12, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isRecurring ? Color.white : Color.clear)
                        .cornerRadius(20)
                }
            }
            .padding(4)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(25)

            // Mode Picker (Income vs Expense)
            Picker("Tipo", selection: $type) {
                Text("Spesa").tag(TransactionType.expense)
                Text("Entrata").tag(TransactionType.income)
            }
            .pickerStyle(.segmented)

            // Categories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { cat in
                        Button {
                            selectedCategory = cat
                        } label: {
                            Text(cat.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(selectedCategory == cat ? Color(hex: "#456646") : Color.gray.opacity(0.1))
                                .foregroundColor(selectedCategory == cat ? .white : .primary)
                                .cornerRadius(10)
                        }
                    }
                }
            }

            // Keypad
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(["1", "2", "3", "4", "5", "6", "7", "8", "9", ",", "0"], id: \.self) { key in
                    Button {
                        appendKey(key)
                    } label: {
                        Text(key)
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.white)
                            .cornerRadius(15)
                    }
                }

                Button {
                    if amount.count > 1 {
                        amount.removeLast()
                    } else {
                        amount = "0"
                    }
                } label: {
                    Image(systemName: "delete.left")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.white)
                        .cornerRadius(15)
                }
            }

            // Confirm
            Button {
                let val = Double(amount.replacingOccurrences(of: ",", with: ".")) ?? 0.0
                if val > 0 {
                    if isRecurring {
                        viewModel.addRecurring(amount: val, category: selectedCategory, type: type)
                    } else {
                        viewModel.addTransaction(amount: val, category: selectedCategory, type: type)
                    }
                    amount = "0"
                }
            } label: {
                Text("CONFERMA VOCE")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#456646"))
                    .cornerRadius(30)
                    .shadow(color: Color(hex: "#456646").opacity(0.2), radius: 10, y: 5)
            }

            Spacer()
        }
        .padding(.horizontal)
        .background(Color(hex: "#faf9f6"))
    }

    func appendKey(_ key: String) {
        if amount == "0" && key != "," {
            amount = key
        } else {
            if key == "," && amount.contains(",") { return }
            amount += key
        }
    }
}
