//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import TwitterAPIKit

// When authenticating with OAuth 1.0a, rewrite consumerKey and consumerSecret.
private let consumerKey = "..."
private let consumerSecret = "..."

// If you want to authenticate with OAuth 20 Public Client, please rewrite the clientID.
// When authenticating with OAuth 20's Confidential Client, rewrite clientID and Client Secret.
// For more information, please visit https://github.com/mironal/TwitterAPIKit/blob/main/HowDoIAuthenticate.md
private let clientID = "<Your Client ID>"
private let clientSecret = "<Your Client Secret>"

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    private var env: Env {
        if let env = Env.restore() {
            return env
        }
        return Env(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            oauthToken: nil,
            oauthTokenSecret: nil,
            clientID: clientID,
            clientSecret: clientSecret
        )
    }
    
    var client: TwitterAPIClient! {
        didSet {
            if client == nil {
                print("Not Auth")
            } else if case .oauth10a = client.apiAuth {
                print("Currently authenticated with OAuth 1.0a")
            } else if case .oauth20 = client.apiAuth {
                print("Currently authenticated with OAuth 2.0")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func predictPressed(_ sender: Any) {
    
    
    }

    // MARK: - Private

    private func createClient() -> TwitterAPIClient? {
        if let consumerKey = env.consumerKey,
           let consumerSecret = env.consumerSecret,
           let oauthToken = env.oauthToken,
           let oauthTokenSecret = env.oauthTokenSecret {
            return TwitterAPIClient(.oauth10a(.init(
                consumerKey: consumerKey,
                consumerSecret: consumerSecret,
                oauthToken: oauthToken,
                oauthTokenSecret: oauthTokenSecret
            )))
        } else if let accessToken = env.token {
            return TwitterAPIClient(.oauth20(accessToken))
        }
        return nil
    }

    private func confirmReset() {
        let alert = UIAlertController(title: nil, message: "Reset", preferredStyle: .alert)
        alert.addAction(.init(title: "Reset", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            Env.reset()
            self.client = self.createClient()
        })
        alert.addAction(.init(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func refreshAndStoreToken(clientType: TwitterAuthenticationMethod.OAuth20WithPKCEClientType) async {
        guard let client = client, case .oauth20 = client.apiAuth else {
            fatalError("Refresh is available only when you are authenticating with OAuth 2.0.")
        }
        do {
            let refresh = try await client.refreshOAuth20Token(type: .confidentialClient(clientID: env.clientID!, clientSecret: env.clientSecret!), forceRefresh: true)
            if refresh.refreshed {
                var env = self.env
                env.token = refresh.token
                env.store()
                self.client = createClient()
            }
            print("Success Refresh")
        } catch {
            print(error.localizedDescription)
        }
    }
}
