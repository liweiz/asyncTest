//
//  ApiGetter.swift
//  asyncTest
//
//  Created by Liwei Zhang on 2015-01-29.
//  Copyright (c) 2015 Liwei Zhang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let uriBase = "https://hacker-news.firebaseio.com/v0/"

func testApi() {
    let u: [String] = ["bane", "LiweiZ", "rdtsc", "ssivark", "sparkzilla", "Wogef"]
    var a = ApiData()
    a.userIds = u
    a.dataProcessor()
    a.dataProcessorClass()
}

func convertJsonIntArray(j: JSON) -> [Int]? {
    if let k = j.array {
        var r = [Int]()
        for (index: String, x: JSON) in j {
            r.append(x.intValue)
        }
        if r.count > 0 {
            return r
        }
    }
    return nil
}

// MARK: Api data container
struct ApiData {
    var userIds = [String]()
    var users = [User]()
    var usersClass = [UserClass]()
    
    mutating func dataProcessorClass() -> () {
        println("usersClass member count: \(usersClass.count)")
        for uId in userIds {
            getOneApiDataClass(uriBase + "user/" + uId + ".json", &usersClass, { (r: UserClass) in
                println("fOk [class] member count: \(self.usersClass.count)")
                }, {}, {})
        }
    }
    
    mutating func dataProcessor() -> () {
        println("users member count: \(users.count)")
        for uId in userIds {
            getOneApiData(uriBase + "user/" + uId + ".json", &users, { (r: User) in
                println("fOk [struct] member count: \(self.users.count)")
                }, {}, {})
        }
    }
    
}

// MARK: - Class based approach

class UserClass {
    var id: String? = nil
    var delay: Int? = nil
    var created: Int? = nil
    var karma: Int? = nil
    var about: String? = nil
    var submitted: [Int]? = nil
    var rating: Int = 0
    required init() {
        
    }
}

protocol JsonImportableClass {
    init()
    func importData(j: JSON)
}

extension UserClass: JsonImportableClass {
    func importData(j: JSON) {
        id = j["id"].string
        delay = j["delay"].int
        created = j["created"].int
        karma = j["karma"].int
        about = j["about"].string
        submitted = convertJsonIntArray(j["submitted"])
    }
}

func getOneApiDataClass<T: JsonImportableClass>(path: String, inout r: [T], fOk: (r: T) -> (), fNotOk: () -> (), fAnyway: () -> ()) {
    Alamofire.request(.GET, path).responseJSON {(req, res, json, error) in
        if(error != nil) {
            NSLog("Error: \(error)")
            fNotOk()
        } else {
            NSLog("Success: \(path)")
            var t = T()
            t.importData(JSON(json!))
            r.append(t)
            println("[class] member count: \(r.count)")
            fOk(r: t)
        }
        fAnyway()
    }
}

// MARK: Struct based approach
internal struct User {
    var id: String? = nil
    var delay: Int? = nil
    var created: Int? = nil
    var karma: Int? = nil
    var about: String? = nil
    var submitted: [Int]? = nil
    var rating: Int = 0
}

protocol JsonImportable {
    init()
    mutating func importData(j: JSON)
}

extension User: JsonImportable {
    mutating func importData(j: JSON) {
        id = j["id"].string
        delay = j["delay"].int
        created = j["created"].int
        karma = j["karma"].int
        about = j["about"].string
        submitted = convertJsonIntArray(j["submitted"])
    }
}

func getOneApiData<T: JsonImportable>(path: String, inout r: [T], fOk: (r: T) -> (), fNotOk: () -> (), fAnyway: () -> ()) {
    Alamofire.request(.GET, path).responseJSON {(req, res, json, error) in
        if(error != nil) {
            NSLog("Error: \(error)")
            fNotOk()
        } else {
            NSLog("Success: \(path)")
            var t = T()
            t.importData(JSON(json!))
            r.append(t)
            println("[struct] member count: \(r.count)")
            fOk(r: t)
        }
        fAnyway()
    }
}
