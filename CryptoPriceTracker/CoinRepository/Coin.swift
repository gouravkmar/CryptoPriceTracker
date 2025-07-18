//
//  Coin.swift
//  CryptoPriceTracker
//
//  Created by Gourav Kumar on 18/07/25.
//

import Foundation

struct Coin: Identifiable, Codable {
    let id: String
    let symbol: String
    let name: String
    let image: String?
    let currentPrice: Double
    let priceChangePercentage24H: Double?
    var isInWatchList: Bool? = false
}
