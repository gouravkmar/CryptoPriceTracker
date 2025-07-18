//
//  CryptoPriceTrackerTests.swift
//  CryptoPriceTrackerTests
//
//  Created by Gourav Kumar on 17/07/25.
//
import Testing
@testable import CryptoPriceTracker

struct CryptoPriceTrackerTests {

    class MockWatchlistStore: WatchlistStoreProtocol {
        func deleteData(key: String) {
            storedIDs = []
        }
        

        var storedIDs: [String] = []

         func storeCoins(coindIDs: [String], for key: String) {
            storedIDs = coindIDs
        }

        func getCoinIDs(for key: String) -> [String]? {
            return storedIDs
        }

         func deleteCoins(key: String) {
            storedIDs = []
        }
    }

    class MockCoinRepository: CoinRepositoryProtocol {
        var isWatchlistDirty: Bool = false
        
        func resetWatchlistDirtyFlag() {
            isWatchlistDirty = false
        }
        
        func fetchCoins() async throws -> [Coin] {
            return [
                Coin(id: "btc", symbol: "BTC", name: "Bitcoin", image: nil, currentPrice: 1000, priceChangePercentage24H: 1.0, isInWatchList: false),
                Coin(id: "eth", symbol: "ETH", name: "Ethereum", image: nil, currentPrice: 500, priceChangePercentage24H: -2.0, isInWatchList: false)
            ]
        }

        func storeWatchList(coins: [Coin]) {}
        func getWatchlist() async throws -> [Coin] { return [] }
        func storeCoinToWatchlist(coin: Coin) {}
        func removeCoinFromWatchlist(coin: Coin) {}
        func getWatchlistIDs() -> [String] { return ["btc"] }
    }

    @Test func testCoinRepositoryFetchSuccess() async throws {
        let repo = MockCoinRepository()
        let coins = try await repo.fetchCoins()
        #expect(coins.count == 2)
        #expect(coins[0].name == "Bitcoin")
    }

    @Test func testWatchlistStoreSaveAndRetrieve() {
        var store = MockWatchlistStore()
        store.storeCoins(coindIDs: ["btc", "eth"], for: "WatchList")
        let saved = store.getCoinIDs(for: "WatchList")
        #expect(saved == ["btc", "eth"])
    }

    @Test func testViewModelFetchUpdatesCoins() async throws {
        let vm = CoinListViewModel(coinRepository: MockCoinRepository(), refreshRate: 60)
        try await Task.sleep(for: .milliseconds(100)) // give task a tick
        #expect(vm.allCoins.count == 2)
        #expect(vm.allCoins.first?.isInWatchList == true)
    }
}
