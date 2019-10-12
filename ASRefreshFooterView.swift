//
//  ASRefreshHeaderView.swift
//  HotelProject
//
//  Created by Lifee on 2019/10/10.
//  Copyright © 2019 ASWorld. All rights reserved.
//

import UIKit


class ASRefreshFooterView: UIView {
    
    private let kASRefreshFooterViewHeight:CGFloat = 54
    private var completion:()->Void?
    private var orginalInset:UIEdgeInsets!
    private weak var scrollView:UIScrollView!
    private var panGesture:UIPanGestureRecognizer!
    private var activityView:UIActivityIndicatorView!
    private var titleLabel:UILabel!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(footerActivity:@escaping ()->Void) {
        
        state = .idle
        completion = footerActivity
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
            
            self.height = kASRefreshFooterViewHeight
            
            addObersers()
        }
        
    }
    private func addObersers() {
        
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions(rawValue: NSKeyValueObservingOptions.new.rawValue | NSKeyValueObservingOptions.old.rawValue), context: nil)
        scrollView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions(rawValue: NSKeyValueObservingOptions.new.rawValue | NSKeyValueObservingOptions.old.rawValue), context: nil)

//        panGesture.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions(rawValue: NSKeyValueObservingOptions.new.rawValue | NSKeyValueObservingOptions.old.rawValue), context: nil)
    }
    private func removeObservers(){
        superview?.removeObserver(self, forKeyPath: "contentOffset")
        superview?.removeObserver(self, forKeyPath: "contentSize")

//        panGesture?.removeObserver(self, forKeyPath: "state")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        print("offset ==== \(scrollView.contentOffset.y) ,drag ----- \(scrollView.isDragging)")
        if keyPath == "contentSize" {
            self.top = max(scrollView.contentSize.height, scrollView.height)
        }
        if scrollView.contentOffset.y <= offsetToSeeFooter() {
            return
        }
    
        if keyPath == "contentOffset" && state != .refreshing{
            contentOffsetDidChange(change: change)
        }
    }
    private func contentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?){

        if scrollView.isDragging {
            
            let exactly = offsetToSeeFooter() + self.height
            
            if state == .idle &&
               scrollView.contentOffset.y > exactly {
                
                state = .pulling
            }
            else if state == .pulling &&
                scrollView.contentOffset.y <= exactly {
                
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
                titleLabel.text = "上拉加载"
                
            }else if newValue == .pulling {
                
                titleLabel.text = "松手加载更多"
                
            }else if newValue == .refreshing {
                //to do something
                var inset = self.orginalInset
                if scrollView.contentSize.height < scrollView.height {
                    inset!.bottom = self.scrollView.height - self.scrollView.contentSize.height + self.height

                }else{
                    inset!.bottom += self.height
                }
                UIView.animate(withDuration: 0.25) {
                    self.scrollView?.contentInset = inset!
                }
                activityView.startAnimating()
                titleLabel.text = "正在加载..."
                completion()
            }
        }
    }
    private func heightOutOfView() -> CGFloat {
        let h = scrollView.height - orginalInset.bottom - orginalInset.top
        return scrollView.contentSize.height - h;
    }
    private func offsetToSeeFooter() ->CGFloat {
        let deltaH = heightOutOfView()
        if  (deltaH > 0) {
            return deltaH - orginalInset.top;
        } else {
            return -orginalInset.top;
        }
    }

    lazy var contentView:UIView = {
        
        let contentView = UIView()
        contentView.autoresizingMask = .flexibleWidth
        contentView.backgroundColor = .yellow
        
        self.titleLabel = UILabel()
        self.titleLabel.text = "上拉加载"
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
