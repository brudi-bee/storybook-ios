import Foundation
import AVFoundation

// MARK: - BGM Moods
enum BGMood: String, CaseIterable {
    case calm = "calm"
    case happy = "happy"
    case tense = "tense"
    case peaceful = "peaceful"
    
    var displayName: String {
        switch self {
        case .calm: return "Sanft"
        case .happy: return "Fröhlich"
        case .tense: return "Spannend"
        case .peaceful: return "Friedlich"
        }
    }
    
    var folder: String {
        return rawValue
    }
    
    var fileNames: [String] {
        switch self {
        case .calm:
            return ["bgm_calm_01", "bgm_calm_02", "bgm_calm_03"]
        case .happy:
            return ["bgm_happy_01", "bgm_happy_02"]
        case .peaceful:
            return ["bgm_peaceful_01", "bgm_peaceful_02"]
        case .tense:
            return ["bgm_tense_01"]
        }
    }
}

// MARK: - Sound Effects
enum SoundEffect: String {
    case pageTurn = "page_turn"
    case success = "success"
    case magic = "magic"
    case buttonTap = "button_tap"
    
    var fileName: String {
        return rawValue
    }
}

// MARK: - Audio Manager
@MainActor
final class AudioManager: ObservableObject {
    @Published var isPlaying = false
    @Published var volume: Float = 0.3 {
        didSet { 
            backgroundPlayer?.volume = volume
        }
    }
    @Published var currentMood: BGMood?
    @Published var fadeDuration: TimeInterval = 1.0
    
    private var backgroundPlayer: AVAudioPlayer?
    private var effectsPlayer: AVAudioPlayer?
    private var sleepTask: Task<Void, Never>?
    private var fadeTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // .playback plays even with silent switch enabled
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    // MARK: - Background Music
    func playMood(_ mood: BGMood, trackIndex: Int? = nil) {
        stopBackgroundMusic()
        
        let files = mood.fileNames
        let selectedFile: String
        
        if let index = trackIndex, index < files.count {
            selectedFile = files[index]
        } else {
            selectedFile = files.randomElement() ?? files[0]
        }
        
        guard let url = Bundle.main.url(
            forResource: selectedFile,
            withExtension: "mp3",
            subdirectory: "Audio/\(mood.folder)"
        ) else {
            // Fallback: Versuche ohne Subdirectory
            guard let fallbackUrl = Bundle.main.url(forResource: selectedFile, withExtension: "mp3") else {
                print("BGM file not found: \(selectedFile).mp3")
                return
            }
            startPlayback(url: fallbackUrl, mood: mood)
            return
        }
        
        startPlayback(url: url, mood: mood)
    }
    
    private func startPlayback(url: URL, mood: BGMood) {
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = -1 // Infinite loop
            backgroundPlayer?.volume = 0 // Starte mit 0 für Fade-In
            backgroundPlayer?.prepareToPlay()
            backgroundPlayer?.play()
            
            currentMood = mood
            isPlaying = true
            
            // Fade-In
            fadeVolume(from: 0, to: volume, duration: fadeDuration)
            
        } catch {
            print("Audio playback failed: \(error)")
            isPlaying = false
        }
    }
    
    /// Spielt passende Musik basierend auf der aktuellen Szene
    func playForScene(mood: String?) {
        guard let moodString = mood else {
            playMood(.calm)
            return
        }
        
        let mappedMood = BGMood(rawValue: moodString.lowercased()) ?? .calm
        playMood(mappedMood)
    }
    
    func stopBackgroundMusic(fadeOut: Bool = true) {
        guard let player = backgroundPlayer else {
            isPlaying = false
            currentMood = nil
            return
        }
        
        if fadeOut && fadeDuration > 0 {
            fadeTask?.cancel()
            fadeTask = Task { @MainActor in
                let steps = 20
                let stepDuration = self.fadeDuration / Double(steps)
                let targetVolume: Float = 0
                let currentVolume = player.volume
                let volumeStep = (currentVolume - targetVolume) / Float(steps)
                
                for i in 0..<steps {
                    guard !Task.isCancelled else { return }
                    try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
                    player.volume = max(0, currentVolume - (volumeStep * Float(i + 1)))
                }
                
                player.stop()
                self.backgroundPlayer = nil
                self.isPlaying = false
                self.currentMood = nil
            }
        } else {
            player.stop()
            backgroundPlayer = nil
            isPlaying = false
            currentMood = nil
        }
        
        sleepTask?.cancel()
        sleepTask = nil
    }
    
    func togglePause() {
        guard let player = backgroundPlayer else { return }
        
        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
    
    // MARK: - Sound Effects
    func playSoundEffect(_ effect: SoundEffect) {
        guard let url = Bundle.main.url(
            forResource: effect.fileName,
            withExtension: "mp3",
            subdirectory: "Audio/sound_effects"
        ) else {
            print("Sound effect not found: \(effect.fileName).mp3")
            return
        }
        
        do {
            effectsPlayer = try AVAudioPlayer(contentsOf: url)
            effectsPlayer?.volume = 0.5
            effectsPlayer?.prepareToPlay()
            effectsPlayer?.play()
        } catch {
            print("Sound effect playback failed: \(error)")
        }
    }
    
    /// Spielt Soundeffekt für Seitenwechsel
    func playPageTurn() {
        playSoundEffect(.pageTurn)
    }
    
    /// Spielt Erfolgs-Sound
    func playSuccess() {
        playSoundEffect(.success)
    }
    
    // MARK: - Volume Control
    private func fadeVolume(from: Float, to: Float, duration: TimeInterval) {
        fadeTask?.cancel()
        fadeTask = Task { @MainActor in
            let steps = 20
            let stepDuration = duration / Double(steps)
            let volumeStep = (to - from) / Float(steps)
            
            for i in 0..<steps {
                guard !Task.isCancelled else { return }
                try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
                self.backgroundPlayer?.volume = from + (volumeStep * Float(i + 1))
            }
        }
    }
    
    // MARK: - Sleep Timer
    func setSleepTimer(minutes: Int) {
        sleepTask?.cancel()
        
        guard minutes > 0 else {
            // Timer deaktivieren - Musik weiterlaufen lassen
            return
        }
        
        let nanoseconds = UInt64(minutes) * 60 * 1_000_000_000
        
        sleepTask = Task {
            try? await Task.sleep(nanoseconds: nanoseconds)
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                self.stopBackgroundMusic(fadeOut: true)
            }
        }
    }
    
    func cancelSleepTimer() {
        sleepTask?.cancel()
        sleepTask = nil
    }
    
    // MARK: - Legacy Support
    @available(*, deprecated, renamed: "playMood")
    func playLoop(named fileName: String, ext: String = "mp3") {
        stopBackgroundMusic(fadeOut: false)
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            print("BGM file not found: \(fileName).\(ext)")
            return
        }
        
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = -1
            backgroundPlayer?.volume = volume
            backgroundPlayer?.prepareToPlay()
            backgroundPlayer?.play()
            isPlaying = true
        } catch {
            print("Audio playback failed: \(error)")
        }
    }
    
    @available(*, deprecated, renamed: "stopBackgroundMusic")
    func stop() {
        stopBackgroundMusic(fadeOut: false)
    }
    
    @available(*, deprecated, renamed: "playMood")
    func setEnabled(_ enabled: Bool, fileName: String = "bgm_calm") {
        if enabled {
            playLoop(named: fileName)
        } else {
            stopBackgroundMusic()
        }
    }
}
