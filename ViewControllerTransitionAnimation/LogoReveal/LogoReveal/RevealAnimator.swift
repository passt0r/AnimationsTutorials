//
//  RevealAnimator.swift
//  LogoReveal
//
//  Created by Dmytro Pasinchuk on 02.05.18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit

class RevealAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, CAAnimationDelegate {
    let animationDuration = 2.0
    var operation = UINavigationControllerOperation.push
    var interactive = false
    weak var storedContext: UIViewControllerContextTransitioning?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        storedContext = transitionContext
        if operation == .push {
        let fromVC = transitionContext.viewController(forKey: .from) as! MasterViewController
        let toVC = transitionContext.viewController(forKey: .to) as! DetailViewController
        transitionContext.containerView.addSubview(toVC.view)
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue =
            NSValue(caTransform3D: CATransform3DIdentity)
        animation.toValue = NSValue(caTransform3D: CATransform3DConcat(CATransform3DMakeTranslation(0.0, -10.0, 0.0), CATransform3DMakeScale(150.0, 150.0, 1.0)))
        animation.duration = animationDuration
        animation.delegate = self
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseIn)
        
        let maskLayer: CAShapeLayer = RWLogoLayer.logoLayer()
        maskLayer.position = fromVC.logo.position
        toVC.view.layer.mask = maskLayer
        maskLayer.add(animation, forKey: nil)
        fromVC.logo.add(animation, forKey: nil)
            
        let fadeAnimation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.duration = animationDuration
        fadeAnimation.fromValue = 0.0
        fadeAnimation.toValue = 1.0
        toVC.view.layer.add(fadeAnimation, forKey: nil)
        } else {
            let from = transitionContext.view(forKey: .from)!
            let to = transitionContext.view(forKey: .to)!
            
            transitionContext.containerView.insertSubview(to, belowSubview: from)
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseIn, animations: {
                from.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }) { (complete) in
                transitionContext.completeTransition(complete)
            }
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let context = storedContext {
            context.completeTransition(!context.transitionWasCancelled)
            let fromVC = context.viewController(forKey: .from)
                as! MasterViewController
            fromVC.logo.removeAllAnimations()
            let toVC = context.viewController(forKey: .to)
                as! DetailViewController
            toVC.view.layer.mask = nil
        }
        storedContext = nil
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: recognizer.view!.superview!)
        var progress: CGFloat = abs(translation.x / 200.0)
        progress = min(max(progress, 0.01), 0.99)
        
        switch recognizer.state {
        case .changed:
            update(progress)
        case .cancelled, .ended:
            let transitionLayer = storedContext!.containerView.layer
            if operation == .push {
                transitionLayer.beginTime = CACurrentMediaTime()
            }
            if progress < 0.5 {
                cancel()
                if operation == .push {
                    transitionLayer.speed = -1.0
                }
            } else {
                if operation == .push {
                    transitionLayer.speed = 1.0
                }
                finish()
            }
            interactive = false
        default:
            break
        }
    }
    

}
