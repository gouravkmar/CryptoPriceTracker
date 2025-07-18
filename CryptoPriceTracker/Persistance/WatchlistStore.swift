//
//  UserDefaultHelper.swift
//  CryptoPriceTracker
//
//  Created by Gourav Kumar on 18/07/25.
//

import Foundation

protocol WatchlistStoreProtocol {
    func storeCoins(coindIDs: [String], for key: String)
    func getCoinIDs(for key: String) -> [String]?
    func deleteData(key: String)
}

enum CryptoStoredKeys { //can be extended to store other types on coins, bought, different watchlists etc
    static let watchListKey = "WatchList"
}
class WatchlistStore : WatchlistStoreProtocol{

    func storeCoins(coindIDs : [String] , for key : String = CryptoStoredKeys.watchListKey) { //defaulting for this project, must remove this default in future
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(coindIDs){ // for now if the watchlist is not stored, we allow to fail silently, meaning storing watchlist becomes a good to have feature
            UserDefaultsStore.storeData(data: data, for: key)
        }
    }
    
    func getCoinIDs(for key : String = CryptoStoredKeys.watchListKey)-> [String]?{
        guard let data = UserDefaultsStore.retrieveData(for: key) else { return nil} //same failing silently logic applies here
        
        let decoder = JSONDecoder()
        return try? decoder.decode([String].self, from: data)
    }
    func deleteData(key: String = CryptoStoredKeys.watchListKey) {
        UserDefaultsStore.deleteData(for: key)
    }
    
}
