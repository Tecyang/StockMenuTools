//
//  StockCodesModel.swift
//  StockMenuTools
//
//  Created by tecyang on 2023/3/14.
//

import Foundation
import Cocoa
import SwiftUI
import SwiftyJSON

class StockCodesModes{
    
    @AppStorage("codes") var codes = ""
    
    var symbols = [JSON]()
    init (){
        
        let jsonData = codes.data(using: .utf8)!
        symbols = try! JSON(data: jsonData).arrayValue
    }
        
    func appendSymbol(_ symbol: String, code: JSON) {
        symbols.append(code)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let jsonData = try? encoder.encode(symbols){
            codes = String(data: jsonData, encoding: .utf8)!
        }
        print(codes)
    }
        
    func removeSymbol(_ symbol:String, code: JSON){
        symbols = symbols.filter { $0["symbol"].stringValue != symbol }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let jsonData = try? encoder.encode(symbols){
            codes = String(data: jsonData, encoding: .utf8)!
        }
        print(codes)
    }
    
    
    
}
