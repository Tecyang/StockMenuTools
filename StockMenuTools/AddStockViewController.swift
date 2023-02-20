//
//  AddStockViewController.swift
//  StockMenuTools
//
//  Created by tecyang on 2023/2/17.
//

import Foundation
import Cocoa
import SwiftHTTP
import SwiftyJSON

class AddStockViewController: NSViewController,NSSearchFieldDelegate,NSTableViewDelegate, NSTableViewDataSource{
    
    
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var tableView: NSTableView!
    var searchResults = [String]()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do view setup here.
        searchField.delegate = self
        tableView.delegate = self
    }
    
    func controlTextDidChange(_ obj: Notification) {
        searchResults = []
        let searchText = searchField.stringValue
        if searchText.count > 0 {
            // 根据搜索关键字查询数据
            getStockInfo(code:searchText)
            print(searchResults)
        }
    }
    
    func updateSearchResults(res:[String]){
        self.searchResults = res
    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        // 返回表格的分区数量
        return searchResults.count
        
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//        if tableColumn?.identifier.rawValue == "stockInfoColumn" {
            //添加股票名称
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: nil) as! NSTableCellView
            cell.textField?.stringValue = self.searchResults[row]
            print(cell.textField?.stringValue)
//        }
        return cell
//        else if tableColumn?.identifier.rawValue == "stockOperationColumn"{
//            //添加股票名称
//            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "operationCell"), owner: nil) as! NSTableCellView
//            cell.textField?.stringValue = "添加"
//            return cell
//        }
    }
    
    
    //    @IBAction func AddStockCode(_ sender: NSSearchField) {
    ////        print(sender.stringValue)
    //        self.getStockInfo(code: sender.stringValue)
    //    }
    
    
    func getStockInfo(code:String) {
        let url = "https://www.weicaixun.com/pubapi1/gp_search_lists";
        
        let paras = ["search_text":code]
        
        HTTP.GET(url, parameters: paras)  { response in
            
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                //                return //also notify app of failure as needed
            }
            else{
                do{
                    let json = try JSON(data: response.text!.data(using: .utf8, allowLossyConversion: false)!)
                    //                    print(json)
                    if json["code"] == 1 {
                        var result:[String] = []
                        for item in json["data"].arrayValue {
                            let symbol:String = item["symbol"].string!
                            let name:String = item["name"].string!
                            result.append(symbol+name)
                            DispatchQueue.main.async {
                                self.searchResults = result
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                catch {}
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
