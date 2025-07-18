//
//  WatchlistView.swift
//  CryptoPriceTracker
//
//  Created by Gourav Kumar on 18/07/25.
//

import SwiftUI

import SwiftUI

struct WatchlistView: View {
    @StateObject var viewModel: WatchlistViewModel

    var body: some View {
        NavigationView {
            List(viewModel.watchlistedCoins) { coin in
                CoinRowView(
                    coin: coin,
                    isInWatchlist: coin.isInWatchList!,
                    addAction: {
                        viewModel.addCoinToWatchlist(coin: coin)
                    },
                    removeAction: {
                        viewModel.removeCoinFromWatchlist(coin: coin)
                    }
                )
            }
            .navigationTitle("Watchlist")
            .onAppear {
                viewModel.onAppear()
            }
        }
    }
}
