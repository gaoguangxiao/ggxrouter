//
//  ViewController.swift
//  GXSwiftRouter
//
//  Created by 小修 on 11/02/2023.
//  Copyright (c) 2023 小修. All rights reserved.
//

import UIKit
import GXSwiftRouter

let schemeName = "appscheme"

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //参看设计文章 https://sspai.com/post/44591
    }

    @IBAction func 动作跳转(_ sender: Any){
        //动作web有值，那么page之后的值会失效，以web寻址为主，找不到才会寻找page
//        OpenURLHandler.handlerString("\(schemeName)://web?page=test1")
        OpenURLHandler.handlerString("\(schemeName)://web?url=https://www.baidu.com")
    }
    
    @IBAction func 无参跳转(_ sender: Any) {
        OpenURLHandler.handlerString("\(schemeName)://open?page=test1")
    }
    
    @IBAction func 有参数跳转(_ sender: Any) {
        OpenURLHandler.handlerString("\(schemeName)://open?page=test2&Id=1&name=ggx")
    }
    
    @IBAction func 错误跳转(_ sender: Any) {
        //跳转需要携带page参数，表示跳转的视图
        OpenURLHandler.handlerString("\(schemeName)://open?Id=1&name=ggx")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

