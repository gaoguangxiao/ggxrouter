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

@objc public class Router: NSObject {
    
    @objc public static let share = Router()
    
    //    @objc public static let universalUrl: String = "https://oabu.wecloudservice.com"
    
    static private var pages = [String:String]()
    
    //唯一性的控制器，仅存在一个，可pop返回
    public var uniquePages = [String]()
    
    //只有包含在uri的才可以跳转
    public var whiteUri = [String]()
    
    public var fromHomepage: UIViewController?
    
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
//        if #available(iOS 16.0, *) {
//            if let _host = url.host() {
//                u_host = _host
//            }
//        } else {
            if let _host = url.host {
                u_host = _host
            }
//        }
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
    public func openContoller(_ vcName:String,params:[String:Any], project: String? = nil) throws -> Bool {
        
        //获取params的path值，是否包含在白名单中
        let paramsData = RouterAppInfoModel.deserialize(from: params)
        if let path = paramsData?.path {
            //包括path，那么path必须有效
            var iscontains = false
            Router.share.whiteUri.forEach { element in
                if path.contains(element) {
                    iscontains = true
                }
            }
            guard iscontains else {
                throw URLHandlerError.pathError
            }
        }
        //模块间耦合
        guard var projectName = Bundle.main.infoDictionary?["CFBundleName"] as? String else {
            throw URLHandlerError.BundleError
        }
        if let project {
            projectName = project
        }
        
        //查看工程中是否存在控制器的类
        guard let projectClass = NSClassFromString(projectName + "." + vcName) else {
            throw URLHandlerError.pageError
        }
        
        //要显示的`vcName`属于主控制器
        if Router.share.uniquePages.contains(vcName) {
            //获取最上层的控制器
            let activeVc = UIApplication.visibleViewController
            guard let routerVc = activeVc as? RouterProtocol else {
                //请实现协议
                throw URLHandlerError.ApplicationNoCan
            }
            //判断最上层控制器是否是主控制器
            if let isMember = activeVc?.isMember(of: projectClass) , isMember == true{
                routerVc.reloadCreate(params)
                //属于的话直接刷新，否则仅
                print("当前控制器是主控制器:\(projectClass)")
                return true
            }
            //最上层的控制器非主控制器，那么实现pop返回
            if let navVC = activeVc?.navigationController as? UINavigationController {
                print("当前控制器非主控制器:\(navVC)")
                var mainVc: RouterProtocol?
                //在栈中遍历，判断是否具有`maniVc`
                navVC.viewControllers.forEach { element in
                    let isMainVc = element.isMember(of: projectClass)
                    if isMainVc,
                       let routerVc = element as? RouterProtocol {
                        mainVc = routerVc
                    }
                }
                
                //找到`mainVc`，刷新此页数据
                if let mainVc, let activeVc {
                    if routerVc.present {
                        PushTransition.dismissRootWithTransition(VC: activeVc)
                    } else {
                        activeVc.popToRoot()
                    }
//                    print("目标主控制器:\(mainVc)")
                    //并刷新数据
                    mainVc.reloadCreate(params)
                    return true
                }
            }
        }
        
        //如果`vcName`是主控制器
        if let any = NSClassFromString(projectName + "." + vcName) as? RouterProtocol.Type,
           let vc = any.create(params) as? UIViewController {
            var present = false
            if let pt = paramsData?.present {
                present = pt
            }
            onNextPage(vc,isPresent: present)
            return true
        } else {
            throw URLHandlerError.pageError
        }
    }
    
    private func onNextPage(_ toController:UIViewController,fromController:UIViewController? = nil,isPresent:Bool = false)
    {
        let fromVC = UIApplication.visibleViewController
        if let navVC = fromVC?.navigationController as? UINavigationController,
           let fromVC {
            if isPresent {
                PushTransition.pushWithTransition(fromVC: fromVC, toVC: toController, type: .fromBottom, duration: 0.5)
            } else {
                navVC.pushViewController(toController, animated: true)
            }
            return
        }
        
        
        if isPresent {
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
