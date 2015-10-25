//
//  MPQuoteViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 24/10/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit

class MPQuoteViewController: UIViewController {
    private var quoteView: MPQuoteView { return self.view as! MPQuoteView }
    private let quoteManager: MPQuoteManager = MPQuoteManager()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        tabBarItem = UITabBarItem(title: "Quote", image: UIImage(named: "BookIcon"), tag: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        quoteManager.retrieveQuote({[weak self] (quote) -> Void in
            self?.quoteView.configureWithQuote(quote)
        })
    }
}
