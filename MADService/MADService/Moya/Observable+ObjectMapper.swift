//
//  Observable+ObjectMapper.swift
//  BLTService
//
//  Created by 梁宪松 on 2018/11/1.
//  Copyright © 2018 ob. All rights reserved.
//

import UIKit
import RxSwift
import Moya
import ObjectMapper
import Result

public extension Observable {
    
    func mapObject<T: Mappable>(type: T.Type) -> Observable<T> {
        return self.mapObject(type: type, dataKey: nil)
    }
    
    func mapObject<T: Mappable>(type: T.Type, dataKey: String?) -> Observable<T> {
        return self.map { response in
            //if response is a dictionary, then use ObjectMapper to map the dictionary
            //if not throw an error
            guard let dict = response as? [String: Any] else {
                throw RxSwiftMoyaError.ParseJSONError
            }
            
            guard (dict["code"] as? Int) != nil else{
                throw RxSwiftMoyaError.ParseJSONError
            }
            
            if let error = self.parseError(response: dict) {
                throw error
            }
            
            if dataKey != nil {
                
                guard let data = dict[dataKey!] else {
                    return Mapper<T>().map(JSON: [:])!
                }
                
                if let d = data  as? [String : Any] {
                    return Mapper<T>().map(JSON:d) ?? Mapper<T>().map(JSON: [:])!
                }
                return Mapper<T>().map(JSONObject: data) ?? Mapper<T>().map(JSON: [:])!
            }else {
                
                return Mapper<T>().map(JSON: dict) ?? Mapper<T>().map(JSON: [:])!
            }
        }
    }
    
    func mapArray<T: Mappable>(type: T.Type) -> Observable<[T]> {
        return self.map { response in
            
            guard let array = response as? [Any] else {
                throw RxSwiftMoyaError.ParseJSONError
            }
            
            guard let dicts = array as? [[String: Any]] else {
                throw RxSwiftMoyaError.ParseJSONError
            }

            return Mapper<T>().mapArray(JSONArray: dicts)
        }
    }
    
    func mapArray<T: Mappable>(type: T.Type, dataKey: String) -> Observable<[T]> {
        return self.map { response in
            
            guard let dict = response as? [String: Any] else {
                throw RxSwiftMoyaError.ParseJSONError
            }
            
            guard (dict["code"] as?Int) != nil else{
                throw RxSwiftMoyaError.ParseJSONError
            }
            
            if let error = self.parseError(response: dict) {
                throw error
            }
            
            if let arr = dict[dataKey] {
                
                if let array = arr as? [Any] {
                    
                    guard let dicts = array as? [[String: Any]] else {
                        throw RxSwiftMoyaError.ParseJSONError
                    }
                    
                    return Mapper<T>().mapArray(JSONArray: dicts)
                }else {
                    return []
                }
            }else {
                throw RxSwiftMoyaError.ParseJSONError
            }
        }
    }
    
    
    func parseServerError() -> Observable {
        return self.map { (response) in
            let name = type(of: response)
            print(name)
            guard let dict = response as? [String: Any] else {
                throw RxSwiftMoyaError.ParseJSONError
            }
            if let error = self.parseError(response: dict) {
                throw error
            }
            return self as! Element
        }
        
    }
    
    fileprivate func parseError(response: [String: Any]?) -> NSError? {
        var error: NSError?
        if let value = response {
            var code:Int?
            
            
            if let codes = value["code"] as?Int
            {
                code = codes
            }
            
            if  code != MADHttpResponse.SUCCESS_CODE {
                var msg = ""
                if let message = value["msg"] as? String {
                    msg = message
                }
                error = NSError(domain: MADHttpResponse.SERVER_DOMAIN_ERROR, code: code!, userInfo: [NSLocalizedDescriptionKey: msg])
            }
        }
        return error
    }
    
    
}

enum RxSwiftMoyaError: String {
    case ParseJSONError
    case OtherError
}

extension RxSwiftMoyaError: Swift.Error {
    
    
}
