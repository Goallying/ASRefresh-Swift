//
//  ASRefresh.swift
//  HotelProject
//
//  Created by Lifee on 2019/10/10.
//  Copyright © 2019 ASWorld. All rights reserved.
//

import UIKit

private var headerKey = "headerKey"
private var footerKey = "footerKey"

enum State : Int{
    case idle = 1
    case pulling
    case refreshing
}

extension UIScrollView {
    var as_state:State {
        get {
            return as_header?.state ?? .idle
        }
    }
    
    var as_header:ASRefreshHeaderView?{
        set {
            objc_setAssociatedObject(self, &headerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let view = newValue {
                self.insertSubview(view, at: 0)
            }
        }
        get {
            return objc_getAssociatedObject(self, &headerKey) as? ASRefreshHeaderView
        }
    }
    
    var as_footer:ASRefreshFooterView?{
        set {
            objc_setAssociatedObject(self, &footerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let view = newValue {
                self.insertSubview(view, at: 0)
            }
        }
        get {
            return objc_getAssociatedObject(self, &footerKey) as? ASRefreshFooterView
        }
    }
    
    func as_stopAnimating(){
        
        if let st = as_header?.state ,st == .refreshing{
            as_header?.state = .idle
        }else if let st = as_footer?.state , st == .refreshing {
            as_footer?.state = .idle
        }
    }
    
}

