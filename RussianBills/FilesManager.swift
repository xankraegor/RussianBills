//
//  FilesManager.swift
//  RussianBills
//
//  Created by Xan Kraegor on 21.07.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit

enum FilesManager {

    // MARK: - Reference Paths

    static func attachmentDir(forBillNumber number: String)->String {
        return "\(NSHomeDirectory())/Documents/\(number)/Attachments/"
    }

    static func defaultRealmPath()->URL {
        let path = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("default.realm")
        return path
    }

    // MARK: - Files
    
    static func createEmptyFile(named fileName: String, atPath path: String) {
        FilesManager.createDirectory(atPath: path)
        let fullPath = (path as NSString).appendingPathComponent(fileName)
        let emptyContent = ""
        do {
            try emptyContent.write(toFile: fullPath, atomically: true, encoding: .utf8)
        } catch let error {
            debugPrint("∆ Error when creating an empty file in folder \(fullPath): \(error.localizedDescription)")
        }
    }
    
    static func writeToFile(string: String, named fileName: String, atPath path: String) {
        do {
            try string.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
        } catch let error {
            debugPrint("∆ Error when creating an empty file: \(error.localizedDescription)")
        }
    }

    static func deleteFile(atPath path: String, withSeparateName name: String? = nil) {
        if let filePath = URL(fileURLWithPath: path).appendingPathComponent(name ?? "").path.removingPercentEncoding {
            debugPrint("∆ File Path to delete: \(filePath)")
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch let error {
                print("∆ Error deleting file: \(error.localizedDescription)")
            }
        } else {
            debugPrint("∆ Cannot generate path to delete a file")
        }

    }

    static func pathForFile(containingInName namePart: String, inDirectory path: String)->String? {
        let filesPathesList = filesInDirectory(atPath: path)
        for i in 0..<filesPathesList.count {
            if filesPathesList[i].fileName().contains(namePart) {
                return URL(fileURLWithPath: path).appendingPathComponent(filesPathesList[i]).path
            }
        }
        return nil
    }

    static func createAndOrWriteToFileBillDescrition(text: String, name: String, atPath path: String) {
        let fullPath = URL(fileURLWithPath: path).appendingPathComponent(name).path
        let fileExists = FileManager.default.fileExists(atPath: fullPath)

        if !fileExists {
            FilesManager.createEmptyFile(named: name, atPath: path)
        }
        FilesManager.writeToFile(string: text, named: name, atPath: path)
    }

    static func renameFile(named: String, atPath: String, newName: String) {
        let existingFullPath = URL(fileURLWithPath: atPath).appendingPathComponent(named)
        guard FileManager.default.fileExists(atPath: existingFullPath.path) else {
            debugPrint("∆ Cannot move a file, because it does not exist at path \(existingFullPath.path)")
            return
        }
        let newFullPath = URL(fileURLWithPath: atPath).appendingPathComponent(newName)

        do {
            try FileManager.default.moveItem(atPath: existingFullPath.path, toPath: newFullPath.path)
        }
        catch let error {
            debugPrint("∆ Cannot move the file: \(error)")
        }
    }
    
    static func sizeOfFile(atPath: String)->String? {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: atPath), let fileSize = attributes[FileAttributeKey.size] as? UInt64  else {
            return nil
        }
        let  byteCountFormatter =  ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useKB, .useMB, .useGB]
        let sizeToDisplay = byteCountFormatter.string(fromByteCount: Int64(fileSize))
        return sizeToDisplay
    }
    
    // MARK : - Directories
    
    static func doesDirExist(atPath path: String)->Bool {
        var isDir: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
    }
    
    static func createDirectory(atPath path: String) {
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            debugPrint("∆ Error when creating a new directory with FileManager.default.createDirectory(atPath: absolutePath, withIntermediateDirectories: true, attributes: nil):: \(error.localizedDescription) at path \(path)")
        }
    }

    static func filesInDirectory(atPath path: String) -> [String] {
        var fileList: [String] = []
        do {
            fileList = try FileManager.default.contentsOfDirectory(atPath: path)
        } catch let error {
            debugPrint("∆ Can't examine contents at path \(path):: \(error.localizedDescription)")
        }
        return fileList
    }

    static func sizeOfDirectoryContents(atPath path: String)->String? {
        let documentsDirectoryURL = URL(fileURLWithPath: path)
        var bool: ObjCBool = false
        if FileManager.default.fileExists(atPath: documentsDirectoryURL.path, isDirectory: &bool), bool.boolValue {
            var folderSize = 0
            FileManager.default.enumerator(at: documentsDirectoryURL, includingPropertiesForKeys: [.fileSizeKey], options: [])?.forEach {
                folderSize += (try? ($0 as? URL)?.resourceValues(forKeys: [.fileSizeKey]))??.fileSize ?? 0
            }
            let  byteCountFormatter =  ByteCountFormatter()
            byteCountFormatter.allowedUnits = [.useKB, .useMB, .useGB]
            let sizeToDisplay = byteCountFormatter.string(fromByteCount: Int64(folderSize))
            return sizeToDisplay
        } else {
            return nil
        }
    }

    static func deleteAllAttachments() {
        let documentsDirectory = URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/")
        if let directoryContents = try? FileManager.default.contentsOfDirectory(atPath: documentsDirectory.path) {
            for elementPath in directoryContents {
                let fullPath = documentsDirectory.appendingPathComponent(elementPath).path
                do {
                    try FileManager.default.removeItem(atPath: fullPath)
                } catch let error {
                    debugPrint("∆ deleteAllAttachments: \(error.localizedDescription)")
                }
            }
        } else {
            debugPrint("∆ deleteAllAttachments: can't recieve Documents directory contents")
        }
    }
    
    // MARK: - Specific functions 
    
    static func extractUniqueDocumentNameFrom(urlString: String)->String? {
        // Example: http://sozd.parlament.gov.ru/download/78155743-0269-463E-8EEE-5648D5A0B40E
        if let key = urlString.components(separatedBy: "/").last?.components(separatedBy: "&").last {
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
