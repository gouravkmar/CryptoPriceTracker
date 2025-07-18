//
//  MainTabView.swift
//  CryptoPriceTracker
//
//  Created by Gourav Kumar on 18/07/25.
//

import SwiftUI

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            let repository = CoinRepository(watchListStore: WatchlistStore())
            CoinListView(viewModel: CoinListViewModel(
                coinRepository: repository,
                refreshRate: 60
            ))
            .tabItem {
                Label("Coins", systemImage: "bitcoinsign.circle")
            }

            WatchlistView(viewModel: WatchlistViewModel(
                coinRepository: repository
            ))
            .tabItem {
                Label("Watchlist", systemImage: "star.fill")
            }
        }
    }
}

#Preview {
    MainTabView()
}
