//
//  ProfileViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/11/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit
import RealmSwift

class ProfileViewController: UIViewController
{
    private var profileView: ProfileView
    {
        return view as! ProfileView
    }
    
    private var profileContentProvider: ProfileContentProvider!
    
    private var username: String!
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, username: String)
    {
        super.init(nibName: nibNameOrNil, bundle: nil)
        self.username = username
        self.profileContentProvider = ProfileContentProvider(profileService: ProfileService.sharedInstance)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileContentProvider.notificationBlock = {
            (changes: RealmCollectionChange<Results<Profile>>) in
            
            if let profile = changes.results?.first {
                self.profileView.configureWithProfile(profile)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.profileContentProvider.fetchContentIfNeeded(username)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.profileContentProvider.disableNotification()
    }

}
