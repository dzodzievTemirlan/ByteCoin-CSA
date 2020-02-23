//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Temirlan Dzodziev on 11/02/2020.
//  Copyright © 2019 Temirlan Dzodziev. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didFailWithError(_ error: Error)
    func didUpdateCoin(_ price: String, _ currency: String)
}

struct CoinManager{
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC/"
    let apiKey = "APIKEY"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String){
        
        let urlString = "\(baseURL)\(currency)?apikey=\(apiKey)"
        
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, responce, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                if let safeData = data{
                    if let bitcoinPrice = self.parseJson(safeData){
                        let priceString = String(format: "%0.2f", bitcoinPrice)
                        self.delegate?.didUpdateCoin(priceString, currency)
                    }
                }
                
            }
            task.resume()
        }
    }
    
    
    func parseJson(_ data: Data)->Double?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            return lastPrice
        }catch{
            delegate?.didFailWithError(error)
            return nil
        }
    }
    
}



