//
//  RouterProtocol.swift
//  GXSwiftRouter
//
//  Created by 高广校 on 2025/4/1.
//

import Foundation

public protocol RouterProtocol {
    
    //1:present弹出风格，默认:push推入效果
    var present: Bool {set get}
    
    static func create(_ params:[String:Any]?) -> RouterProtocol?
    
    //reload参数
    func reloadCreate(_ params:[String:Any]?)
    
}
