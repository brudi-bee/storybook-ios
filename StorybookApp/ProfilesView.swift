import SwiftUI

struct ProfilesView: View {
    @EnvironmentObject var store: AppStore

    @State private var child1Name = ""
    @State private var child1Gender: ChildGender = .female
    @State private var hasSecondChild = false
    @State private var child2Name = ""
    @State private var child2Gender: ChildGender = .male

    var body: some View {
        NavigationStack {
            Form {
                Section("Kind 1") {
                    TextField("Name", text: $child1Name)
                    Picker("Geschlecht", selection: $child1Gender) {
                        ForEach(ChildGender.allCases) { g in
                            Text(g.displayName).tag(g)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Toggle("Zweites Kind hinzufügen", isOn: $hasSecondChild)
                }

                if hasSecondChild {
                    Section("Kind 2") {
                        TextField("Name", text: $child2Name)
                        Picker("Geschlecht", selection: $child2Gender) {
                            ForEach(ChildGender.allCases) { g in
                                Text(g.displayName).tag(g)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                Button("Profile speichern") {
                    store.upsertChild(index: 0, name: child1Name, gender: child1Gender)
                    if hasSecondChild {
                        store.upsertChild(index: 1, name: child2Name, gender: child2Gender)
                    } else {
                        store.removeSecondChildIfNeeded(enabled: false)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Kinderprofile")
            .onAppear {
                if let c1 = store.children.first {
                    child1Name = c1.name
                    child1Gender = c1.gender
                }
                if store.children.count > 1 {
                    let c2 = store.children[1]
                    hasSecondChild = true
                    child2Name = c2.name
                    child2Gender = c2.gender
                }
            }
        }
    }
}
