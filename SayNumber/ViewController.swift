    //
    //  ViewController.swift
    //  SayNumber
    //
    //  Created by Dave Poirier on 2017-09-21.
    //  Copyright © 2017 Soft.io. All rights reserved.
    //

    import UIKit
    import AVFoundation

    class ViewController: UIViewController, AVAudioPlayerDelegate {

        var valueToAnnonce: Int = 321
        var audioPlayer: AVAudioPlayer!
        var audioQueue: [String] = []

        @IBAction
        func announceValue(_ sender: Any?) {
            verbalizeValue(valueToAnnonce)
        }

        func verbalizeValue(_ value: Int) {
            let announcements = prepareAnnouncements(value)
            playAnnouncements(announcements)
        }

        func prepareAnnouncements(_ value: Int) -> [String] {
            var valueToProcess: Int = value
            var announcements: [String] = []
            if valueToProcess >= 100 {
                // values 100 and above
                let hundred = valueToProcess / 100
                valueToProcess = valueToProcess % 100
                let soundfile = "say_\(hundred)00"
                announcements.append(soundfile)
            }
            if valueToProcess >= 20 {
                // values 30 to 99
                let dozen = valueToProcess / 10
                valueToProcess = valueToProcess % 10
                let soundfile = "say_\(dozen)0"
                announcements.append(soundfile)
            }
            if valueToProcess >= 1 || announcements.count == 0 {
                // values 0 to 19
                let soundfile = "say_\(valueToProcess)"
                announcements.append(soundfile)
            }
            return announcements
        }

        func playAnnouncements(_ announcements: [String] ) {
            // announcements contains an array of wave filenames to play one after the other
            if nil != audioPlayer && audioPlayer!.isPlaying {
                print("Audio player was active, stop it and play the new announcements!")
                audioPlayer.stop()
            }
            audioQueue.removeAll()
            for filename in announcements {
                let path = pathForAudioFile(filename)
                if path != nil {
                    audioQueue.append(path!)
                }
            }
            playNextInQueue()
        }

        func playNextInQueue() {
            let nextPathInQueue = audioQueue.first
            if nextPathInQueue != nil {
                audioQueue.removeFirst(1)
                let audioFileURL = URL(fileURLWithPath: nextPathInQueue!)
                audioPlayer = try? AVAudioPlayer(contentsOf: audioFileURL)
                guard audioPlayer != nil else {
                    print("Oops, file not found: \(nextPathInQueue!)")
                    return
                }
                print("playing \(nextPathInQueue!)")
                audioPlayer?.delegate = self
                audioPlayer?.play()
            } else {
                print("looks like we are all done!")
            }
        }

        func pathForAudioFile(_ filename: String) -> String? {
            return Bundle.main.path(forResource: filename, ofType: "wav")
        }

        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            DispatchQueue.main.async {
                self.playNextInQueue()
            }
        }
    }

