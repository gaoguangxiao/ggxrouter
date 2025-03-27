//
//  RouterAppInfoModel.swift
//  GXSwiftRouter
//
//  Created by 高广校 on 2025/3/27.
//

import Foundation
import SmartCodable

//外部打开app，app解析的数据
//每个控制器都有自己的方向
public enum OrientationType : String {
    case landscape    //横屏
    case portrait     //竖屏
}

public struct RouterAppInfoModel: SmartCodable {
    public var path: String?
    
    //App横竖屏方向
    public var orientation: String?
    
    /// 默认false
    public var hideTopBar: Bool = false
    
    ///默认false
    public var present: Bool = false
    
    public init(){}
}
