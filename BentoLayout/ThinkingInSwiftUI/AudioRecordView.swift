//
//  AudioRecordView.swift
//  ThinkingInSwiftUI
//
//  Created by MacBook on 16/8/2024.
//

import SwiftUI
import Foundation
import AVFoundation

struct WaveformShape: Shape {
    var samples: [Float]
    var sensitivity: CGFloat = 0.5 // Reduce the sensitivity
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step = rect.width / CGFloat(samples.count)
        let centerY = rect.height / 2
        
        for index in samples.indices {
            let x = CGFloat(index) * step
            let normalizedSample = CGFloat(samples[index]).clamped(to: 0...1) // Normalize between 0 and 1
            let amplitude = normalizedSample * centerY * sensitivity
            
            // Draw the upward wave
            path.move(to: CGPoint(x: x, y: centerY))
            path.addLine(to: CGPoint(x: x, y: centerY - amplitude))
            
            // Draw the downward wave (mirror image)
            path.move(to: CGPoint(x: x, y: centerY))
            path.addLine(to: CGPoint(x: x, y: centerY + amplitude))
        }
        
        return path
    }
}

extension Comparable {
    /// Clamps a value to a specified range.
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

struct WaveformView: View {
    var samples: [Float]
    
    var body: some View {
        WaveformShape(samples: samples)
            .stroke(Color.blue, lineWidth: 2)
            .padding(.horizontal)
            .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .animation(.linear, value: samples)
    }
}


struct AudioRecordView: View {
    @StateObject private var audioRecorder = AudioRecorder()
        
    var body: some View {
        VStack {
            Text(audioRecorder.isRecording ? "Recording..." : "Not Recording")
                .padding()
            
            Button(audioRecorder.isRecording ? "Stop Recording" : "Start Recording") {
                if audioRecorder.isRecording {
                    audioRecorder.stopRecording()
                } else {
                    audioRecorder.startRecording()
                }
            }
            .padding()
            .background(audioRecorder.isRecording ? Color.red : Color.green)
            .foregroundColor(.white)
            .clipShape(Capsule())
            
            WaveformView(samples: audioRecorder.amplitudeSamples)
                .frame(height: 100)
                .padding()
            
            List(audioRecorder.recordings, id: \.createdAt) { recording in
                HStack {
                    Text("Recording \(recording.createdAt)")
                    Spacer()
                    Button("Play") {
                        audioRecorder.playRecording(recording: recording)
                    }
                }
            }
            .padding()
        }
        .padding()
    }
}


class AudioRecorder: NSObject, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var levelTimer: Timer?

    @Published var recordings: [Recording] = []
    @Published var isRecording = false
    @Published var amplitudeSamples: [Float] = []

    override init() {
        super.init()
        fetchRecordings()
    }

    func startRecording() {
        let fileName = "\(Date()).m4a"
        let path = getDocumentsDirectory().appendingPathComponent(fileName)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1, // Change to mono
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: path, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            isRecording = true
            
            // Start the level timer to capture amplitude data
            levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                self.captureAmplitude()
            }
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        levelTimer?.invalidate()
        fetchRecordings()
    }

    func playRecording(recording: Recording) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recording.fileURL)
            audioPlayer?.play()
        } catch {
            print("Failed to play recording: \(error.localizedDescription)")
        }
    }
    
    private func captureAmplitude() {
        guard let audioRecorder = audioRecorder else { return }
        audioRecorder.updateMeters()
        let level = audioRecorder.averagePower(forChannel: 0)
        let normalizedLevel = max(0.2, CGFloat(level) + 50) / 2 // Normalization
        amplitudeSamples.append(Float(normalizedLevel))
        
        // Limit samples to 100 to avoid excessive memory usage
        if amplitudeSamples.count > 100 {
            amplitudeSamples.removeFirst()
        }
    }

    private func fetchRecordings() {
        recordings.removeAll()
        let fileManager = FileManager.default
        let documentsDirectory = getDocumentsDirectory()
        
        do {
            let urls = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            for url in urls {
                let recording = Recording(fileURL: url, createdAt: getCreationDate(for: url))
                recordings.append(recording)
            }
        } catch {
            print("Failed to fetch recordings: \(error.localizedDescription)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func getCreationDate(for url: URL) -> Date {
        (try? FileManager.default.attributesOfItem(atPath: url.path)[.creationDate] as? Date) ?? Date()
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            stopRecording()
        }
    }
}

struct Recording {
    let fileURL: URL
    let createdAt: Date
}
