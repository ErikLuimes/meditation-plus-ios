//
//  MPProfileViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/11/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit

class MPProfileViewController: UIViewController {
    private var profileView: MPProfileView { return view as! MPProfileView }
    
    private var username: String!
    
    private var profileManager: MPProfileManager = MPProfileManager.sharedInstance
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, username: String) {
        super.init(nibName: nibNameOrNil, bundle: nil)
        self.username = username
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileManager.profile(username) { (profile) -> Void in
            self.profileView.configureWithProfile(profile)
        }
    }

}
