import SwiftUI

struct OnboardingView: View {
    @Bindable var viewModel: FinanceViewModel
    @State private var username: String = ""
    @State private var step: Int = 0
    @State private var balanceInput: String = ""

    var body: some View {
        ZStack {
            Color(hex: "#faf9f6").ignoresSafeArea()

            VStack(spacing: 30) {
                if step == 0 {
                    // Welcome
                    VStack(spacing: 20) {
                        Text("Benvenuto in FARM")
                            .font(.system(size: 40, weight: .bold))
                            .multilineTextAlignment(.center)

                        TextField("Come ti chiami?", text: $username)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.05), radius: 5)
                            .padding(.horizontal)

                        Button {
                            withAnimation { step = 1 }
                        } label: {
                            Text("Inizia")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "#456646"))
                                .cornerRadius(30)
                        }
                        .padding(.horizontal)
                        .disabled(username.isEmpty)
                    }
                } else if step == 1 {
                    // Initial Balance
                    VStack(spacing: 20) {
                        Text("Quanto hai in banca oggi?")
                            .font(.system(size: 30, weight: .bold))
                            .multilineTextAlignment(.center)

                        HStack {
                            Text("€")
                                .font(.system(size: 40, weight: .light))
                            TextField("0", text: $balanceInput)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 60, weight: .bold))
                                .fixedSize()
                        }

                        Button {
                            let bal = Double(balanceInput.replacingOccurrences(of: ",", with: ".")) ?? 0.0
                            viewModel.setupProfile(username: username, initialBalance: bal)
                        } label: {
                            Text("Vai alla Dashboard")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "#456646"))
                                .cornerRadius(30)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
    }
}

// Utility to handle Hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
