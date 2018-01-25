//
//  Ext-NSError.swift
//  RussianBills
//
//  Created by Xan Kraegor on 10.01.2018.
//  Copyright © 2018 Xan Kraegor. All rights reserved.
//

import Foundation

extension NSError {

    public convenience init(_ domain: NSError.errDomain, code: NSError.errCode, message: String, info: [String: Any]? = nil) {
        let domain = domain.rawValue
        let code = code.rawValue
        var userInfo: [String: Any] = ["errorDescription": message]
        if let additionalInfo = info {
            for (key, value) in additionalInfo {
                userInfo[key] = value
            }
        }
        self.init(domain: domain, code: code, userInfo: userInfo)
    }

    public enum errDomain: String {
        case mainAppl = "com.xankraegor.russianBillsMainApp"
        case todayExt = "com.xankraegor.russianBillsTodayExt"
        case messgExt = "com.xankraegor.russianBillsMessageExt"
        case watchApp = "com.xankraegor.russianBillsWatchApp"
        case watchExt = "com.xankraegor.russianBillsWatchExt"
    }

    public var desc: String {
        return self.userInfo["errorDescription"] as? String ?? ""
    }

    public enum errCode: Int {
        case billSearchResponseErrorCode = 1001
        case parsingResponseErrorCode = 1002
        case parserError = 1003
    }

}
