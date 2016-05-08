//
//  ProfileApiClient.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation
import AlamofireObjectMapper
import Alamofire
import ObjectMapper

public protocol ProfileApiClientProtocol
{
    func loadProfile(username: String, completionBlock: (ApiResponse<MPProfile>) -> Void)
}

public class ProfileApiClient: BaseApiClient, ProfileApiClientProtocol
{
    public func loadProfile(username: String, completionBlock: (ApiResponse<MPProfile>) -> Void)
    {
        let endpoint: String               = "http://meditation.sirimangalo.org/db.php"
        let parameters: [String:AnyObject] = ["profile": username, "submit": "Profile"]
        
        super.loadObject(Alamofire.Method.POST, endpoint, parameters: parameters, keyPath: "chat", completionBlock: completionBlock)
    }
}
