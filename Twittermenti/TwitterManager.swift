//
//  TwitterManager.swift
//  Twittermenti
//
//  Created by Antonio Hernández Santander on 28/01/26.
//  Copyright © 2026 London App Brewery. All rights reserved.
//

import Foundation
import TwitterAPIKit

class TwitterManager {
    static let shared = TwitterManager()
    private var client: TwitterAPIClient!
    
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
    
    func searchTweets() async {
        let request = GetSearchTweetsRequestV1(
            q: "@Apple",
            count: 2,
            resultType: .recent
        )
            
        let request2 = GetTweetsSearchAllRequestV2(
            query: "@Apple",
            maxResults: 2
        )
        
        let result = await client.v1.search.searchTweets(request).responseData.result
        let result2 = await client.v2.search.searchTweetsAll(request2).responseData.result
        // print(result)
        print(result2)
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
