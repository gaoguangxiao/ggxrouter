//
//  PushTransition.swift
//  KidReading
//
//  Created by zoe on 2019/9/6.
//  Copyright © 2019 putao. All rights reserved.
//

import Foundation


import UIKit

public class PushTransition: NSObject {
    
    enum `Type` {
        case scale
        case formTop
        case fromBottom
        case dismiss

    }
    
    private let ScreenWidth = UIScreen.main.bounds.size.width
    private let ScreenHeight = UIScreen.main.bounds.size.height
    
    static private var duration = 0.5
    static private var type: Type = .scale
    // 设置转场代理
    static var transition = PushTransition()
    
    /// 带动画的push
    ///
    /// - Parameters:
    ///   - fromVC: 发起push操作的VC
    ///   - toVC: 即将被push出来的VC
    ///   - type: 需要哪种动画
    ///   - duration: 动画执行的时间
    static func pushWithTransition(fromVC: UIViewController,
                                   toVC: UIViewController,
                                   type: Type = .fromBottom,
                                   duration: Double = 0.5) {
        self.type = type
        self.duration = duration
        fromVC.navigationController?.delegate = PushTransition.transition
        fromVC.navigationController?.pushViewController(toVC, animated: true)
        fromVC.navigationController?.delegate = nil
    }
    
    public static func dismissWithTransition(VC: UIViewController,
                                   duration: Double = 0.5) {
        self.type = .dismiss
        self.duration = duration
        VC.navigationController?.delegate = PushTransition.transition
        VC.navigationController?.popViewController(animated: true)
        VC.navigationController?.delegate = nil
    }
    
    public static func dismissRootWithTransition(VC: UIViewController,
                                   duration: Double = 0.5) {
        self.type = .dismiss
        self.duration = duration
        VC.navigationController?.delegate = PushTransition.transition
        VC.navigationController?.popToRootViewController(animated: true)
        VC.navigationController?.delegate = nil
    }
}

extension PushTransition: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return PushTransition.duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        
        guard let fromView = fromVC?.view,
            let toView = toVC?.view else {
                return
        }
        
        switch PushTransition.type {
        case .scale:
            scale(fromView: fromView,
                  toView: toView,
                  transitionContext: transitionContext)
        case .formTop:
            fromTop(fromView: fromView,
                    toView: toView,
                    transitionContext: transitionContext)
        case .fromBottom:
            fromBottom(fromView: fromView,
                       toView: toView,
                       transitionContext: transitionContext)
        case .dismiss:
            dismiss(fromView: fromView,
                    toView: toView,
                    transitionContext: transitionContext)
            
        }
    }
}

extension PushTransition: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return PushTransition()
    }
}

extension PushTransition {
    
    /// 缩放的push
    ///
    /// - Parameters:
    ///   - fromView: 发起push操作的VC的View
    ///   - toView: 即将被push出来的VC的view
    ///   - transitionContext: 上下文
    private func scale(fromView: UIView,
                       toView: UIView,
                       transitionContext: UIViewControllerContextTransitioning)
    {
        transitionContext.containerView.addSubview(toView)
        transitionContext.containerView.bringSubviewToFront(fromView)
        
        UIView.animate(withDuration: PushTransition.duration, animations: {
            
            fromView.alpha = 0
            fromView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            toView.alpha = 1.0
            
        }) { (_) in
            
            fromView.transform = CGAffineTransform(scaleX: 1, y: 1)
            transitionContext.completeTransition(true)
            fromView.alpha = 1.0
        }
    }
    
    /// 从上到下的push
    ///
    /// - Parameters:
    ///   - fromView: 发起push操作的VC的View
    ///   - toView: 即将被push出来的VC的view
    ///   - transitionContext: 上下文
    private func fromTop(fromView: UIView,
                         toView: UIView,
                         transitionContext: UIViewControllerContextTransitioning)
    {
        transitionContext.containerView.addSubview(toView)
        
        toView.transform = CGAffineTransform(translationX: 0,
                                             y: -self.ScreenHeight)
        UIView.animate(withDuration: PushTransition.duration, animations: {
            toView.transform = CGAffineTransform(translationX: 0, y: 0)
            toView.alpha = 1.0
            
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
    
    /// 从下往上的push
    ///
    /// - Parameters:
    ///   - fromView: 发起push操作的VC的View
    ///   - toView: 即将被push出来的VC的view
    ///   - transitionContext: 上下文
    private func fromBottom(fromView: UIView,
                            toView: UIView,
                            transitionContext:  UIViewControllerContextTransitioning)
    {
        transitionContext.containerView.addSubview(toView)
        
        toView.transform = CGAffineTransform(translationX: 0,
                                             y: self.ScreenHeight)
        UIView.animate(withDuration: PushTransition.duration, animations: {
            toView.transform = CGAffineTransform(translationX: 0, y: 0)
            toView.alpha = 1.0
            
        }) { (_) in
            transitionContext.completeTransition(true)
        }
        
    }
    
    /// 从下往上的push
    ///
    /// - Parameters:
    ///   - fromView: 发起push操作的VC的View
    ///   - toView: 即将被push出来的VC的view
    ///   - transitionContext: 上下文
    private func dismiss(fromView: UIView,
                         toView: UIView,
                         transitionContext:  UIViewControllerContextTransitioning)
    {
        transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
        UIView.animate(withDuration: PushTransition.duration, animations: {
            fromView.transform = CGAffineTransform(translationX: 0,
                                                   y: self.ScreenHeight)
            fromView.alpha = 0
        }) { (_) in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
        
    }
}
