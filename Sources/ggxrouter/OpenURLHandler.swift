//
//  OpenURLHandler.swift
//  ArtAIClassSwift
//
//  Created by Iann on 2019/12/20.
//  Copyright © 2019 ggx.com. All rights reserved.
//

import Foundation
import UIKit

@objcMembers
public class OpenURLHandler: NSObject {
    
    public static let share = OpenURLHandler()

//    @available(iOS 13.0.0/*,*/ *)
    @discardableResult
    public static func handlerString(_ absoluteurl:String) throws -> Bool {
        guard let url = URL(string: absoluteurl) else {
            throw URLHandlerError.urlstringError
        }
        return try OpenURLHandler.share.handler(url)
    }
    
    @discardableResult
    public func handler(_ url:URL) throws -> Bool {

        if url.isApp {
            return try Router.request(url)
        } else {
            if UIApplication.shared.canOpenURL(url)  {
                UIApplication.shared.open(url, options: [:]) { (_) in
                    
                }
                return true
            } else {
                throw URLHandlerError.ApplicationNoCan
            }
        }
    }
}

public extension URL {
    var isApp: Bool {
        guard let scheme = self.scheme else {
            return false
        }
        //app内部打开界面，如果不是app需要支持app打开外部，比如wx等平台，那么就需要配置scheme
        if scheme == Router.share.scheme {
            return true
        }
        return false
    }
    
    func parsePushUrl(_ url : String) -> [String : Any] {
        var result : [String : String] = [:]
        let comps = url.components(separatedBy: "&")
        for subUrl in comps {
            let subComps = subUrl.components(separatedBy: "=")
            if subComps.count == 2 {
                let key = subComps[0]
                result[key] = subComps[1].removingPercentEncoding
            }
        }
        return result
    }
    
    func queryParse() -> [String:Any]?{
        guard let string = query else {
            return nil
        }
        return parsePushUrl(string)
    }
    
}
