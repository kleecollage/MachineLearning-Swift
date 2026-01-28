//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import TwitterAPIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let sentimentalClassifier = TweetSentimentClassifier()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let prediction = try! sentimentalClassifier.prediction(text: "@Apple is the best company!")
        print(prediction.label)
    }

    @IBAction func predictPressed(_ sender: Any) {
        if let searchText = textField.text {
            Task {
                await TwitterManager.shared.searchTweets()
                let score = TwitterManager.shared.sentimentScore
                updateUI(score)
            }
        }
    }
    
    func updateUI(_ score: Int) {
        switch score {
        case 21...100:
            DispatchQueue.main.async { self.sentimentLabel.text = "🥰" }
        case 11...20:
            DispatchQueue.main.async { self.sentimentLabel.text = "😊" }
        case 1...10:
            DispatchQueue.main.async { self.sentimentLabel.text = "😐" }
        case 0:
            DispatchQueue.main.async { self.sentimentLabel.text = "😑" }
        case (-10)...(-1):
            DispatchQueue.main.async { self.sentimentLabel.text = "😡" }
        case (-20)...(-11):
            DispatchQueue.main.async { self.sentimentLabel.text = "🤮" }
        default:
            DispatchQueue.main.async { self.sentimentLabel.text = "💩" }
        }
    }
}
