//
//  FlowerManager.swift
//  WhatFlower
//
//  Created by Antonio Hernández Santander on 26/01/26.
//

import Foundation

protocol FlowerManagerDelegate {
    func didUpdateFlowers(_ flowerManager: FlowerManager, flowerModel: FlowerModel)
    func didFailWithError(error: Error)
}

struct FlowerManager {
    var delegate: FlowerManagerDelegate?
    let url = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&indexpageids&redirects=1&titles="
    
    func fetchFlowers(flowerName: String) {
        let urlString = url + flowerName
        performRequest(with: urlString)
    }
    
    func performRequest(with url: String) {
        if let url = URL(string: url) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let flower = self.parseJSON(safeData) {
                        delegate?.didUpdateFlowers(self, flowerModel: flower)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ flowerData: Data) -> FlowerModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(FlowerData.self, from: flowerData)
            guard let id = decodedData.query.pageids.first else {
                fatalError("No ID found")
            }
            let title = decodedData.query.pages[id]!.title
            let extract = decodedData.query.pages[id]!.extract
            let flowerInfo = FlowerModel(title: title, extract: extract)
            return flowerInfo
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
