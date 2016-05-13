//
//  BaseApiClient.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

public class BaseApiClient
{
    public func loadObject<T: Mappable>(method: Alamofire.Method = .POST, _ endpoint: URLStringConvertible, parameters: [String : AnyObject]? = nil, keyPath: String? = nil ,completionBlock: (ApiResponse<T>) -> Void)
    {
        Alamofire.request(method, endpoint, parameters: parameters).validate(contentType: ["text/html"]).responseObject(keyPath: keyPath)
        {
            (response: Response<T, NSError>) -> Void in
            
            guard response.result.isSuccess else {
                completionBlock(ApiResponse.Failure(response.result.error))
                return
            }
            
            guard let modelObject = response.result.value  else {
                completionBlock(ApiResponse.NoData(response.result.value))
                return
            }
            
            completionBlock(ApiResponse.Success(modelObject))
        }
    }
    
    public func loadArray<T: Mappable>(method: Alamofire.Method = .POST, _ endpoint: URLStringConvertible, parameters: [String : AnyObject]? = nil, keyPath: String? = nil ,completionBlock: (ApiResponse<[T]>) -> Void)
    {
        Alamofire.request(method, endpoint, parameters: parameters).validate(contentType: ["text/html"]).responseArray(keyPath: keyPath)
        {
            (response: Response<[T], NSError>) -> Void in
            
            guard response.result.isSuccess else {
                completionBlock(ApiResponse.Failure(response.result.error))
                return
            }
            
            guard let modelArray = response.result.value where modelArray.count > 0 else {
                completionBlock(ApiResponse.NoData(response.result.value))
                return
            }
            
            completionBlock(ApiResponse.Success(modelArray))
        }
    }
}
