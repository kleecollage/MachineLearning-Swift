//
//  TwitterManager.swift
//  Twittermenti
//
//  Created by Antonio Hernández Santander on 28/01/26.
//  Copyright © 2026 London App Brewery. All rights reserved.
//

import Foundation
import TwitterAPIKit
import SwiftyJSON

class TwitterManager {
    static let shared = TwitterManager()
    private var client: TwitterAPIClient!
    let sentimentalClassifier = TweetSentimentClassifier()
    
    private init() {
        self.client = setupClient()
    }
    
    private func setupClient() -> TwitterAPIClient {
        // Credentials from Secrets.plist
        guard let apiKey = SecretsManager.shared.getValue(forKey: "API_KEY"),
              let apiSecret = SecretsManager.shared.getValue(forKey: "API_SECRET"),
              let clientID = SecretsManager.shared.getValue(forKey: "CLIENT_ID"),
              let clientIDSecret = SecretsManager.shared.getValue(forKey: "CLIENT_ID_SECRET"),
              let bearerToken = SecretsManager.shared.getValue(forKey: "BEARER_TOKEN"),
              let accessToken = SecretsManager.shared.getValue(forKey: "TOKEN"),
              let accessTokenSecret = SecretsManager.shared.getValue(forKey: "TOKEN_SECRET") else {
            fatalError("ERROR: Twitter credentials not found")
        }
        
        // OAuth 1.0a
        /* return TwitterAPIClient(.oauth10a(.init(
            consumerKey: apiKey,
            consumerSecret: apiSecret,
            oauthToken: accessToken,
            oauthTokenSecret: accessTokenSecret
        ))) */
        
        return TwitterAPIClient(.bearer(bearerToken))
    }
    
    func searchTweets() async -> Int {
        /* let request = GetSearchTweetsRequestV1(
            q: "@Apple",
            count: 100,
            resultType: .recent
        )
        let result = await client.v1.search.searchTweets(request).responseData.result
        print(result) */
        
        var sentimentScore: Int = 0
        let requestV2 = GetTweetsSearchAllRequestV2(
            query: "@Apple",
            maxResults: 100
        )
        let resultV2 = await client.v2.search.searchTweetsAll(requestV2).responseData.result
        switch resultV2 {
            case .success(let data):
                let json = JSON(data)
                var tweets = [TweetSentimentClassifierInput]()
            
                for i in 0..<min(100, json["data"].count) {
                    if let tweet = json["data"][i]["text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                print("Tweets found: \(tweets)")
                do {
                    let predictions = try self.sentimentalClassifier.predictions(inputs: tweets)
                    print(predictions[0].label)
                    for prediction in predictions {
                        print(prediction.label)
                        let sentiment = prediction.label
                        if sentiment == "Pos" {
                            sentimentScore += 1
                        } else if sentiment == "Neg" {
                            sentimentScore -= 1
                        }
                    }
                } catch {
                    print("ERROR: There was an error making a prediction, \(error)")
                }
            case .failure(let error):
                print(error)
        }
        return sentimentScore
    }

    
}

// example 4 documentation
class CustomSearchTweetsRequestV1: GetSearchTweetsRequestV1 {
    let custom: String = ""
    
    override var parameters: [String: Any] {
        var p = super.parameters
        p["custom"] = custom
        return p
    }
}
