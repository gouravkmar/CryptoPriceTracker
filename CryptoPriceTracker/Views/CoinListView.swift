//
//  CoinListView.swift
//  CryptoPriceTracker
//
//  Created by Gourav Kumar on 18/07/25.
//

import SwiftUI

import SwiftUI

struct CoinListView: View {
    @StateObject var viewModel: CoinListViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search Coins", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                if viewModel.isLoading {
                    ProgressView("Loading Coins...")
                        .padding()
                } else {
                    List(viewModel.visibleCoins) { coin in
                        CoinRowView(coin: coin,
                                    isInWatchlist: coin.isInWatchList!,
                                    addAction: {
                            viewModel.addCoinToWatchlist(coin: coin)
                        },
                                    removeAction: {
                            viewModel.removeCoinFromWatchList(coin: coin)
                        })
                    }
                }
            }
            .navigationTitle("Crypto Tracker")
        }.onAppear(perform: {
            viewModel.onAppear()
        })
    }
}
