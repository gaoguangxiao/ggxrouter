//
//  ViewController.swift
//  GXSwiftRouter
//
//  Created by 小修 on 11/02/2023.
//  Copyright (c) 2023 小修. All rights reserved.
//

import UIKit
import GXSwiftRouter

let schemeName = "adventure"

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //参看设计文章 https://sspai.com/post/44591
    }

    @IBAction func 动作跳转(_ sender: Any){
        //动作web有值，那么page之后的值会失效，以web寻址为主，找不到才会寻找page
//        OpenURLHandler.handlerString("\(schemeName)://web?page=test1")
        
        do {
            try OpenURLHandler.handlerString("\(schemeName)://web?url=https://www.baidu.com")
        } catch {
            if let e = error as? URLHandlerError {
                print("error:\(e.label))")
            }
        }
        
    }
    
    //:///代表了跳转界面
    @IBAction func 无参跳转(_ sender: Any) {
        let _ = try? OpenURLHandler.handlerString("\(schemeName)://test1")
    }
    
//adventure:///web?path=https%3A%2F%2Fwww.risekid.cn%2Fpolicy%2FuserProtocal.html
    @IBAction func 有参数跳转(_ sender: Any) {
        // /web本身代表了跳转 web页
        let url = "\(schemeName):///web?path=http%3A%2F%2Fwww.risekid.cn%2Fpolicy%2FuserProtocal.html"
        do {
            try OpenURLHandler.handlerString(url)
        } catch {
            if let e = error as? URLHandlerError {
                print("error:\(e.label))")
            }
        }
//        try? OpenURLHandler.handlerString("\(schemeName)://open?page=web&Id=1&name=ggx&url=https://www.baidu.com")
    }
    
    @IBAction func 错误跳转(_ sender: Any) {
        //跳转需要携带page参数，表示跳转的视图
        try? OpenURLHandler.handlerString("\(schemeName)://open?Id=1&name=ggx")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

