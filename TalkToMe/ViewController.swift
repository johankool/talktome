//
//  ViewController.swift
//  TalkToMe
//
//  Created by Johan Kool on 29/11/2023.
//

import UIKit
import AVFAudio

class ViewController: UIViewController {
    let synthesizer = AVSpeechSynthesizer()
    var status: SynthesizerStatus = .ready {
        didSet {
            updateButtons()
        }
    }
    
    var utterances: [AVSpeechUtterance] = []
    var highlightedRange: (Int, NSRange)? {
        didSet {
            updateHighlight(oldValue: oldValue)
        }
    }
    
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var textLabel2: UILabel!
    @IBOutlet var textLabel3: UILabel!
    @IBOutlet var speakButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        synthesizer.delegate = self
        updateButtons()
    }

    func utterance(for string: NSAttributedString?) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(attributedString: string!)
        utterance.preUtteranceDelay = 0.2
        utterance.postUtteranceDelay = 0.4
        return utterance
    }
    
    @IBAction func speakButtonTapped(_ sender: Any) {
        print("Spreek!")
        let session = AVAudioSession.sharedInstance()
        do {
            // 1) Configure your audio session category, options, and mode
            try session.setCategory(.playback)
            // 2) Activate your audio session to enable your custom configuration
            try session.setActive(true)
        } catch let error as NSError {
            print("Unable to activate audio session:  \(error.localizedDescription)")
        }
        switch status {
        case .ready:
            utterances = [textLabel, textLabel2, textLabel3]
                .map(\.attributedText)
                .map(utterance(for:))
            status = .preparing
            synthesizer.speak(utterances[0])
        case .preparing, .speaking:
            break
        case .paused:
            synthesizer.continueSpeaking()
        }
       
    }
    
    @IBAction func pauseButtonTapped(_ sender: Any) {
        print("Pauze")
        synthesizer.pauseSpeaking(at: .word)
    }
    
    private func updateButtons() {
        switch status {
        case .ready:
            speakButton.isHidden = false
            pauseButton.isHidden = true
        case .preparing:
            speakButton.isHidden = true
            pauseButton.isHidden = true
        case .speaking:
            speakButton.isHidden = true
            pauseButton.isHidden = false
        case .paused:
            speakButton.isHidden = false
            pauseButton.isHidden = true
        }
    }
    
    private func updateHighlight(oldValue: (Int, NSRange)?) {
        func label(for index: Int) -> UILabel {
            let label: UILabel!
            if index == 0 {
                label = textLabel
            } else if index == 1 {
                label = textLabel2
            } else if index == 2 {
                label = textLabel3
            } else {
                fatalError()
            }
            return label
        }
        if let (oldIndex, oldRange) = oldValue {
            let label = label(for: oldIndex)
            if let attributedText = label.attributedText?.mutableCopy() as? NSMutableAttributedString {
                attributedText.removeAttribute(NSAttributedString.Key.backgroundColor, range: oldRange)
                label.attributedText = attributedText
            }
        }
        if let (newIndex, newRange) = highlightedRange {
            let label = label(for: newIndex)
            if let attributedText = label.attributedText?.mutableCopy() as? NSMutableAttributedString {
                attributedText.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.blue.cgColor, range: newRange)
                label.attributedText = attributedText
            }
        }
    }
}

enum SynthesizerStatus {
    case ready
    case preparing
    case speaking
    case paused
}

extension ViewController: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        status = .speaking
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let index = utterances.firstIndex(of: utterance)!
        let nextIndex = index + 1
        if utterances.indices.contains(nextIndex) {
            synthesizer.speak(utterances[nextIndex])
        } else {
            status = .ready
            highlightedRange = nil
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        status = .paused
        highlightedRange = nil
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        status = .speaking
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        status = .ready
        highlightedRange = nil
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let index = utterances.firstIndex(of: utterance)!
        highlightedRange = (index, characterRange)
    }
    
}
