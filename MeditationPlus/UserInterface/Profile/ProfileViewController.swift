//
//  ProfileViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/11/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    private var profileView: ProfileView
    {
        return view as! ProfileView
    }
    
    private var username: String!
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, username: String) {
        super.init(nibName: nibNameOrNil, bundle: nil)
        self.username = username
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
