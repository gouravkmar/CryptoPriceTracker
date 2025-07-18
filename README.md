CryptoPriceTracker

CryptoPriceTracker is a SwiftUI-based iOS app that tracks real-time cryptocurrency prices using the CoinGecko API.

All that is needed is Xcode and a device or simulator to run the app, no dependencies or Cocoapods are used.

[▶️ Watch App Preview](https://youtube.com/shorts/4k2R6PhlIy8?feature=share)  
⸻

User Features

Users can:
	•	View the top 20 cryptocurrencies by market cap.
	•	Search for coins by name or symbol.
	•	Add/remove coins from their personal watchlist.
	•	View their saved watchlist.
	•	See live price updates at regular intervals.

⸻

Key Features

Coin List View
	•	Displays top 20 coins from CoinGecko.
	•	Refreshes every 60 seconds (configurable).
	•	Includes a search bar to filter by name or symbol.
	•	Each row shows:
	•	Coin name and symbol
	•	Current price
	•	Watchlist icon:
	•	Green checkmark if the coin is in watchlist.
	•	Blue plus icon if it is not.
	•	Button lets users add or remove a coin from their watchlist.
	•	Tapping on a row is planned to open a modal for detailed coin info (feature not implemented yet).

Watchlist View
	•	Lists only the coins added to watchlist.
	•	Re-fetches their latest data from the API using saved coin IDs.
	•	Uses the same row design (CoinRowView) for consistency.
	•	Only coin IDs are stored locally to avoid outdated prices.
	•	Actual coin data is always freshly fetched from the API using those IDs.

⸻

Assumptions
	•	Static Configuration:
The app currently tracks only the top 20 coins in USD. Configuration like currency, sort order, etc. is hardcoded for now. This can be enhanced in the future.
	•	CryptoAPIConfig:
API host, query parameters, and paths are organized into a single configuration enum. This includes the base URL, endpoint paths, and query keys.
	•	Auth Token:
The token is currently hardcoded. In future, it should be stored securely using Keychain or secure storage.
	•	Watchlist Persistence:
Watchlist data is stored in UserDefaults for simplicity. This can be migrated to CoreData or another persistent store later.
	•	Silent Failures:
If encoding/decoding fails while storing or retrieving watchlist data, the app fails silently. This is acceptable for this version, but error handling and retry mechanisms can be added in the future.

