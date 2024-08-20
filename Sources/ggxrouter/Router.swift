//
//  Router.swift
//  ArtAIClassSwift
//
//  Created by Iann on 2019/12/7.
//  Copyright © 2019 meishubao.com. All rights reserved.
//

import Foundation
import UIKit
import GGXSwiftExtension

public protocol RouterProtocol {
    static func create(_ params:[String:Any]?) -> RouterProtocol?
}

//func QualityUrl(path: String) -> String {
//    if  gQualityURL.last != "/" && path.first != "/" {
//        return gQualityURL + "/" + path
//    }
//    return gQualityURL + path
//}
//
//func H5Url(path: String) -> String {
//    if  gH5BaseURL.last != "/" && path.first != "/" {
//        return gH5BaseURL + "/" + path
//    }
//    return gH5BaseURL + path
//}

@objc public class Router: NSObject {
    
    @objc public static let share = Router()
    
    //    @objc public static let universalUrl: String = "https://oabu.wecloudservice.com"
    
    static private var pages = [String:String]()
    
    public var scheme = ""
    
    public static func request(_ url: URL,
                               isPresent: Bool = false,
                               controller: UIViewController? = nil) throws -> Bool {
        
        //1、解析url中query参数
        var params : [String:Any] = [:]
        if let npa = url.queryParse() {
            params = npa
        }
        
        //判断url.host：web、open，看是否能够找到界面，URLScheme中称为动作，如果`动作`可以在配置
        var u_host = ""
        if #available(iOS 16.0, *) {
            if let _host = url.host() {
                u_host = _host
            }
        } else {
            // Fallback on earlier versions
            if let _host = url.host {
                u_host = _host
            }
        }
        if let vcname = Router.pages[u_host] {
            //从'page'中查找该动作`host`对应的页面，有的话实现跳转
            return try Router.share.openContoller(vcname, params: params)
        } else {
            //从参数中解析跳转的，需要用到path()
            let u_path = url.absoluteString.toPath
            let page =  u_path.pathComponents.last
            if let page {
                var newParams = [String:Any]()
                for (key,value) in params {
                    if key != "page" && key != "type" {
                        newParams[key] = value
                    }
                }
                print(newParams)
                
                return try Router.share.queryContoller(page, params:newParams)
            } else {
                //无法解析page
                print("host不得为空，或者增加参数page和page的值")
                throw URLHandlerError.pageError
            }
        }
    }
    
    //查询controller
    public func queryContoller(_ page:String, params:[String:Any]) throws -> Bool{
        guard let vcname = Router.pages[page] else {
            //            print("找不到合适的控制器")
            throw URLHandlerError.pageError
        }
        return try openContoller(vcname, params: params)
    }
    
    //跳转controller
    public func openContoller(_ vcName:String,params:[String:Any]) throws -> Bool {
        guard let projectName = Bundle.main.infoDictionary?["CFBundleName"] as? String else {
            throw URLHandlerError.BundleError
        }
        
        if let any = NSClassFromString(projectName + "." + vcName) as? RouterProtocol.Type,
           let vc = any.create(params) as? UIViewController {
            onNextPage(vc)
            return true
        } else {
            throw URLHandlerError.pageError
        }
    }
    
    private func onNextPage(_ toController:UIViewController,fromController:UIViewController? = nil,isPresnet:Bool = false)
    {
        var fromVC = fromController
        if fromVC == nil {
            fromVC = currentController
        }
        if fromVC?.isKind(of: UINavigationController.self) == true , let navVC = fromVC as? UINavigationController {
            navVC.pushViewController(toController, animated: true)
            return
        }
        if fromVC?.navigationController == nil {
            toController.modalPresentationStyle =  .fullScreen
            fromVC?.present(toController, animated: true, completion: nil)
            return
        }
        if isPresnet {
            toController.modalPresentationStyle =  .fullScreen
            fromVC?.present(toController, animated: true, completion: nil)
        } else {
            toController.modalPresentationStyle =  .fullScreen
            fromVC?.navigationController?.pushViewController(toController, animated:true)
        }
    }
    
    var currentController: UIViewController? {
        return UIApplication.rootWindow?.rootViewController
    }
}

extension Router {
    public static func initPages(_ sourse:[String:String]) {
        Router.pages = sourse
    }
    
    public static func initPages(_ plistname:String) {
        let pathName = plistname
        guard let path =  Bundle.main.path(forResource: pathName, ofType: nil) else {
            print("没有加载到路由配置文件")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        if let params = NSDictionary(contentsOf: url) as? [String:String] {
            Router.pages = params
        }
    }
}
