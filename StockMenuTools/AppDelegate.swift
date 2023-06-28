//
//  AppDelegate.swift
//  MenuToolDemo
//
//  Created by 5km on 2019/10/22.
//  Copyright © 2019 5km. All rights reserved.
//

import Cocoa
import SwiftUI
import SwiftyJSON
import SwiftHTTP
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var menu: NSMenu!
    
    
    //代码
    @AppStorage("codes") private var codes: String = ""
    
    //是否刷新状态栏标识
    @AppStorage("isPaused") private var isPaused: Bool = false
    //刷新间隔 s
    @AppStorage("timeInterval") private var timeInterval = 1
    //视图文本
    @Published private var text:NSAttributedString = NSAttributedString(string: "添加")
    //更新视图计时器
    private var timer: Timer =  Timer()
    //总更新次数计数
    private var times = 0
    //状态栏
    private let statusItem = NSStatusBar.system.statusItem(withLength: CGFloat.init(180.0))
    
    //弹窗监视器
    private var monitor: Any?

    
    func updateStockInfo(text:NSAttributedString){
        self.text = text
        self.statusItem.button?.attributedTitle = self.text
    }
    
    let popover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusItem.menu = menu
        
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusIcon")
            button.attributedTitle = self.text
        }
        popover.contentViewController = AddStockViewController.initController()
    }
    
    @IBAction func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
                    if monitor != nil {
                        NSEvent.removeMonitor(monitor!)
                    }
                    monitor = nil
        } else {
            monitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown,.rightMouseDown] ){ [weak self] event in
                        if let strongSelf = self, strongSelf.popover.isShown {
                          strongSelf.closePopover(sender: event)
                        }
                    }
            showPopover(sender: sender)
        }
      }
    
      
            
      func showPopover(sender: Any?) {
        if let button = statusItem.button {
          popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
      }

      func closePopover(sender: Any?) {
          popover.performClose(sender)
      }

    @IBAction func quitApp(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    

    @IBAction func playButton(sender: AnyObject) {

        isPaused = false
        self.getData(codes:self.codes)
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeInterval), repeats: true, block: { [self] _ in
            self.times=self.times+1
            self.getData(codes:self.codes)
            })
    }


    @IBAction func stopButton(sender: AnyObject) {
        timer.invalidate()
    }


    // if it's currently paused, pressing on the pause button again should restart the counter from where it originally left off.

    @IBAction func pauseButton(sender: AnyObject) {

        if isPaused == false {

        timer.invalidate()
            isPaused = true
        } else if isPaused == true {
            isPaused = false
            timer.fire()
            //  timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
        }
    }


    @IBAction func resetButton(sender: AnyObject) {
        timer.invalidate()
    }

    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
 

    override init() {
        super.init()
//        self.statusItem.button?.contentTintColor = NSColor.white
//        startTimer()
    }

    func getData(codes:String){
        let url: String = "https://qt.gtimg.cn"
        //        let url: String = "https://www.weicaixun.com/pubapi1/get_gp_info"
        
        var codeParas = ""
        if let codesData = codes.data(using: .utf8){
            let json = try? JSON(data: codesData)
            codeParas = json!.arrayValue.map { $0["symbol"].stringValue }.joined(separator: ",")
        }
        
        let codeArr:[String] = codeParas.components(separatedBy: ",")
        let paras: [String:String] = ["q":codeParas]
        if codeParas.isEmpty{
            pauseButton(sender: NSNull.self)
            return
        }
        HTTP.GET(url, parameters: paras) { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            print("opt finished: \(response.description)")
//            # GBK编码, 使用GB18030是因为它向下兼容GBK
            let cfEnc = CFStringEncodings.GB_18030_2000
            let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
            let gbk = String.Encoding.init(rawValue: enc)
            
            let res:String  = String(data: response.data, encoding: gbk)!
            let resArr =  res.components(separatedBy: "~")
            var i = 0
            for code in codeArr {
                let index = resArr.firstIndex(of:code.replacingOccurrences(of: "sz", with: "").replacingOccurrences(of: "sh", with: ""))
                print(self.times)
                i=i+1
                if index != nil && self.times%i == 0{
                    print(index!)
                    let name = resArr[index!-1].padding(toLength: 4, withPad: " ", startingAt: 0)
                    let sell = resArr[index!+1].padding(toLength: 5, withPad: " ", startingAt: 0)
                    var updownrate = resArr[index!+30]                                            .padding(toLength: 6, withPad: " ", startingAt: 0)
                    
                    if !updownrate.contains("-") {
                        updownrate = "+"+updownrate
                    }
                        
                    let info = name+":"+sell+" "+updownrate
                    let infoAttribute = [NSAttributedString.Key.foregroundColor: NSColor.white]
                    let infoAttrString = NSAttributedString(string: info, attributes: infoAttribute)
                    DispatchQueue.main.async {
                        self.updateStockInfo(text:infoAttrString)
                    }
                }
                                            
                
            }
            
        }
        
    }
        
   
}

