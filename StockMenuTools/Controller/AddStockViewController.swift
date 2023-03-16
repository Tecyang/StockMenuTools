//
//  AddStockViewController.swift
//  StockMenuTools
//
//  Created by tecyang on 2023/2/17.
//

import Foundation
import Cocoa
import SwiftUI
import SwiftHTTP
import SwiftyJSON

class AddStockViewController: NSViewController,NSSearchFieldDelegate,NSTableViewDelegate, NSTableViewDataSource{
    
    // 结果表格
    @IBOutlet weak var tableView: NSTableView!
    //操作列
    @IBOutlet weak var stockOperation: NSTableColumn!
    // 搜索框
    @IBOutlet weak var searchField: NSSearchField!
    
    // 搜索结果
    var searchResults = [JSON]()
    
    // 已存在代码表格
    @IBOutlet weak var codesTableView: NSTableView!
    
    private var stockCodesModel = StockCodesModes()
    
    
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
        else{
            tableView.reloadData()
        }
    }
    
//    func updateSearchResults(res:[JSON]){
//        self.searchResults = res
//    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        // 返回表格的分区数量
        return searchResults.count
        
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let symbol:String = self.searchResults[row]["symbol"].stringValue
        let name:String = self.searchResults[row]["name"].stringValue
        if tableColumn?.identifier.rawValue == "stockInfoColumn" {
            //add stock symbol
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: nil) as? NSTableCellView
            cell?.textField?.stringValue = symbol + name
            return cell
        }
        else if tableColumn?.identifier.rawValue == "stockOperationColumn" {
            //add stock operation
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "operation"), owner: nil) as? NSTableCellView
            let hasCode = stockCodesModel.symbols.map { $0["symbol"].stringValue == symbol }
            
            if hasCode.contains(true) {
                cell?.textField?.stringValue = "移除"
            }
            else{
                cell?.textField?.stringValue = "添加"
            }
            return cell
        }
        else{
            return nil
        }
        
    }
    
    @IBAction func chooseStock(_ sender: NSTableView) {
        
        let code:JSON = searchResults[sender.clickedRow]
        let symbol:String  = code["symbol"].stringValue
        let hasCode = stockCodesModel.symbols.map { $0["symbol"].stringValue == symbol }
        
        if hasCode.contains(true) {
            stockCodesModel.removeSymbol(symbol,code:code)
            let cell = stockOperation.dataCell(forRow: sender.clickedRow) as? NSTableCellView
            cell?.textField?.stringValue = "移除"
        }
        else{
            stockCodesModel.appendSymbol(symbol,code: code)
            let cell = stockOperation.dataCell(forRow: sender.clickedRow) as? NSTableCellView
            cell?.textField?.stringValue = "添加"
        }
        tableView.reloadData()
    }
    
    func getStockInfo(code:String) {
        let url = "https://www.weicaixun.com/pubapi1/gp_search_lists";
        
        let paras = ["search_text":code]
        
        HTTP.GET(url, parameters: paras)  { response in
            
            if let err = response.error {
                print("error: \(err.localizedDescription)")
            }
            else{
                do{
                    let json = try JSON(data: response.text!.data(using: .utf8, allowLossyConversion: false)!)
                    if json["code"] == 1 {
                        let result:[JSON] = json["data"].arrayValue
                        DispatchQueue.main.async {
                            self.searchResults = result
                            self.tableView.reloadData()
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
