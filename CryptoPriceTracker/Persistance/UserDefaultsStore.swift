//
//  UserDefaultPersistance.swift
//  CryptoPriceTracker
//
//  Created by Gourav Kumar on 18/07/25.
//

import Foundation

class UserDefaultsStore {
    
    static let session = UserDefaults.standard
    
    static func storeData(data: Data, for key : String){
        session.set(data, forKey: key)
    }
    
    static func deleteData(for key: String){
        session.removeObject(forKey: key)
    }
    
    static func retrieveData(for key : String)-> Data?{
        return session.data(forKey: key)
    }
}
