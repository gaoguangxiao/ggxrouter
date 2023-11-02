//
//  WebViewController.swift
//  GXSwiftRouter_Example
//
//  Created by 高广校 on 2023/11/2.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class WebViewController: RouterBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "web"
        
        view.backgroundColor = .yellow
    }
    
    override func queryParams(params: [String : Any]) {
        print("可以加载的\(params["url"])")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
