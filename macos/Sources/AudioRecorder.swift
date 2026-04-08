import AVFoundation
import Foundation

class AudioRecorder: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var recordingTime: TimeInterval = 0
    @Published var playbackProgress: Double = 0
    @Published var playbackDuration: TimeInterval = 0

    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var timer: Timer?
    private var tempURL: URL?

    var recordedURL: URL? { tempURL }

    func startRecording() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".m4a")
        tempURL = url

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.record()
            isRecording = true
            recordingTime = 0
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.recordingTime = self?.recorder?.currentTime ?? 0
            }
        } catch {
            isRecording = false
        }
    }

    func stopRecording() {
        recorder?.stop()
        recorder = nil
        timer?.invalidate()
        timer = nil
        isRecording = false
    }

    func startPlaying(url: URL) {
        stopPlaying()
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            playbackDuration = player?.duration ?? 0
            playbackProgress = 0
            player?.play()
            isPlaying = true
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                guard let self, let player = self.player else { return }
                self.playbackProgress = player.duration > 0 ? player.currentTime / player.duration : 0
            }
        } catch {
            isPlaying = false
        }
    }

    func stopPlaying() {
        player?.stop()
        player = nil
        timer?.invalidate()
        timer = nil
        isPlaying = false
        playbackProgress = 0
    }

    func togglePlayback(url: URL) {
        if isPlaying { stopPlaying() } else { startPlaying(url: url) }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.stopPlaying()
        }
    }

    func formatTime(_ time: TimeInterval) -> String {
        let m = Int(time) / 60
        let s = Int(time) % 60
        return String(format: "%d:%02d", m, s)
    }

    func cleanup() {
        stopRecording()
        stopPlaying()
        if let url = tempURL { try? FileManager.default.removeItem(at: url) }
        tempURL = nil
    }
}
