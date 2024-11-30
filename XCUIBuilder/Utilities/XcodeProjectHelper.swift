//
//  XcodeProjectHelper.swift
//  XCUIBuilder
//
//  Created by Natalia Popova on 11/22/24.
//

import Foundation
import XcodeProj
import PathKit

func setupFolderStructureForExistingTarget(projectPath: String, targetName: String) throws {
    let projectFilePath = Path(projectPath)

    // Validate that the path is a valid .xcodeproj
    guard projectPath.hasSuffix(".xcodeproj") else {
        throw NSError(domain: "XCUIBuilder", code: 1, userInfo: [NSLocalizedDescriptionKey: "Provided path is not a valid .xcodeproj path."])
    }
    
    // Load the Xcode project
    let xcodeProj = try XcodeProj(path: projectFilePath)
    let pbxproj = xcodeProj.pbxproj
    
    // Find the target
    guard let _ = pbxproj.targets(named: targetName).first else {
        throw NSError(domain: "XCUIBuilder", code: 2, userInfo: [NSLocalizedDescriptionKey: "Target '\(targetName)' not found in the project. Please re-run the script and enter a valid target name."])
    }
    
    print("🚀 Adding Folder Structure to the Target...")

    // Ensure that the target folder exists in the filesystem
    let targetFolderPath = projectFilePath.parent() + Path(targetName)
    if !targetFolderPath.exists {
        try targetFolderPath.mkpath()
        print("✅ Created target folder '\(targetName)' in the filesystem.")
    } else {
        print("ℹ️ Target folder '\(targetName)' already exists in the filesystem.")
    }

    // Create subfolders: Support, Screens, Tests if they do not already exist
    let subfolderNames = ["Support", "Screens", "Tests"]

    for subfolderName in subfolderNames {
        let subfolderPath = targetFolderPath + Path(subfolderName)
        if !subfolderPath.exists {
            try subfolderPath.mkpath()
            print("✅ Created subfolder '\(subfolderName)' under target folder '\(targetName)'.")
        } else {
            print("ℹ️ Subfolder '\(subfolderName)' already exists under target folder '\(targetName)'.")
        }

        if subfolderName == "Support" {
            // Add nested folders under Support: Enums, Extensions, Protocols
            let supportSubfolders = ["Enums", "Extensions", "Protocols"]
            for supportSubfolder in supportSubfolders {
                let supportSubfolderPath = subfolderPath + Path(supportSubfolder)
                if !supportSubfolderPath.exists {
                    try supportSubfolderPath.mkpath()
                    print("✅ Created support subfolder '\(supportSubfolder)' under group 'Support'.")
                } else {
                    print("ℹ️ Support subfolder '\(supportSubfolder)' already exists under group 'Support'.")
                }
            }
        }
    }

    print("✅ Successfully set up the folder structure in the filesystem for the existing UI Testing target '\(targetName)'.")
}
