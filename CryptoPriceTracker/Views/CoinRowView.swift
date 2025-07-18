//
//  CoinRowView.swift
//  CryptoPriceTracker
//
//  Created by Gourav Kumar on 18/07/25.
//

import Foundation
import SwiftUI

struct CoinRowView: View {
    let coin: Coin
    let isInWatchlist: Bool
    let addAction: () -> Void
    let removeAction: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(coin.name)
                    .font(.headline)
                Text(coin.symbol.uppercased())
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("$\(String(format: "%.2f", coin.currentPrice))")
                .font(.subheadline)
            
            Button(action: {
                isInWatchlist ? removeAction() : addAction()
            }) {
                Image(systemName: isInWatchlist ? "checkmark.circle.fill" : "plus.circle")
                    .foregroundColor(isInWatchlist ? .green : .blue)
                    .imageScale(.large)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
    }
}



