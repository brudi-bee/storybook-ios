import SwiftUI

struct ParentalSettingsView: View {
    @EnvironmentObject var store: SDAppStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Sicherheit") {
                    Toggle("Content Filter aktiv", isOn: Binding(
                        get: { store.settings?.contentFilteringEnabled ?? true },
                        set: { store.settings?.contentFilteringEnabled = $0 }
                    ))
                    
                    Text("Geschichten werden auf kindgerechte Inhalte geprüft.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Section("Tageslimits") {
                    Stepper("Max. Geschichten pro Tag: \(store.settings?.maxDailyStories ?? 10)", value: Binding(
                        get: { store.settings?.maxDailyStories ?? 10 },
                        set: { store.settings?.maxDailyStories = $0 }
                    ), in: 0...50)
                    
                    Text("0 = Unbegrenzt")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let used = store.settings?.dailyStoryCountUsed,
                       let max = store.settings?.maxDailyStories,
                       max > 0 {
                        ProgressView(value: Double(used), total: Double(max))
                            .tint(used > max ? .red : .green)
                        
                        Text("Heute erstellt: \(used) von \(max)")
                            .font(.caption)
                    }
                }
                
                Section("Speicher") {
                    Stepper("Max. gespeicherte Geschichten: \(store.settings?.maxStoriesToKeep ?? 50)", value: Binding(
                        get: { store.settings?.maxStoriesToKeep ?? 50 },
                        set: { store.settings?.maxStoriesToKeep = $0 }
                    ), in: 10...200)
                    
                    Text("Älteste werden automatisch gelöscht.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Section("Standardwerte") {
                    Toggle("Musik standardmäßig an", isOn: Binding(
                        get: { store.settings?.musicDefaultOn ?? true },
                        set: { store.settings?.musicDefaultOn = $0 }
                    ))
                    
                    Picker("Sprache", selection: Binding(
                        get: { store.settings?.defaultLanguage ?? .de },
                        set: { store.settings?.defaultLanguage = $0 }
                    )) {
                        ForEach(StoryLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                }
            }
            .navigationTitle("Elternbereich")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ParentalSettingsView()
        .environmentObject(SDAppStore())
}
