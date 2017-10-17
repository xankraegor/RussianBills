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
    
    static func createEmptyFile(named fileName: String, atRelativePath relativePath: String) {
        FilesManager.createDirIfItDontExist(atRelativePath: relativePath)
        let absolutePath = (homeDirPath.appending(relativePath) as NSString).appendingPathComponent(fileName)
        let emptyContent = ""
        do {
            try emptyContent.write(toFile: absolutePath, atomically: true, encoding: String.Encoding.utf8)
        } catch let error {
            debugPrint("∆ Error when creating an empty file in folder \(absolutePath): \(error.localizedDescription)")
        }
    }
    
    static func writeToFile(string: String, named fileName: String, atRelativePath relativePath: String) {
        let absolutePath = (homeDirPath.appending(relativePath) as NSString).appendingPathComponent(fileName)
        do {
            try string.write(toFile: absolutePath, atomically: true, encoding: String.Encoding.utf8)
        } catch let error {
            debugPrint("∆ Error when creating an empty file: \(error.localizedDescription)")
        }
    }
    
    static func readFile(named fileName: String, atRelativePath relativePath: String) -> String {
        let absolutePath = (homeDirPath.appending(relativePath) as NSString).appendingPathComponent(fileName)
        var contents = String()
        do {
            contents = try NSString(contentsOfFile: absolutePath, encoding: String.Encoding.utf8.rawValue) as String
        } catch let error {
            debugPrint("∆ Error when reading a file: \(error.localizedDescription)")
        }
        return contents
    }
    
    static func deleteFile(named fileName: String, atRelativePath relativePath: String) {
        let absolutePath = (homeDirPath.appending(relativePath) as NSString).appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(atPath: absolutePath)
        } catch let error {
            print("∆ Error deleting file: \(error.localizedDescription)")
        }
    }
    
    static func doesFileExist(withNamePart fileNameWithoutExtension: String, atRelativePath relativePath: String)->Bool {
        let filesList = filesInDirectory(atRelativePath: relativePath).map{$0.fileName()}
        debugPrint("All files in directory are: \(filesList)")
        if filesList.contains(fileNameWithoutExtension) {
            return true
        }
        return false
    }

    static func createAndOrWriteToFile(text: String, name: String, atRelativePath relativePath: String) {
        let existingFile = FilesManager.doesFileExist(withNamePart: name, atRelativePath: relativePath)
        if !existingFile {
            FilesManager.createEmptyFile(named: name, atRelativePath: relativePath)
        }
        FilesManager.writeToFile(string: text, named: name, atRelativePath: relativePath)
    }

    // MARK : - Directories

    static func doesDirExist(atRelativePath relativePath: String)->Bool {
        let absolutePath = homeDirPath.appending(relativePath)
        var isDir: ObjCBool = false
        return FileManager.default.fileExists(atPath: absolutePath, isDirectory: &isDir)
    }

    static func createDirectory(atRelativePath relativePath: String) {
        let absolutePath = homeDirPath.appending(relativePath)
        do {
            try FileManager.default.createDirectory(atPath: absolutePath, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            debugPrint("∆ Error when creating a new directory with FileManager.default.createDirectory(atPath: absolutePath, withIntermediateDirectories: true, attributes: nil):: \(error.localizedDescription) at path \(absolutePath)")
        }
    }

    static func createDirIfItDontExist(atRelativePath relativePath: String) {
        if !doesDirExist(atRelativePath: relativePath) {
            createDirectory(atRelativePath: relativePath)
        }
    }

    static func filesInDirectory(atRelativePath relativePath: String) -> [String] {
        let absolutePath = homeDirPath.appending(relativePath)
        var fileList: [String] = []
        do {
            fileList = try FileManager.default.contentsOfDirectory(atPath: absolutePath)
        } catch let error {
            debugPrint("∆ Error when examining contents of a directory at \(absolutePath):: \(error.localizedDescription)")
        }
        return fileList
    }
    
    // MARK: - Specific functions 
    
    static func extractUniqueDocumentNameFrom(urlString: String)->String? {
        debugPrint("∆ Url String is: \(urlString)")
        // Example: http://sozd.parlament.gov.ru/download/78155743-0269-463E-8EEE-5648D5A0B40E
        if let key = urlString.components(separatedBy: "/").last?.components(separatedBy: "&").last {
            debugPrint("∆ Extracted key is: \(key)")
            let forbiddenCharactersSet = CharacterSet(charactersIn: "-0123456789ABCDEF").inverted
            if key.rangeOfCharacter(from: forbiddenCharactersSet) == nil {
                return key
            } else {
                debugPrint("∆ Wrong characters in string when exctracting unique name for document. Key is: \(key)")
            }
        }
        return nil
    }
    
}
