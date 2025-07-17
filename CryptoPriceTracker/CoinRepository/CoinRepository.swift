//
//  CoinRepository.swift
//  CryptoPriceTracker
//
//  Created by Gourav Kumar on 18/07/25.
//

import Foundation

protocol CoinRepositoryProtocol {
    func fetchCoins() async throws -> [Coin]
    func storeWatchList(coins : [Coin])
    func getWatchlist() async throws -> [Coin]
}
enum CoinRepositoryError: Error {
    case networkFailed
    case decodingFailed
}

class CoinRepository : CoinRepositoryProtocol {
    
    let watchListStore : WatchlistStoreProtocol
    
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
                CryptoAPIConfig.QueryKeys.perPage: "20",// problemm statement
                CryptoAPIConfig.QueryKeys.page: "1"
            ])
            .addHeader(key: "Accept-Encoding", value: "gzip")
            .setTimeout(30)
            .build()
        do {
            let (data,_ ) = try await NetworkManager.shared.makeAPIRequest(networkRequest: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase //coin gecko apis are snakecased and we have camelcasing, can be sorted by using codingkeys also
            return try decoder.decode([Coin].self, from: data)
        } catch let error as DecodingError {
            throw CoinRepositoryError.decodingFailed
        } catch {
            throw CoinRepositoryError.networkFailed
        }
    }
    
    func storeWatchList(coins: [Coin]) {
        let ids = coins.map { $0.id }
        watchListStore.storeCoins(coindIDs: ids, for: CryptoStoredKeys.watchListKey)
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
            .build()
        
        do {
            let (data, _) = try await NetworkManager.shared.makeAPIRequest(networkRequest: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let coins = try decoder.decode([Coin].self, from: data)
            return coins
        }  catch let error as DecodingError {
            throw CoinRepositoryError.decodingFailed
        } catch {
            throw CoinRepositoryError.networkFailed
        }
    }
    
    
}
struct Coin: Codable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let image: String?
    let currentPrice: Double
    let priceChangePercentage24H: Double? // temporary structure, check docs for exact format 
}
