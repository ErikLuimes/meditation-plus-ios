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
    
    private var meditator: MPMeditator!
    
    private var profileManager: MPProfileManager = MPProfileManager.sharedInstance
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, meditator: MPMeditator) {
        super.init(nibName: nibNameOrNil, bundle: nil)
        self.meditator = meditator
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileManager.profile(meditator.username) { (profile) -> Void in
            self.profileView.configureWithProfile(profile, meditator: self.meditator)
        }
    }

}
