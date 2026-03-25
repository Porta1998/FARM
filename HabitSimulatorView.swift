import SwiftUI
import Charts

struct HabitSimulatorView: View {
    @Bindable var viewModel: FinanceViewModel
    @State private var coffeeSavings: Double = 40
    @State private var smokingReduction: Bool = true
    @State private var takeAwaySavings: Double = 80

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // Header
                VStack(alignment: .leading, spacing: 5) {
                    Text("PROIEZIONE RISPARMIO")
                        .font(.caption.bold())
                        .foregroundColor(Color(hex: "#456646").opacity(0.6))
                    Text("Il tuo futuro finanziario")
                        .font(.title.bold())
                }

                // Comparison Chart Card
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Saldo tra 12 mesi")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            Text("€\(String(format: "%.2f", viewModel.projection12M))")
                                .font(.system(size: 32, weight: .black))
                        }
                        Spacer()
                        Text("+€3.200")
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "#c6edc4"))
                            .cornerRadius(20)
                    }

                    Chart {
                        ForEach(viewModel.getProjectionData(), id: \.month) { item in
                            LineMark(
                                x: .value("Mese", item.month),
                                y: .value("Saldo", item.balance)
                            )
                            .foregroundStyle(.secondary.opacity(0.3))
                        }

                        ForEach(viewModel.getOptimizedData(), id: \.month) { item in
                            LineMark(
                                x: .value("Mese", item.month),
                                y: .value("Saldo", item.balance)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(Color(hex: "#456646"))
                            .lineStyle(StrokeStyle(lineWidth: 4))

                            AreaMark(
                                x: .value("Mese", item.month),
                                y: .value("Saldo", item.balance)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(LinearGradient(colors: [Color(hex: "#456646").opacity(0.1), .clear], startPoint: .top, endPoint: .bottom))
                        }
                    }
                    .frame(height: 150)
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                }
                .padding(25)
                .background(Color(hex: "#edeeea").opacity(0.5))
                .cornerRadius(25)

                Text("Simulatore Abitudini")
                    .font(.title3.bold())

                // Habit Cards
                VStack(spacing: 15) {
                    HabitCard(icon: "coffee.fill", title: "Caffè fuori", subtitle: "€ 1,20 per tazza", value: $coffeeSavings)

                    // Tobacco Toggle
                    VStack(alignment: .leading) {
                        HStack {
                            ZStack {
                                Circle().fill(Color.white).frame(width: 45)
                                Image(systemName: "smoke.fill").foregroundColor(Color(hex: "#456646"))
                            }
                            VStack(alignment: .leading) {
                                Text("Tabacco").bold()
                                Text("€ 6,00 per pacchetto").font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $smokingReduction)
                                .tint(Color(hex: "#456646"))
                        }
                        .padding()
                        .background(Color(hex: "#edeeea").opacity(0.5))
                        .cornerRadius(20)
                    }

                    HabitCard(icon: "bag.fill", title: "Cibo d'asporto", subtitle: "Spesa media € 15,00", value: $takeAwaySavings)
                }

                Button {
                    // Apply strategy
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Applica Strategia di Crescita")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#456646"))
                    .cornerRadius(30)
                }

                Text("I fondi risparmiati verranno allocati nel Portafoglio Crescita")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
        }
        .background(Color(hex: "#faf9f6"))
    }
}

struct HabitCard: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                ZStack {
                    Circle().fill(Color.white).frame(width: 45)
                    Image(systemName: icon).foregroundColor(Color(hex: "#456646"))
                }
                VStack(alignment: .leading) {
                    Text(title).bold()
                    Text(subtitle).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Text("3 DIE").font(.caption.bold()).padding(6).background(Color.white).cornerRadius(10)
            }

            Slider(value: $value, in: 0...100)
                .tint(Color(hex: "#456646"))

            HStack {
                Text("RIDUCI").font(.system(size: 8, weight: .bold)).foregroundColor(.secondary)
                Spacer()
                Text("MANTENERE").font(.system(size: 8, weight: .bold)).foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(hex: "#edeeea").opacity(0.5))
        .cornerRadius(20)
    }
}
