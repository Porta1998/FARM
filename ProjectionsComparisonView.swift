import SwiftUI
import Charts

struct ProjectionsComparisonView: View {
    let viewModel: FinanceViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Confronto Proiezioni")
                    .font(.system(size: 48, weight: .black))
                    .tracking(-2)

                Text("Visualizza l'impatto delle tue scelte sul tuo futuro finanziario a 12 mesi.")
                    .foregroundColor(.secondary)

                // Big Comparison Chart
                VStack(alignment: .leading) {
                    Chart {
                        ForEach(viewModel.getProjectionData(), id: \.month) { item in
                            LineMark(
                                x: .value("Mese", item.month),
                                y: .value("Saldo", item.balance)
                            )
                            .foregroundStyle(.secondary.opacity(0.4))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        }

                        ForEach(viewModel.getOptimizedData(), id: \.month) { item in
                            LineMark(
                                x: .value("Mese", item.month),
                                y: .value("Saldo", item.balance)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(Color(hex: "#456646"))
                            .lineStyle(StrokeStyle(lineWidth: 4))
                        }
                    }
                    .frame(height: 250)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.02), radius: 10)

                // Cards
                VStack(spacing: 20) {
                    ComparisonCard(title: "Traiettoria Attuale", amount: viewModel.projection12M, subtitle: "Basata sulle abitudini odierne", isPrimary: false)

                    // Extra Gain
                    Text("+€\(String(format: "%.2f", viewModel.extraGain12M)) EXTRA")
                        .font(.caption.bold())
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(hex: "#456646"))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .offset(y: 10)
                        .zIndex(1)

                    ComparisonCard(title: "Traiettoria Ottimizzata", amount: viewModel.optimizedProjection12M, subtitle: "Strategia Growth Bloom", isPrimary: true)
                }
            }
            .padding()
        }
        .background(Color(hex: "#faf9f6"))
    }
}

struct ComparisonCard: View {
    let title: String
    let amount: Double
    let subtitle: String
    let isPrimary: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isPrimary ? Color(hex: "#456646") : .secondary)
                    Text(subtitle)
                        .font(.headline)
                }
                Spacer()
                Image(systemName: isPrimary ? "arrow.up.right" : "arrow.right")
                    .foregroundColor(isPrimary ? Color(hex: "#456646") : .secondary)
            }

            VStack(alignment: .leading) {
                Text("Proiezione a 12 mesi")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                    .italic()
                Text("€\(String(format: "%.2f", amount))")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(isPrimary ? Color(hex: "#456646") : .primary)
            }
        }
        .padding(30)
        .background(isPrimary ? Color(hex: "#c6edc4").opacity(0.4) : Color(hex: "#edeeea").opacity(0.5))
        .cornerRadius(25)
    }
}
