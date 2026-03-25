# FARM App - SwiftUI & SwiftData

L'intera applicazione è stata migrata in **SwiftUI** con supporto alla persistenza locale tramite **SwiftData** (basato su SQLite).

### Caratteristiche Implementate:
1. **Persistenza (SQL Locale)**: Tutti i dati (profilo, transazioni, flussi ricorrenti) vengono salvati sul dispositivo.
2. **Dashboard Dinamica**: Visualizza il saldo reale calcolato dalla somma del budget iniziale e delle transazioni.
3. **Grafici in tempo reale**: Utilizzo di `Swift Charts` per mostrare la traiettoria del patrimonio nei prossimi 12 mesi.
4. **Inserimento Rapido**: Tastiera numerica custom con feedback immediato sull'impatto annuale della spesa/entrata.
5. **Simulatore Abitudini**: Slider interattivi per simulare risparmi futuri.
6. **Gestione Sessione**: Funzione di Logout per resettare tutti i dati locali.

### Come utilizzare il codice in Xcode:

1. **Crea un nuovo progetto**: In Xcode, seleziona "App" e scegli "SwiftUI" e **"SwiftData"** come Storage.
2. **Copia i file**:
   - `Models.swift`: Classi `@Model` per il database.
   - `FinanceViewModel.swift`: Logica di business e gestione dati.
   - `MainTabView.swift`: Root view con TabBar.
   - `OnboardingView.swift`, `DashboardView.swift`, `QuickInsertView.swift`, `HabitSimulatorView.swift`, `ProjectionsComparisonView.swift`: Le varie schermate dell'app.
3. **Configura App Context**: Nel file principale della tua app (es. `FARMApp.swift`), assicurati di aggiungere il modifier `.modelContainer`:

```swift
import SwiftUI
import SwiftData

@main
struct FARMApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [Transaction.self, RecurringTransaction.self, UserProfile.self])
    }
}
```

### Navigazione:
L'app utilizza un menù a tab inferiore per navigare tra Dashboard, Inserimento, Simulatore e Analisi della Crescita.
