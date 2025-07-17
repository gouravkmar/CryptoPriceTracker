//
//  CryptoAPIConfig.swift
//  CryptoPriceTracker
//
//  Created by Gourav Kumar on 18/07/25.
//

import Foundation

enum CryptoAPIConfig { // all hard string stored here in the config containing paths , querry strings and host
    static let host = "api.coingecko.com"
    
    enum Path {
        static let topCoins = "/api/v3/coins/markets" // for now we have paths like this, this can be done better
    }

    enum QueryKeys {
        static let vsCurrency = "vs_currency"
        static let order = "order"
        static let perPage = "per_page"
        static let page = "page"
    }
}
