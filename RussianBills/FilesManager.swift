//
//  FilesManager.swift
//  RussianBills
//
//  Created by Xan Kraegor on 21.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit

enum FilesManager {
    
    static var homeDirPath: String {
        return NSHomeDirectory() + "/Documents"
    }
    
    // MARK: - Files
    
    static func createEmptyFile(named fileName: String, placedAt relativePath: String) {
        let filePath = (homeDirPath.appending(relativePath) as NSString).appendingPathComponent(fileName)
        let emptyContent = ""
        do {
            try emptyContent.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
        } catch let error {
            debugPrint("∆ Error when creating an empty file: \(error.localizedDescription)")
        }
    }
    
    static func writeToFile(string: String, named fileName: String, placedAt relativePath: String) {
        let filePath = (homeDirPath.appending(relativePath) as NSString).appendingPathComponent(fileName)
        do {
            try string.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
        } catch let error {
            debugPrint("∆ Error when creating an empty file: \(error.localizedDescription)")
        }
    }
    
    static func readFile(named fileName: String, placedAt relativePath: String) -> String {
        let filePath = (homeDirPath.appending(relativePath) as NSString).appendingPathComponent(fileName)
        var contents = String()
        do {
            contents = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
        } catch let error {
            debugPrint("∆ Error when reading a file: \(error.localizedDescription)")
        }
        return contents
    }
    
    static func deleteFile(named fileName: String, placedAt relativePath: String) {
        let filePath = (homeDirPath.appending(relativePath) as NSString).appendingPathComponent(fileName)
        do {
            try FileManager().removeItem(atPath: filePath)
        } catch let error {
            print("∆ Error deleting file: \(error.localizedDescription)")
        }
    }
    
    static func doesFileExist(withNamePart fileNameWithoutExtension: String, atPath path: String)->Bool {
        let filesList = filesInDirectory(placedAt: path).map{$0.fileName()}
        debugPrint("All files in directory are: \(filesList)")
        if filesList.contains(fileNameWithoutExtension) {
            return true
        }
        return false
    }

    static func createAndOrWriteToFile(text: String, name: String, path: String) {
        let existingFile = FilesManager.doesFileExist(withNamePart: name, atPath: path)
        if !existingFile {
            FilesManager.createEmptyFile(named: name, placedAt: path)
        }
        FilesManager.writeToFile(string: text, named: name, placedAt: path)
    }

    // MARK : - Dirs

    static func filesInDirectory(placedAt relativePath: String) -> [String] {
        var fileList: [String] = []
        do { fileList = try FileManager().contentsOfDirectory(atPath: homeDirPath.appending(relativePath))
        } catch let error as NSError {
            debugPrint("∆ Error when examining contents of a directory: \(error)")
        }
        return fileList
    }
    
    // MARK: - Specific functions 
    
    static func extractUniqueDocumentNameFrom(urlString: String)->String? {
        // Example: /main.nsf/(ViewDoc)?OpenAgent&work/dz.nsf/ByID&B5DAF1172254E92A4325815D0037367A
        if let key = urlString.components(separatedBy: "&").last {
            if key.characters.count == 32 {
                let forbiddenCharactersSet = CharacterSet(charactersIn: "0123456789ABCDEF").inverted
                if key.rangeOfCharacter(from: forbiddenCharactersSet) == nil {
                    return key
                } else {
                    debugPrint("∆ Wrong characters in string when exctracting unique name for document")
                }
            } else {
                debugPrint("∆ Characters count mismatch when exctracting unique name for document")
            }
        }
        return nil
    }
    
    
    
    
}
