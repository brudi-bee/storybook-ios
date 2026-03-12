import SwiftUI

struct ReaderView: View {
    @EnvironmentObject var store: AppStore
    let story: Story
    @State private var sceneIndex = 0
    @State private var musicOn = true
    @State private var sleepMinutes = 0

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(story.title)
                    .font(.largeTitle.bold())
                Text("\(story.genre.displayName) · \(story.setting)")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(colors: [.blue.opacity(0.35), .purple.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 180)
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.system(size: 34))
                        Text("Dummy Bild Szene \(scene.index)")
                            .font(.footnote)
                    }
                    .foregroundStyle(.secondary)
                }

            ScrollView {
                Text(scene.text)
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
            }

            HStack {
                Button("Zurück") {
                    sceneIndex = max(0, sceneIndex - 1)
                }
                .disabled(sceneIndex == 0)

                Spacer()

                Toggle("BGM", isOn: $musicOn)
                    .toggleStyle(.switch)
                    .frame(width: 120)
                    .onChange(of: musicOn) { _, newValue in
                        store.audioManager.setEnabled(newValue)
                    }

                Spacer()

                Button("Weiter") {
                    sceneIndex = min(story.scenes.count - 1, sceneIndex + 1)
                }
                .disabled(sceneIndex >= story.scenes.count - 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Sleep Timer")
                    Spacer()
                    Picker("", selection: $sleepMinutes) {
                        Text("Aus").tag(0)
                        Text("10m").tag(10)
                        Text("20m").tag(20)
                        Text("30m").tag(30)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 240)
                }

                HStack {
                    Text("Lautstärke")
                    Slider(value: Binding(
                        get: { Double(store.audioManager.volume) },
                        set: { store.audioManager.volume = Float($0) }
                    ), in: 0...0.5)
                }
            }
        }
        .padding()
        .navigationTitle("Lesemodus")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if musicOn { store.audioManager.setEnabled(true) }
        }
        .onDisappear {
            store.audioManager.stop()
        }
        .onChange(of: sleepMinutes) { _, newValue in
            store.audioManager.setSleepTimer(minutes: newValue)
        }
    }

    private var scene: StoryScene {
        story.scenes[sceneIndex]
    }
}
