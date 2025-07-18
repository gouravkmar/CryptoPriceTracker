//
//  MockCoinRepository.swift
//  CryptoPriceTrackerTests
//
//  Created by Gourav Kumar on 18/07/25.
//

import Foundation

class MockCoinRepository: CoinRepositoryProtocol {
    var isWatchlistDirty: Bool = false
    
    func resetWatchlistDirtyFlag() {
        isWatchlistDirty = false
    }
    
    private var allCoins: [Coin] = [
//        Coin(id: "bitcoin", symbol: "btc", name: "Bitcoin", image: nil, currentPrice: 60000, priceChangePercentage24H: 2.5, isInWatchList: false),
//        Coin(id: "ethereum", symbol: "eth", name: "Ethereum", image: nil, currentPrice: 3000, priceChangePercentage24H: -1.2, isInWatchList: false),
//        Coin(id: "dogecoin", symbol: "doge", name: "Dogecoin", image: nil, currentPrice: 0.25, priceChangePercentage24H: 4.1, isInWatchList: false)
    ]
    
    private var watchlistIDs: Set<String> = ["bitcoin"]
    
    func fetchCoins() async throws -> [Coin] {
        return allCoins.map { coin in
            var c = coin
            c.isInWatchList = watchlistIDs.contains(coin.id)
            return c
        }
    }
    
    func storeWatchList(coins: [Coin]) {
        watchlistIDs = Set(coins.map { $0.id })
        isWatchlistDirty = true
    }
    
    func getWatchlist() async throws -> [Coin] {
        return allCoins.filter { watchlistIDs.contains($0.id) }.map({ coin in
            var mutableCoin = coin
            mutableCoin.isInWatchList = true
            return mutableCoin
        })
    }
    
    func storeCoinToWatchlist(coin: Coin) {
        watchlistIDs.insert(coin.id)
        isWatchlistDirty = true
    }
    
    func removeCoinFromWatchlist(coin: Coin) {
        watchlistIDs.remove(coin.id)
        isWatchlistDirty = true
    }
    
    func getWatchlistIDs() -> [String] {
        return Array(watchlistIDs)
    }
}
