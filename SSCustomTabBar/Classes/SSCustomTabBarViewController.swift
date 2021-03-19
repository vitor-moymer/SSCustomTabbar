//
//  SSCustomTabBarViewController.swift
//  SSCustomTabBar
//
//  Created by Sumit Goswami on 27/03/19.
//  Copyright © 2019 SimformSolutions. All rights reserved.
//

import UIKit


/// Default index value for priviousSelectedIndex
private let defaultIndexValue = -1

open class SSCustomTabBarViewController: UITabBarController {
    
    /// Tabbar height
    @IBInspectable var barHeight: CGFloat {
        get{
            return self.kBarHeight ?? self.tabBar.frame.height
        }
        set{
            self.kBarHeight = newValue
        }
    }
    
    /// icon up animation point
    @IBInspectable var upAnimationPoint: CGFloat {
        get{
            return self.kUpAnimationPoint
        }
        set{
            self.kUpAnimationPoint = newValue
            (self.tabBar as? SSCustomTabBar)?.upAnimationPoint = kUpAnimationPoint
        }
    }
    
    private var kBarHeight: CGFloat?
    
    private var kUpAnimationPoint: CGFloat = 8
    
    private var previousSelectedIndex: Int = defaultIndexValue
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        (self.tabBar as? SSCustomTabBar)?.upAnimationPoint = kUpAnimationPoint
        // Do any additional setup after loading the view.
    }
    
    /// Notifies the view controller that its view was added to a view hierarchy.
    ///
    /// - Parameter animated: variable for namiation
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.previousSelectedIndex == defaultIndexValue {
            if let item = self.tabBar.selectedItem {
                self.tabBar(self.tabBar, didSelect: item)
            }
        }
    }
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let items = tabBar.items   else {
            return
        }
        var i = 0
        for item in items {
            item.tag = i
            i +=  1
        }
    }
}


// MARK: - set bar height
extension SSCustomTabBarViewController {
    override public func viewWillLayoutSubviews() {
       changeTabBarHeight()
    }
    
    func changeTabBarHeight() {
        guard var height = kBarHeight, height > 0 else { return }
        height += self.view.safeAreaInsets.bottom
        var tabBarFrame = self.tabBar.frame
        tabBarFrame.size.height = height
        tabBarFrame.origin.y = UIScreen.main.bounds.height - height
        self.tabBar.frame = tabBarFrame
        self.tabBar.clipsToBounds = false
    }
}


// MARK: - Tabbar Delegate
extension SSCustomTabBarViewController {
    
    
    /// Sent to the delegate when the user selects a tab bar item.
    ///
    /// - Parameters:
    ///   - tabBar: The tab bar that is being customized.
    ///   - item: The tab bar item that was selected.
    override public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if let uSelf = self.tabBar as? SSCustomTabBar, let items = uSelf.items, let index = items.firstIndex(of: item), index != self.previousSelectedIndex {
            
            let width = UIScreen.main.bounds.width/CGFloat(items.count)
            let changeValue = (width*CGFloat(index+1))-(width/2)
            uSelf.animating = true
             
            let orderedTabBarItemViews: [UIView] = {
                let interactionViews = tabBar.subviews.filter({ $0 is UIControl })
                return interactionViews.sorted(by: { $0.frame.minX < $1.frame.minX })
            }()
            
            orderedTabBarItemViews.forEach({ (objectView) in
                let objectIndex = orderedTabBarItemViews.firstIndex(of: objectView)
                if index ==  objectIndex {
                    print(index)
                }else if  objectIndex == previousSelectedIndex {
                    UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
                        objectView.transform = CGAffineTransform.identity
                        /*
                        objectView.frame = CGRect(x: objectView.frame.origin.x, y: objectView.frame.origin.y + self.kUpAnimationPoint, width: objectView.frame.width, height: objectView.frame.height)*/
                        
                    }, completion: nil)
                }
            })
            DispatchQueue.main.async{ [weak self] in
                self?.previousSelectedIndex = index
                self?.performSpringAnimation(for: orderedTabBarItemViews[index], changeValue: changeValue)
            }
            
        }
        
    }
    
    
    /// Perform Animation
    ///
    /// - Parameters:
    ///   - view: going to up.
    ///   - changeValue: center location for wave.
    func performSpringAnimation(for view: UIView, changeValue: CGFloat) {
        
        if let uSelf = self.tabBar as? SSCustomTabBar {
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                uSelf.setDefaultlayoutControlPoints(waveHeight: uSelf.minimalHeight, locationX: changeValue)
                
            }, completion: { s in
                if s {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                           uSelf.animating = false
                    }
                }
               
            })
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
                
                view.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2).translatedBy(x: 0, y: -self.kUpAnimationPoint)
                /*
                view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y - self.kUpAnimationPoint, width: view.frame.width, height: view.frame.height)
                 */
            }, completion: { s in
                if s {
                     (self.tabBar as? SSCustomTabBar)?.canCorrectPositioning = true
                }
               
            })
        }
    }
    
}
