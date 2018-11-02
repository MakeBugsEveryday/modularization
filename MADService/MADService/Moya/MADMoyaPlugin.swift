//
//  BLTMoyaPlugin.swift
//  BLTService
//
//  Created by 梁宪松 on 2018/11/1.
//  Copyright © 2018 ob. All rights reserved.
//

import UIKit
import Moya
import Result

let networkActivityPlugin = NetworkActivityPlugin{ (changeType:NetworkActivityChangeType, targetType: TargetType) in
    
    switch(changeType){
        
    case .ended:
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    case .began:
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
}

struct AuthPlugin: PluginType {
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var rq = request
        rq.timeoutInterval = 30
        return rq
    }
}
