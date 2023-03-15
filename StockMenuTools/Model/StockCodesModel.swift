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
    
    var symbols = [String]()
    
    init() {
        symbols = (try? JSONDecoder().decode([String].self, from: Data(codes.utf8))) ?? []
    }
        
    func appendSymbol(_ symbol: String) {
        symbols.append(symbol)
        codes = symbols.joined(separator: ",")
        print(codes)
    }
        
    func removeSymbol(_ symbol:String){
        symbols = symbols.filter { $0 != symbol }
        codes = symbols.joined(separator: ",")
        print(codes)
    }
    
    
    
}
