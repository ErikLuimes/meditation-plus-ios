//
//  MeditatorApiClient.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation
import AlamofireObjectMapper
import Alamofire
import ObjectMapper

public protocol MeditatorApiClientProtocol
{
    func loadMeditators(username: String, completionBlock: (ApiResponse<[Meditator]>) -> Void)
    
    func startMeditation(username: String, token: String, sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completionBlock: (ApiResponse<[Meditator]>) -> Void)
    
    func cancelMeditation(username: String, token: String, sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completionBlock: (ApiResponse<[Meditator]>) -> Void)
}

public class MeditatorApiClient: BaseApiClient, MeditatorApiClientProtocol
{
    public func loadMeditators(username: String, completionBlock: (ApiResponse<[Meditator]>) -> Void)
    {
        let endpoint = "http://meditation.sirimangalo.org/db.php"
        // Always post 'last_chat' date so that no chat data is returned
        let parameters: [String:AnyObject] = ["username": username, "last_chat": String(UInt(NSDate().timeIntervalSince1970))]
        
        super.loadArray(Alamofire.Method.POST, endpoint, parameters: parameters, keyPath: "list", completionBlock: completionBlock)
    }
    
    
    public func startMeditation(username: String, token: String, sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completionBlock: (ApiResponse<[Meditator]>) -> Void)
    {
        let endpoint = "http://meditation.sirimangalo.org/db.php"
        var parameters: [String:String] = [
                "username": username,
                "token": token,
                "form_id": "timeform",
                "last_chat": String(UInt(NSDate().timeIntervalSince1970)),
                "source": "ios"
        ]

        parameters["sitting"] = sittingTimeInMinutes == nil ? "" : String(sittingTimeInMinutes!)
        parameters["walking"] = walkingTimeInMinutes == nil ? "" : String(walkingTimeInMinutes!)

        super.loadArray(Alamofire.Method.POST, endpoint, parameters: parameters, keyPath: "list", completionBlock: completionBlock)
    }
    
    public func cancelMeditation(username: String, token: String, sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completionBlock: (ApiResponse<[Meditator]>) -> Void)
    {
        let endpoint = "http://meditation.sirimangalo.org/db.php"
        var parameters: [String:String] = [
                "username": username,
                "token": token,
                "form_id": "cancelform",
                "last_chat": String(UInt(NSDate().timeIntervalSince1970)),
                "source": "ios"
        ]

        parameters["sitting"] = sittingTimeInMinutes == nil ? "" : String(sittingTimeInMinutes!)
        parameters["walking"] = walkingTimeInMinutes == nil ? "" : String(walkingTimeInMinutes!)
        
        super.loadArray(Alamofire.Method.POST, endpoint, parameters: parameters, keyPath: "list", completionBlock: completionBlock)
    }
}