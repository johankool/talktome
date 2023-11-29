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
    
    @IBOutlet var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func speakButtonTapped(_ sender: Any) {
        print("Speaking!")
        let utterance = AVSpeechUtterance(string: textLabel.text!)
        synthesizer.speak(utterance)
    }
    
}

