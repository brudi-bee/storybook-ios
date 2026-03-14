import SwiftUI
import SwiftData

struct ProfilesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChildProfile.order) private var children: [ChildProfile]
    
    @State private var selectedChild: ChildProfile?
    @State private var showAvatarCreation = false
    @State private var showEditSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(children) { child in
                    ChildProfileRow(child: child)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedChild = child
                            showEditSheet = true
                        }
                }
                
                if children.count < 2 {
                    AddChildButton {
                        createNewChild()
                    }
                }
            }
            .navigationTitle("Kinderprofile")
            .sheet(item: $selectedChild) { child in
                if child.hasAvatar {
                    EditProfileSheet(child: child)
                } else {
                    AvatarCreationFlowView(child: child) {
                        // Completion handler
                    }
                }
            }
        }
    }
    
    private func createNewChild() {
        let newChild = ChildProfile(
            name: "",
            gender: .neutral,
            order: children.count
        )
        modelContext.insert(newChild)
        selectedChild = newChild
    }
}

// MARK: - Child Profile Row
struct ChildProfileRow: View {
    let child: ChildProfile
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar or placeholder
            if let avatarData = child.avatarImageData,
               let uiImage = UIImage(data: avatarData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } else {
                AvatarPlaceholder(configuration: child.avatarConfiguration, name: child.name)
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(child.name.isEmpty ? "Neues Kind" : child.name)
                    .font(.headline)
                
                HStack(spacing: 4) {
                    Image(systemName: child.gender == .female ? "person.fill" : "person")
                        .font(.caption)
                    Text(child.gender.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if child.hasAvatar {
                    Label("Avatar erstellt", systemImage: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Avatar Placeholder
struct AvatarPlaceholder: View {
    let configuration: AvatarConfiguration
    let name: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            configuration.clothingColor.color.opacity(0.7),
                            configuration.skinTone.color.opacity(0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 0) {
                Text(configuration.style.emoji)
                    .font(.system(size: 24))
                if !name.isEmpty {
                    Text(name.prefix(1).uppercased())
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

// MARK: - Add Child Button
struct AddChildButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.accent)
                
                Text("Kind hinzufügen")
                    .font(.headline)
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Edit Profile Sheet
struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let child: ChildProfile
    
    @State private var name: String = ""
    @State private var gender: ChildGender = .neutral
    @State private var showAvatarEditor = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Profil") {
                    // Avatar display
                    HStack {
                        Spacer()
                        if let avatarData = child.avatarImageData,
                           let uiImage = UIImage(data: avatarData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            AvatarPlaceholder(configuration: child.avatarConfiguration, name: child.name)
                                .frame(width: 120, height: 120)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    
                    Button("Avatar bearbeiten") {
                        showAvatarEditor = true
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    
                    TextField("Name", text: $name)
                    
                    Picker("Geschlecht", selection: $gender) {
                        ForEach(ChildGender.allCases) { g in
                            Text(g.displayName).tag(g)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Avatar-Einstellungen") {
                    HStack {
                        Text("Stil")
                        Spacer()
                        Text(child.avatarStyle.displayName)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Haarfarbe")
                        Spacer()
                        Circle()
                            .fill(child.hairColor.color)
                            .frame(width: 20, height: 20)
                        Text(child.hairColor.displayName)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Hautton")
                        Spacer()
                        Circle()
                            .fill(child.skinTone.color)
                            .frame(width: 20, height: 20)
                        Text(child.skinTone.displayName)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Augenfarbe")
                        Spacer()
                        Circle()
                            .fill(child.eyeColor.color)
                            .frame(width: 20, height: 20)
                        Text(child.eyeColor.displayName)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section {
                    Button("Avatar löschen", role: .destructive) {
                        child.clearAvatar()
                    }
                }
            }
            .navigationTitle("Profil bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        saveChanges()
                    }
                }
            }
            .onAppear {
                name = child.name
                gender = child.gender
            }
            .sheet(isPresented: $showAvatarEditor) {
                AvatarCreationFlowView(child: child) {
                    // Avatar updated
                }
            }
        }
    }
    
    private func saveChanges() {
        child.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        child.genderRaw = gender.rawValue
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save: \(error)")
        }
    }
}