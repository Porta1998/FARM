import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: FinanceViewModel?
    @State private var selectedTab: Int = 0

    var body: some View {
        Group {
            if let vm = viewModel {
                if vm.userProfile == nil {
                    OnboardingView(viewModel: vm)
                } else {
                    TabView(selection: $selectedTab) {
                        DashboardView(viewModel: vm)
                            .tabItem {
                                Label("Dashboard", systemImage: "house.fill")
                            }
                            .tag(0)

                        QuickInsertView(viewModel: vm)
                            .tabItem {
                                Label("Inserimento", systemImage: "plus.circle.fill")
                            }
                            .tag(1)

                        HabitSimulatorView(viewModel: vm)
                            .tabItem {
                                Label("Simulatore", systemImage: "chart.line.uptrend.xyaxis")
                            }
                            .tag(2)

                        ProjectionsComparisonView(viewModel: vm)
                            .tabItem {
                                Label("Crescita", systemImage: "arrow.up.forward.app.fill")
                            }
                            .tag(3)
                    }
                    .tint(Color(hex: "#456646"))
                }
            } else {
                ProgressView()
                    .onAppear {
                        viewModel = FinanceViewModel(modelContext: modelContext)
                    }
            }
        }
    }
}
