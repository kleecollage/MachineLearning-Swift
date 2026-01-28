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
        Task {
            await TwitterManager.shared.searchTweets()
        }
        let prediction = try! sentimentalClassifier.prediction(text: "@Apple is the best company!")
        print(prediction.label)
    }

    @IBAction func predictPressed(_ sender: Any) {
    }
}
