//
//  Main.swift
//  XCUIBuilder
//

import Foundation
import XcodeProj
import PathKit

func main() {
    print("🔍 Starting XCUIBuilder...")

    // Step 1: Get the project path
    let projectPath = getUserInput(prompt: "Enter the path to your Xcode project (.xcodeproj or project folder):")
    print("📂 Project Path Entered: \(projectPath)")

    // Step 2: Handle folder or .xcodeproj
    let fileManager = FileManager.default
    var xcodeprojPath: String?
    var projectRootPath: String?

    if projectPath.hasSuffix(".xcodeproj") {
        xcodeprojPath = projectPath
        projectRootPath = URL(fileURLWithPath: projectPath).deletingLastPathComponent().path
    } else {
        if let xcodeproj = try? fileManager.contentsOfDirectory(atPath: projectPath).first(where: { $0.hasSuffix(".xcodeproj") }) {
            xcodeprojPath = "\(projectPath)/\(xcodeproj)"
            projectRootPath = projectPath
        }
    }

    guard let validPath = xcodeprojPath, let rootPath = projectRootPath, fileManager.fileExists(atPath: validPath) else {
        print("❌ Error: Provided path is not a valid .xcodeproj path or folder.")
        exit(1) // Exit with error
    }
    print("✅ Valid Project Path: \(validPath)")
    print("📂 Project Root Path: \(rootPath)")

    // Step 3: Get the target name
    let targetName = getUserInput(prompt: "Enter the name of the existing UI Testing target you want to add folders to (if the target doesn't exist, please create it manually in Xcode first):")
    print("🎯 Target Name Entered: \(targetName)")

    // Step 4: Create the folder structure in the specified target
    do {
        try setupFolderStructureForExistingTarget(projectPath: validPath, targetName: targetName)
    } catch {
        print("❌ Error: \(error.localizedDescription)")
        exit(1)
    }
    print("✅ Folder Structure Added Successfully.")

    // Step 5: Get the builder pattern type
    var pattern: BuilderPattern? = nil
    while pattern == nil {
        let patternSelection = getUserInput(prompt: "Select the builder pattern to use:\n1. Screen Transition Chaining\n2. Self Chaining\nEnter your choice: ")
        if let selection = Int(patternSelection), let chosenPattern = BuilderPattern.fromSelection(selection) {
            pattern = chosenPattern
        } else {
            print("❌ Error: Invalid selection. Please enter '1' or '2'.")
        }
    }

    // Step 6: Add shared and pattern-specific files
    let targetFolderPath = Path(rootPath) + Path(targetName)
    print("🚀 Adding Files to the Target...")
        addSharedFiles(basePath: targetFolderPath)
        addPatternSpecificFiles(basePath: targetFolderPath, pattern: pattern!)

        print("✅ Successfully added the files.")

    // Step 7: Register files in the Xcode project
    print("🔗 Registering files in Xcode project...")
    do {
        try addGeneratedFilesToXcodeProject(projectPath: validPath, targetName: targetName)
    } catch {
        print("❌ Error updating Xcode project: \(error.localizedDescription)")
        exit(1)
    }
}

main()
