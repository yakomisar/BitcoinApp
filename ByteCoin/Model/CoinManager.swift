//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoinPrice(_ coinManager: CoinManager, coin: CoinModel)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "?apikey=9390EA63-8669-4526-B22D-A529FEBB7142"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    
    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String) -> Double? {
        return 1.0
    }
    
    func fetchPriceFor(currency: String) {
        let getPrice = "\(baseURL)/\(currency)\(apiKey)"
        performRequest(url: getPrice)
    }
    
    func performRequest(url: String)  {
        //1. Create URL
        if let urlString = URL(string: url) {
            //2. Create a URLSession
            let urlSession = URLSession(configuration: .default)
            
            //3. Give the session a task
            let task = urlSession.dataTask(with: urlString) { (data, response, error) in
                if error != nil {
                    print(error!)
                }
                
                if let safeData = data {
                    if let price = self.parseJSON(coinData: safeData) {
                        self.delegate?.didUpdateCoinPrice(self, coin: price)
                    }
                    
                }
            }
            //4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(coinData: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do {
        let decodedData = try decoder.decode(CoinData.self, from: coinData)
    
            let id_base = decodedData.asset_id_base
            let id_quote = decodedData.asset_id_quote
            let rate = decodedData.rate
            
            let coinModel = CoinModel(base: id_base, quote: id_quote, rate: rate)
            return coinModel
        } catch {
            print(error)
            return nil
        }
    }
    
}
