//
//  MPMeditatorListViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit

class MPMeditatorListViewController: UIViewController {
    private let meditatorManager = MPMeditatorManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.meditatorManager.meditatorList(failure: { (error) -> Void in
            NSLog("error: \(error)")
        }) { (meditators) -> Void in
            NSLog("meditators: \(meditators)")
        }
        self.view.backgroundColor = UIColor.orangeColor()
        // Do any additional setup after loading the view.
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
