//
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import Foundation
import Cartography


// This class wraps the conversation content view controller in order to display the navigation bar on the top
@objc open class ConversationRootViewController: UIViewController {
    
    fileprivate(set) var customNavBar : UINavigationBarContainer?
    fileprivate var contentView = UIView()
    var navHeight : NSLayoutConstraint?
    var networkStatusBarHeight : NSLayoutConstraint?

    fileprivate let networkStatusViewController: NetworkStatusViewController

    open fileprivate(set) weak var conversationViewController: ConversationViewController?
    
    public init(conversation: ZMConversation, clientViewController: ZClientViewController) {
        let conversationController = ConversationViewController()
        conversationController.conversation = conversation
        conversationController.zClientViewController = clientViewController

        networkStatusViewController = NetworkStatusViewController()
        
        super.init(nibName: .none, bundle: .none)
        
        self.addChildViewController(conversationController)
        self.contentView.addSubview(conversationController.view)
        conversationController.didMove(toParentViewController: self)
        
        conversationViewController = conversationController

        configure()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func configure() {
        guard let conversationViewController = self.conversationViewController else {
            return
        }
        
        self.view.backgroundColor = ColorScheme.default().color(withName: ColorSchemeColorBarBackground)
        
        let navbar = UINavigationBar()///TODO: animation height
        navbar.isTranslucent = false
        navbar.isOpaque = true
        navbar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        navbar.shadowImage = UIImage()
        navbar.barTintColor = ColorScheme.default().color(withName: ColorSchemeColorBarBackground)
        
        self.customNavBar = UINavigationBarContainer(navbar)
        
        self.view.addSubview(self.customNavBar!)
        self.view.addSubview(self.contentView)
        self.addChild(networkStatusViewController)

        [networkStatusViewController.view, navbar, self.contentView].forEach{view in
            view.translatesAutoresizingMaskIntoConstraints = false}

        constrain(self.customNavBar!, self.view, self.contentView, conversationViewController.view, networkStatusViewController.view) { (customNavBar: LayoutProxy, view: LayoutProxy, contentView: LayoutProxy, conversationViewControllerView: LayoutProxy, networkStatusViewControllerView: LayoutProxy) -> () in
            
            networkStatusViewControllerView.top == view.top + UIScreen.safeArea.top
            networkStatusViewControllerView.left == view.left
            networkStatusViewControllerView.right == view.right
//                        networkStatusBarHeight = networkStatusViewControllerView.height == OfflineBar.expandedHeight

            customNavBar.top == networkStatusViewControllerView.top
            customNavBar.left == view.left
            customNavBar.right == view.right
//            navHeight = customNavBar.height == 100 ~(750) ///TODO: remove

            contentView.left == view.left
            contentView.right == view.right
            contentView.bottom == view.bottom - UIScreen.safeArea.bottom
            contentView.top == customNavBar.bottom
            
            conversationViewControllerView.edges == contentView.edges
        }
        
        self.customNavBar!.navigationBar.pushItem(conversationViewController.navigationItem, animated: false)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delay(0.4) {
            UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(true)
        }

        ///FIXME: test animation here
//        navHeight?.constant = 150
//        networkStatusBarHeight?.constant = 40

//        UIView.animate(withDuration: 2) {
//            self.view.layoutIfNeeded()
//        }
    }
    
    open override var prefersStatusBarHidden : Bool {
        return false
    }
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        switch ColorScheme.default().variant {
        case .light:
            return .default
        case .dark:
            return .lightContent
        }
    }
}
