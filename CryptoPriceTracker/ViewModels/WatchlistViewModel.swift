//
//  WatchlistViewModel.swift
//  CryptoPriceTracker
//
//  Created by Gourav Kumar on 18/07/25.
//

import Foundation

class WatchlistViewModel: ObservableObject {
    @Published var watchlistedCoins: [Coin] = []

    private let coinRepository: CoinRepositoryProtocol

    init(coinRepository: CoinRepositoryProtocol) {
        self.coinRepository = coinRepository
        getWatchlist()
    }

    func getWatchlist() {
        Task {
            do {
                let coins = try await coinRepository.getWatchlist()
                await MainActor.run {
                    self.watchlistedCoins = coins
                }
            } catch {
                
            }
        }
    }
    func onAppear(){
        if coinRepository.isWatchlistDirty {
            getWatchlist()
            coinRepository.resetWatchlistDirtyFlag()
        }
    }

    func addCoinToWatchlist(coin: Coin) {
        coinRepository.storeCoinToWatchlist(coin: coin)
        getWatchlist()
    }

    func removeCoinFromWatchlist(coin: Coin) {
        coinRepository.removeCoinFromWatchlist(coin: coin)
        getWatchlist()
    }
}

