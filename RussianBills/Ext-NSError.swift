//
//  Ext-NSError.swift
//  RussianBills
//
//  Created by Xan Kraegor on 10.01.2018.
//  Copyright © 2018 Xan Kraegor. All rights reserved.
//

import Foundation

extension NSError {

    public convenience init(_ domain: NSError.errDomain, code: NSError.errCode, message: String) {
        let domain = domain.rawValue
        let code = code.rawValue
        let userInfo: [String: Any] = ["erorDescription": message]
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
        return self.userInfo["erorDescription"] as? String ?? ""
    }

    public enum errCode: Int {
        // MARK: RequestFunctionsProvider.swift = 1000
        case billSearchResponseErrorCode = 1001
    }

}
