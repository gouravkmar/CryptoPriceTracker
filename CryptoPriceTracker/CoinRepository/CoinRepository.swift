//
//  CoinRepository.swift
//  CryptoPriceTracker
//
//  Created by Gourav Kumar on 18/07/25.
//

import Foundation

protocol CoinRepositoryProtocol {
    func fetchCoins() async throws -> [Coin]
    func storeCoinToWatchlist(coin: Coin)
    func getWatchlist() async throws -> [Coin]
    func removeCoinFromWatchlist(coin: Coin)
    func getWatchlistIDs() -> [String]
    var isWatchlistDirty : Bool {get}
    func resetWatchlistDirtyFlag() 
}
enum CoinRepositoryError: Error {
    case networkFailed
    case decodingFailed(error : String)
}

class CoinRepository : CoinRepositoryProtocol {
    
    let watchListStore : WatchlistStoreProtocol
    private(set) var isWatchlistDirty = false
    
    init(watchListStore: WatchlistStoreProtocol) {
        self.watchListStore = watchListStore
    }
    
    func fetchCoins() async throws -> [Coin] {
        let request = NetworkRequestBuilder()
            .setHost(CryptoAPIConfig.host)
            .setPath(CryptoAPIConfig.Path.topCoins)
            .setMethod(.get)
            .setParams([
                CryptoAPIConfig.QueryKeys.vsCurrency: "usd",  // this values can come from user settings, of some other config, not overcomplicationg this now by adding more config
                CryptoAPIConfig.QueryKeys.order: "market_cap_desc",
                CryptoAPIConfig.QueryKeys.perPage: "30",// problemm statement
                CryptoAPIConfig.QueryKeys.page: "1"
            ])
            .addHeader(key: "x-cg-demo-api-key", value: CryptoAPIConfig.APIKEY)
            .addHeader(key: "Accept-Encoding", value: "gzip")
            .setTimeout(30)
            .build()
        do {
            let (data,_ ) = try await NetworkManager.shared.makeAPIRequest(networkRequest: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase //coin gecko apis are snakecased and we have camelcasing, can be sorted by using codingkeys also
            return try decoder.decode([Coin].self, from: data)
        } catch let error as DecodingError {
            throw CoinRepositoryError.decodingFailed(error: error.localizedDescription)
        } catch {
            throw CoinRepositoryError.networkFailed
        }
    }
    
    func storeCoinToWatchlist(coin: Coin) {
        let id = coin.id
        let existingIDs = watchListStore.getCoinIDs(for: CryptoStoredKeys.watchListKey) ?? []
        let mergedIDs = Array(Set(existingIDs).union([id])) // add one new ID, keeping it unique
        watchListStore.storeCoins(coindIDs: mergedIDs, for: CryptoStoredKeys.watchListKey)
        isWatchlistDirty = true
    }
    
    func getWatchlist()async throws  -> [Coin] {
        guard let ids = watchListStore.getCoinIDs(for: CryptoStoredKeys.watchListKey), !ids.isEmpty else {
            return []
        }

        let idList = ids.joined(separator: ",") // e.g., "bitcoin,ethereum,dogecoin"

        let request = NetworkRequestBuilder()
            .setHost(CryptoAPIConfig.host)
            .setPath(CryptoAPIConfig.Path.topCoins)
            .setMethod(.get)
            .setParams([
                CryptoAPIConfig.QueryKeys.vsCurrency: "usd",
                "ids": idList
            ])
            .addHeader(key: "x-cg-demo-api-key", value: CryptoAPIConfig.APIKEY)
            .build()
        
        do {
            let (data, _) = try await NetworkManager.shared.makeAPIRequest(networkRequest: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            var coins = try decoder.decode([Coin].self, from: data)
            return coins.map { coin in
                var mutableCoin = coin
                mutableCoin.isInWatchList = true
                return mutableCoin
            }
        }  catch let error as DecodingError {
            throw CoinRepositoryError.decodingFailed(error: error.localizedDescription)
        } catch {
            throw CoinRepositoryError.networkFailed
        }
    }
    func removeCoinFromWatchlist(coin: Coin){
        let id = coin.id
        var watchlist = watchListStore.getCoinIDs(for: CryptoStoredKeys.watchListKey) ?? []
        watchlist.removeAll(where: { $0 == id })
        watchListStore.storeCoins(coindIDs: watchlist, for: CryptoStoredKeys.watchListKey)
        isWatchlistDirty = true
    }
    
    func getWatchlistIDs() -> [String] {
        return watchListStore.getCoinIDs(for: CryptoStoredKeys.watchListKey) ?? []
    }
    func resetWatchlistDirtyFlag() {
            isWatchlistDirty = false
    }
    
    
}


struct Coin: Identifiable, Codable {
    let id: String
    let symbol: String
    let name: String
    let image: String?
    let currentPrice: Double
    let marketCap: Double
    let marketCapRank: Int?
    let fullyDilutedValuation: Double?
    let totalVolume: Double
    let high24H: Double?
    let low24H: Double?
    let priceChange24H: Double?
    let priceChangePercentage24H: Double?
    let marketCapChange24H: Double?
    let marketCapChangePercentage24H: Double?
    let circulatingSupply: Double?
    let totalSupply: Double?
    let maxSupply: Double?
    let ath: Double?
    let athChangePercentage: Double?
    let athDate: String?
    let atl: Double?
    let atlChangePercentage: Double?
    let atlDate: String?
    let roi: ROI?
    let lastUpdated: String?

    var isInWatchList: Bool? = false

    struct ROI: Codable {
        let times: Double?
        let currency: String?
        let percentage: Double?
    }
}
