//
//  MADHttpResponse.swift
//  MADService
//
//  Created by 梁宪松 on 2018/11/1.
//  Copyright © 2018 ob. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper

public class MADHttpResponse: NSObject {

    static let SERVER_DOMAIN_ERROR = "SERVER_DOMAIN_ERROR"
    
    static let SUCCESS_CODE: Int = 200
    
    var data: Any?
    
    var jsonData: JSON?
    
    var code: Int = 0
    
    var msg: String! = "请求失败，请稍后重试"
    
    init(jsonData: Any) {
        
        super.init();
        
        let json = JSON.init(jsonData)
        
        self.jsonData = json
        
        code = json["code"].intValue
        
        msg = json["msg"].string
        
        self.data = jsonData
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        code <- map["code"]
        msg <- map["msg"]
        
        let d = JSON.init(map.JSON)
        data = d
        self.jsonData = d
    }
    
    override init() {
        super.init()
    }
}
