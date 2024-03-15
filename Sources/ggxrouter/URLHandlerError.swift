//
//  URLHandlerError.swift
//  GXSwiftRouter
//
//  Created by 高广校 on 2024/3/13.
//

import Foundation

public enum URLHandlerError: Error {
    
    case urlstringError
    case ApplicationNoCan //app无法打开
    case pageError //缺少page
    case BundleError
    
    
    public var label: String {
        switch self {
        case .urlstringError:
            return "URL不对"
        case .ApplicationNoCan:
            return "无法打开"
        case .pageError:
            return "控制器未注册或没有此控制器"
        case .BundleError:
            return "bundle错误"
        }
    }
}
