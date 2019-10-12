# ASRefresh-Swift
 基础刷新控件实现
MJRefresh 最核心的代码实现.已经在自己项目中使用


Using like this :
        weak var weakSelf = self
        self.tableView.as_header = ASRefreshHeaderView(headerActivity: {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                weakSelf?.tableView.as_stopAnimating()
            }
        })
        
        self.tableView.as_footer = ASRefreshFooterView(footerActivity: {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                weakSelf?.tableView.as_stopAnimating()
            }
        })
 welcome to give your suggestions! thanks
