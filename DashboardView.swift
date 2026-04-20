import SwiftUI
import Charts

struct DashboardView: View {
    @Bindable var viewModel: FinanceViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("SALDO ATTUALE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                        Text("€\(String(format: "%.2f", viewModel.currentBalance))")
                            .font(.system(size: 48, weight: .black))
                    }
                    Spacer()

                    Button {
                        viewModel.logout()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(Color(hex: "#456646"))
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 5)
                    }
                }

                // Mini Chart
                VStack(alignment: .leading) {
                    Text("Andamento Proiettato")
                        .font(.headline)
                    Chart {
                        ForEach(viewModel.getProjectionData(), id: \.month) { item in
                            LineMark(
                                x: .value("Mese", item.month),
                                y: .value("Saldo", item.balance)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(Color(hex: "#456646"))

                            AreaMark(
                                x: .value("Mese", item.month),
                                y: .value("Saldo", item.balance)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(LinearGradient(colors: [Color(hex: "#456646").opacity(0.1), .clear], startPoint: .top, endPoint: .bottom))
                        }
                    }
                    .frame(height: 120)
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                }
                .padding()
                .background(Color(hex: "#edeeea").opacity(0.5))
                .cornerRadius(20)

                // Saving Goal
                if let goalName = viewModel.userProfile?.goalName, let goalTarget = viewModel.userProfile?.goalTarget {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("OBIETTIVO DI RISPARMIO")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "#456646"))

                        Text(goalName)
                            .font(.title2.bold())

                        let progress = viewModel.currentBalance / goalTarget
                        ProgressView(value: min(progress, 1.0))
                            .tint(Color(hex: "#456646"))

                        HStack {
                            Text("\(Int(progress * 100))%")
                                .font(.title.bold())
                                .foregroundColor(Color(hex: "#456646"))
                            Spacer()
                            Text("€\(Int(viewModel.currentBalance)) / €\(Int(goalTarget))")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(25)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.03), radius: 10)
                }

                // Growth Forecasts
                VStack(alignment: .leading, spacing: 15) {
                    Text("Previsione di Crescita")
                        .font(.title3.bold())

                    HStack(spacing: 15) {
                        ForecastCard(title: "1 Mese", amount: viewModel.monthlyNet, color: Color(hex: "#456646"), bgColor: .white)
                        ForecastCard(title: "6 Mesi", amount: viewModel.monthlyNet * 6, color: Color(hex: "#456646"), bgColor: .white)
                        ForecastCard(title: "12 Mesi", amount: viewModel.monthlyNet * 12, color: .white, bgColor: Color(hex: "#456646"))
                    }
                }

                // Recent Activity
                VStack(alignment: .leading, spacing: 15) {
                    Text("Attività Recenti")
                        .font(.title3.bold())

                    ForEach(viewModel.transactions.reversed().prefix(5)) { tx in
                        HStack {
                            ZStack {
                                Circle().fill(Color.gray.opacity(0.1)).frame(width: 40)
                                Image(systemName: tx.type == TransactionType.income.rawValue ? "arrow.up" : "cart.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(tx.type == TransactionType.income.rawValue ? Color(hex: "#456646") : .primary)
                            }
                            VStack(alignment: .leading) {
                                Text(tx.category)
                                    .font(.subheadline.bold())
                                Text(tx.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(tx.type == TransactionType.income.rawValue ? "+" : "-")€\(String(format: "%.2f", tx.amount))")
                                .font(.subheadline.bold())
                                .foregroundColor(tx.type == TransactionType.income.rawValue ? Color(hex: "#456646") : .primary)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                    }
                }
            }
            .padding()
        }
        .background(Color(hex: "#faf9f6"))
    }
}

struct ForecastCard: View {
    let title: String
    let amount: Double
    let color: Color
    let bgColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(color.opacity(0.6))

            Text("€\(Int(amount))")
                .font(.system(size: 16, weight: .black))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(bgColor)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.02), radius: 5)
    }
}
