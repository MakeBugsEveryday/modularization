//
//  MADApiManager.swift
//  MADService
//
//  Created by 梁宪松 on 2018/11/1.
//  Copyright © 2018 ob. All rights reserved.
//

import UIKit
import Moya
import Alamofire

#if DEV
    let API_BASE_URL = "http://api.com"
#else
    let API_BASE_URL = "https://api.com"
#endif

// 默认provide
public let MADDefaultApiManagerProvider = MoyaProvider<MADApiManager>(endpointClosure: endpointMapping, plugins:[
    networkActivityPlugin,
    AuthPlugin.init()
])

// hook 请求
private func endpointMapping<Target: TargetType>(target: Target) -> Endpoint {
    
    print("============\n请求连接：\(target.baseURL)\(target.path) \n方法：\(target.method) \n请求头：\(String(describing: target.headers))\n任务：\(String(describing: target.task)) \n============")
    
    return MoyaProvider.defaultEndpointMapping(for: target)
}

// 请求接口
public enum MADApiManager {
    
}

extension MADApiManager: TargetType {
    
    public var baseURL: URL {
        switch self {
        default:
            return URL.init(string: API_BASE_URL)!
        }
    }
    
    // 请求路径
    public var path: String {
        switch self {
        default:
            return ""
        }
    }
    
    public var method: Moya.Method {
        switch self {
        default:
            // 默认get请求
            return .get
        }
    }
    
    // 单元测试数据
    public var sampleData: Data {
        switch self {
        default:
            return "".data(using: String.Encoding.utf8)!
        }
    }
    
    public var task: Task {
        var params = [String:Any]()
        switch self {
        default:break
        }
        return .requestParameters(parameters: params, encoding: URLEncoding.default)
    }
    
    public var headers: [String : String]? {
        
        return nil
    }
    
    public var validationType: ValidationType {
        return .none
    }
}
