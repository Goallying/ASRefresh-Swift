//
//  ASRefreshHeaderView.swift
//  HotelProject
//
//  Created by Lifee on 2019/10/10.
//  Copyright © 2019 ASWorld. All rights reserved.
//

import UIKit


class ASRefreshHeaderView: UIView {
    
    private let kASRefreshHeaderViewHeight:CGFloat = 54
    private var completion:()->Void?
    private var orginalInset:UIEdgeInsets!
    private weak var scrollView:UIScrollView!
    private var panGesture:UIPanGestureRecognizer!
    private var activityView:UIActivityIndicatorView!
    private var titleLabel:UILabel!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(headerActivity:@escaping ()->Void) {
        
        state = .idle
        completion = headerActivity
        super.init(frame: CGRect())
    
        self.autoresizingMask = .flexibleWidth
        self.addSubview(contentView)
        contentView.snp.makeConstraints {(make) in
            make.edges.equalTo(self)
        }
        
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        
        super.willMove(toSuperview: newSuperview)
        if let s = newSuperview?.isKind(of: UIScrollView.self) , s == false{
            return
        }
        removeObservers()
        if let newValue  = newSuperview{
            scrollView = (newValue as! UIScrollView)
            scrollView.alwaysBounceVertical = true
            
            panGesture = scrollView.panGestureRecognizer
            orginalInset = scrollView.contentInset
            
            self.height = kASRefreshHeaderViewHeight
            self.top = -self.height - orginalInset.top
            
            addObersers()
        }
        
    }
    private func addObersers() {
        
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions(rawValue: NSKeyValueObservingOptions.new.rawValue | NSKeyValueObservingOptions.old.rawValue), context: nil)
//        panGesture.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions(rawValue: NSKeyValueObservingOptions.new.rawValue | NSKeyValueObservingOptions.old.rawValue), context: nil)
    }
    private func removeObservers(){
        superview?.removeObserver(self, forKeyPath: "contentOffset")
//        panGesture?.removeObserver(self, forKeyPath: "state")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        print("offset ==== \(scrollView.contentOffset.y) ,drag ----- \(scrollView.isDragging)")
        if scrollView.contentOffset.y > -orginalInset.top {
             //向上滑动
             return
        }
        if keyPath == "contentOffset" && state != .refreshing {
            contentOffsetDidChange(change: change)
        }
    }
    private func contentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?){

        if scrollView.isDragging {
            
            if state == .idle &&
               (scrollView.contentOffset.y + orginalInset.top) < -self.height {
                
                state = .pulling
            }
            else if state == .pulling &&
                (scrollView.contentOffset.y + orginalInset.top) >= -self.height {
                
                state = .idle
            }
            
        }else if state == .pulling {
            state = .refreshing
        }
        
    }
     var state:State {
        
        willSet {
            
            if newValue == .idle{
                
                UIView.animate(withDuration: 0.25) {
                    self.scrollView.contentInset = self.orginalInset
                }
                activityView.stopAnimating()
                titleLabel.text = "下拉刷新"
                
            }else if newValue == .pulling {
                
                titleLabel.text = "松手刷新"
                
            }else if newValue == .refreshing {
                //to do something
                
                UIView.animate(withDuration: 0.25) {
                    var inset = self.orginalInset
                    inset!.top += self.height
                    self.scrollView?.contentInset = inset!
                }
                
                activityView.startAnimating()
                titleLabel.text = "刷新中..."
                completion()
            }
        }
    }

    lazy var contentView:UIView = {
        
        let contentView = UIView()
        contentView.autoresizingMask = .flexibleWidth
        contentView.backgroundColor = .red
        
        self.titleLabel = UILabel()
        self.titleLabel.text = "下拉刷新"
        self.titleLabel.textColor = .hex(0x333333)
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = .systemFont(ofSize: 14)
        contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.center.equalTo(contentView.snp.center)
        }
        
        self.activityView = UIActivityIndicatorView(style: .gray)
        self.activityView.hidesWhenStopped = true
        contentView.addSubview(self.activityView)
        self.activityView.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.titleLabel.snp.leading).offset(-5)
            make.centerY.equalTo(self.titleLabel.snp.centerY)
        }
        return contentView
    }()


    deinit {
        print("refresh deinit")
    }
}
