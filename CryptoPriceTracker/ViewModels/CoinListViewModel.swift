//
//  CoinListViewModel.swift
//  CryptoPriceTracker
//
//  Created by Gourav Kumar on 18/07/25.
//

import Foundation
class CoinListViewModel : ObservableObject {
    
    @Published var searchText: String = ""
    @Published var allCoins: [Coin] = []
    @Published var isLoading : Bool = false
    @Published var errorMsg : String?
    private var timer : Timer?
    private let coinRepository : CoinRepositoryProtocol
    
    init(coinRepository: CoinRepositoryProtocol, refreshRate : Int) {
        self.coinRepository = coinRepository
        startAutoRefresh(refreshRate: refreshRate)
        getCoins()
    }
    var visibleCoins: [Coin] {
        searchText.isEmpty ? allCoins : allCoins.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.symbol.lowercased().contains(searchText.lowercased())
        }
    }
    
    private func startAutoRefresh(refreshRate : Int) {
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(refreshRate), repeats: true) { [weak self] _ in
                self?.getCoins()
            }
            RunLoop.main.add(timer!, forMode: .common)
    }
    func getCoins() {
        isLoading = true
        Task {
            do {
                let coins = try await coinRepository.fetchCoins()
                let storedIDs = coinRepository.getWatchlistIDs()

                let enrichedCoins = coins.map { coin in
                    var mutableCoin = coin
                    mutableCoin.isInWatchList = storedIDs.contains(coin.id)
                    return mutableCoin
                }
                await MainActor.run{
                    allCoins = enrichedCoins
                    isLoading = false
                }
            }catch {
                await MainActor.run{
                    isLoading = false
                    errorMsg = error.localizedDescription
                }
            }
        }
    }
    
    
    func addCoinToWatchlist(coin: Coin) {
        coinRepository.storeCoinToWatchlist(coin: coin)
        
        if let index = allCoins.firstIndex(where: { $0.id == coin.id }) {
            allCoins[index].isInWatchList = true
        }
    }
    func removeCoinFromWatchList(coin : Coin){
        coinRepository.removeCoinFromWatchlist(coin: coin)
        
        if let index = allCoins.firstIndex(where: { $0.id == coin.id }) {
            allCoins[index].isInWatchList = false
        }
    }
    func onAppear(){
        if coinRepository.isWatchlistDirty {
            getCoins()
            coinRepository.resetWatchlistDirtyFlag()
        }
    }
    
    deinit{
        timer?.invalidate()
        timer = nil
    }
}
