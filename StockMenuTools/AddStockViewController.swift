//
//  AddStockViewController.swift
//  StockMenuTools
//
//  Created by tecyang on 2023/2/17.
//

import Foundation
import Cocoa
import SwiftHTTP

class AddStockViewController: NSViewController{
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func AddStockCode(_ sender: NSSearchField) {
//        print(sender.stringValue)
        self.getStockInfo(code: sender.stringValue)
    }
    
    
    func getStockInfo(code:String){
        let url = "https://www.weicaixun.com/pubapi1/gp_search_lists";
        let paras = ["search_text":code]
        
        HTTP.GET(url, parameters: paras) { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            else{
                JSONSerialization.jsonObject(with: response.text)
            }
        }
        
    }
    
    
}

extension AddStockViewController {
    static func initController() -> AddStockViewController{
        let storyboard = NSStoryboard(name: NSStoryboard.Name( "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("AddStockViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? AddStockViewController else {
          fatalError("Cannot find AddStockViewController ")
        }
        return viewcontroller
    }
}
