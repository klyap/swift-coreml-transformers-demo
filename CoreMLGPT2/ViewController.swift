//
//  ViewController.swift
//  CoreMLGPT2
//
//  Created by Julien Chaumond on 18/07/2019.
//  Copyright © 2019 Hugging Face. All rights reserved.
//

import UIKit

@available(iOS 15.0, *)
class ViewController: UIViewController {
    @IBOutlet weak var shuffleBtn: UIButton!
    @IBOutlet weak var triggerBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var speedLabel: UILabel!

//  let model = GPT2(strategy: .topK(40))
    let model = GPT2()
    
    let prompts = [
        "Write a story about the beach.",
        "Today, we will "
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shuffle()
        shuffleBtn.addTarget(self, action: #selector(shuffle), for: .touchUpInside)
        triggerBtn.addTarget(self, action: #selector(trigger), for: .touchUpInside)
        self.dismissKeyboard()
        
        textView.isScrollEnabled = true
        textView.flashScrollIndicators()
        self.speedLabel.text = "0"
    }
    
    @objc func shuffle() {
        guard let prompt = prompts.randomElement() else {
            return
        }
        textView.text = prompt
    }
    
    @objc func trigger() {
        guard let text = textView.text else {
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            _ = self.model.generate(text: text, nTokens: 50) { completion, time in
                DispatchQueue.main.async {
                    let startingTxt = NSMutableAttributedString(string: text, attributes: [
                        .font: self.textView.font as Any,
                        .foregroundColor: self.textView.textColor as Any,
                    ])
                    let completeTxt = NSAttributedString(string: completion, attributes: [
                        .font: self.textView.font as Any,
                        .foregroundColor: self.textView.textColor as Any,
                        .backgroundColor: UIColor.lightGray.withAlphaComponent(0.5),
                    ])
                    startingTxt.append(completeTxt)
                    self.textView.attributedText = startingTxt
                    self.speedLabel.text = String(format: "%.2f", 1 / time)
                }
            }
        }
    }
}
