//
//  String-FileNameAndExtension.swift
//  RussianBills
//
//  Created by Xan Kraegor on 22.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation

extension String {
    func fileName() -> String {

        if let fileNameWithoutExtension = NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent {
            return fileNameWithoutExtension
        } else {
            return ""
        }
    }

    func fileExtension() -> String {

        if let fileExtension = NSURL(fileURLWithPath: self).pathExtension {
            return fileExtension
        } else {
            return ""
        }
    }
}
