//
//  RouterBaseViewController.swift
//  GXSwiftRouter_Example
//
//  Created by 高广校 on 2023/11/2.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import GXSwiftRouter
class RouterBaseViewController: UIViewController , RouterProtocol{

    static func create(_ params: [String : Any]?) -> GXSwiftRouter.RouterProtocol? {
        let vc = self.init()
        if let data = params {
            vc.queryParams(params: data)
        }
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func queryParams(params:[String:Any]) {
        
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
