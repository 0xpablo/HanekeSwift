//
//  NSFileManager+Haneke.swift
//  Haneke
//
//  Created by Hermes Pique on 8/26/14.
//  Copyright (c) 2014 Haneke. All rights reserved.
//

import Foundation

extension FileManager {

    func enumerateContentsOfDirectoryAtPath(path: String, orderedByProperty property: String, ascending: Bool, usingBlock block: (NSURL, Int, inout Bool) -> Void ) {

        let directoryURL = NSURL(fileURLWithPath: path)
        do {
            let contents = try self.contentsOfDirectory(at: directoryURL as URL, includingPropertiesForKeys: [property], options: FileManager.DirectoryEnumerationOptions())
            let sortedContents = contents.sorted(isOrderedBefore: { URL1, URL2 in
                
                // Maybe there's a better way to do this. See: http://stackoverflow.com/questions/25502914/comparing-anyobject-in-swift
                
                var value1 : AnyObject?
                do {
                    try (URL1 as NSURL).getResourceValue(&value1, forKey: URLResourceKey(rawValue: property));
                } catch {
                    return true
                }
                var value2 : AnyObject?
                do {
                    try (URL2 as NSURL).getResourceValue(&value2, forKey: URLResourceKey(rawValue: property));
                } catch {
                    return false
                }

                if let string1 = value1 as? String, let string2 = value2 as? String {
                    return ascending ? string1 < string2 : string2 < string1
                }
                
                if let date1 = value1 as? Date, let date2 = value2 as? Date {
                    return ascending ? date1 < date2 : date2 < date1
                }
                
                if let number1 = value1 as? NSNumber, let number2 = value2 as? NSNumber {
                    return ascending ? number1 < number2 : number2 < number1
                }
                
                return false
            }) as [NSURL]

            for (i, v) in sortedContents.enumerated() {
                var stop : Bool = false
                block(v, i, &stop)
                if stop { break }
            }
        } catch {
            Log.error(message: "Failed to list directory", error as NSError)
        }
    }

}

func < (lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs) == .orderedAscending
}

func < (lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == .orderedAscending
}
