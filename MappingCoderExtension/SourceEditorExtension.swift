//
//  SourceEditorExtension.swift
//  MappingCoderExtension
//
//  Created by Wang Guanyu on 2021/7/19.
//

import Foundation
import XcodeKit

let domain = "com.wgy.MappingCoder.error"
let paseJSONFailed =
"""
Fail to parse JSON.\
Please select JSON from source editor and try again. 🚨
"""

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    /*
    func extensionDidFinishLaunching() {
        // If your extension needs to do any work at launch, implement this optional method.
    }
    */
    
    /*
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
        return []
    }
    */
    
}
