//
//  FloweData.swift
//  WhatFlower
//
//  Created by Antonio Hernández Santander on 26/01/26.
//

import Foundation

struct FlowerData: Codable {
    let query: QueryData
}

struct QueryData: Codable {
    let pageids: [String]
    let pages: [String: FlowerPageData]
}

struct FlowerPageData: Codable {
    var pageid: String
    let title: String
    let extract: String
}

/*
   "query": {
     "pageids": [
       "26537"
     ],
     "pages": {
       "26537": {
         "pageid": 26537,
         "ns": 0,
         "title": "Rose",
         "extract": "A rose is either a woody ..."
       }
     }
   }
 */
