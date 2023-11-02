//
//  Router.swift
//  ArtAIClassSwift
//
//  Created by Iann on 2019/12/7.
//  Copyright © 2019 meishubao.com. All rights reserved.
//

import Foundation
import UIKit


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
        
    @objc public static func request(_ url:URL?,isPresent:Bool = false,
                                     controller:UIViewController? = nil) {
        
        guard let url = url else {
            return
        }
        
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
            Router.share.openContoller(vcname, params: params)
        } else {
            //从参数中解析跳转的，需要用到page，如果
            if let page = params["page"] as? String {
                var newParams = [String:Any]()
                for (key,value) in params {
                    if key != "page" && key != "type" {
                        newParams[key] = value
                    }
                }
                print(newParams)
                
                Router.share.queryContoller(page, params:newParams)
            } else {
                //无法解析page
                print("host不得为空，或者增加参数page和page的值")
            }
        }
    }
    
    //查询controller
    public func queryContoller(_ page:String,params:[String:Any]) {
        guard let vcname = Router.pages[page] else {
            print("找不到合适的控制器")
            return
        }
        openContoller(vcname, params: params)
    }
    
    //跳转controller
    public func openContoller(_ vcName:String,params:[String:Any]) {
        guard let projectName = Bundle.main.infoDictionary?["CFBundleName"] as? String  else {
            return
        }
        
        if let any = NSClassFromString(projectName + "." + vcName) as? RouterProtocol.Type {
            if let vc = any.create(params) as? UIViewController {
                onNextPage(vc)
            }
        }
    }
    
    private func onNextPage(_ toController:UIViewController,fromController:UIViewController? = nil,isPresnet:Bool = false)
    {
        var fromVC = fromController
        if fromVC == nil {
            fromVC = currentController
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
    
    var currentController:UIViewController? {
        let rootVC = getRootController()
        return getTopController(rootVC)
    }

    
    private func getTopController(_ controller:UIViewController? = nil) -> UIViewController? {
        guard let vc = controller else { return nil }
        if let presentVC = vc.presentedViewController {
            return getTopController(presentVC)
        } else if let tabVC = vc as? UITabBarController {
            return getTopController(tabVC.selectedViewController)
        } else if let nav = vc as? UINavigationController {
            return getTopController(nav.visibleViewController)
        } else {
            return vc
        }
    }
    
    private func getRootController() -> UIViewController? {
        var window: UIWindow?
        if #available(iOS 13.0, *) {
            let windowScenes = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene}).compactMap({$0})
            outer: for s in windowScenes {
                for w in s.windows where w.isMember(of: UIWindow.self) {
                    window = w
                    break outer
                }
            }
        }
        window = window ?? UIApplication.shared.windows.first
        if let vc = window?.rootViewController {
            return vc
        }
        return nil
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
