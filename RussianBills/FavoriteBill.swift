//
//  FavoriteBill.swift
//  RussianBills
//
//  Created by Xan Kraegor on 24.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import RealmSwift

enum FavoritesFilters: String {
    case hasUnseenChanges = "favoriteHasUnseenChanges == true"
    case notMarkedToBeRemoved = "markedToBeRemovedFromFavorites == false"
    case both = "markedToBeRemovedFromFavorites == false AND favoriteHasUnseenChanges == true"
}

final class FavoriteBill_: Object {

    @objc dynamic var number: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var comments: String = ""
    @objc dynamic var favoriteUpdatedTimestamp = Date.distantPast
    @objc dynamic var favoriteHasUnseenChanges: Bool = false
    @objc dynamic var favoriteHasUnseenChangesTimestamp = Date.distantPast

    @objc dynamic var markedToBeRemovedFromFavorites: Bool = false
    @objc dynamic var markedForDownload: Bool = false

    #if BASEPROJECT

    var bill: Bill_? {
        if let bill = try? Realm().object(ofType: Bill_.self, forPrimaryKey: self.number), let tryBill = bill {
            return tryBill
        } else {
            return nil
        }
    }

    #endif

    override static func primaryKey() -> String {
        return "number"
    }

    #if BASEPROJECT

    convenience init(fromBill bill: Bill_) {
        self.init()
        self.number = bill.number
        self.name = bill.name
        self.comments = bill.comments
        self.favoriteUpdatedTimestamp = Date()
    }

    convenience init(withNumber number: String, name: String, comments: String, favoriteUpdatedTimestamp: Date, favoriteHasUnseenChanges: Bool, favoriteHasUnseenChangesTimestamp: Date) {
        self.init()
        self.number = number
        self.name = name
        self.comments = comments
        self.favoriteUpdatedTimestamp = favoriteUpdatedTimestamp
        self.favoriteHasUnseenChanges = favoriteHasUnseenChanges
        self.favoriteHasUnseenChangesTimestamp = favoriteHasUnseenChangesTimestamp
    }

    #endif
    
}

#if BASEPROJECT

extension FavoriteBill_: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let newFavoriteBill = FavoriteBill_()
        newFavoriteBill.name = self.name
        newFavoriteBill.number = self.number
        newFavoriteBill.favoriteUpdatedTimestamp = self.favoriteUpdatedTimestamp
        newFavoriteBill.comments = self.comments
        newFavoriteBill.favoriteHasUnseenChanges = self.favoriteHasUnseenChanges
        newFavoriteBill.favoriteHasUnseenChangesTimestamp = self.favoriteHasUnseenChangesTimestamp
        newFavoriteBill.markedToBeRemovedFromFavorites = self.markedToBeRemovedFromFavorites
        newFavoriteBill.markedForDownload = self.markedForDownload
        return newFavoriteBill
    }
}

#endif
