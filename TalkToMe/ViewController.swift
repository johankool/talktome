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
        print("Speaking!")
        let utterance = AVSpeechUtterance(attributedString: textLabel.attributedText!)
        switch status {
        case .ready:
            utterances = [textLabel, textLabel2, textLabel3]
                .map(\.attributedText)
                .map(utterance(for:))
            synthesizer.speak(utterances[0])
        case .speaking:
            break
        case .paused:
            synthesizer.continueSpeaking()
        }
       
    }
    
    @IBAction func pauseButtonTapped(_ sender: Any) {
        print("Pauze!")
        synthesizer.pauseSpeaking(at: .word)
    }
    
    private func updateButtons() {
        switch status {
        case .ready:
            speakButton.isHidden = false
            pauseButton.isHidden = true
        case .speaking:
            speakButton.isHidden = true
            pauseButton.isHidden = false
        case .paused:
            speakButton.isHidden = false
            pauseButton.isHidden = true
        }
    }
}

enum SynthesizerStatus {
    case ready
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
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        status = .paused
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        status = .speaking
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        status = .ready
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let index = utterances.firstIndex(of: utterance)!
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
        if let attributedText = label.attributedText?.mutableCopy() as? NSMutableAttributedString {
            attributedText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: characterRange)
            label.attributedText = attributedText
        }
    }
    
}
