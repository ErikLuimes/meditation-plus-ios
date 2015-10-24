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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        quoteManager.retrieveQuote({[weak self] (quote) -> Void in
            self?.quoteView.configureWithQuote(quote)
        })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
