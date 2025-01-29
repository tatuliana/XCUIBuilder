//
//  FileManagerHelper.swift
//  XCUIBuilder
//
//  Created by Natalia Popova on 11/21/24.
//

import Foundation
import PathKit
// Function to create a directory at the specified path
func createDirectory(_ path: String) {
    let fileManager = FileManager.default
    do {
        if !fileManager.fileExists(atPath: path) {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            print("✅ Created directory at \(path)")
        } else {
            print("⚠️ Directory already exists at \(path)")
        }
    } catch {
        print("❌ Failed to create directory at \(path): \(error.localizedDescription)")
    }
}

func createFile(_ path: String, content: String) {
    let url = URL(fileURLWithPath: path)
    try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try? content.write(to: url, atomically: true, encoding: .utf8)
}



/// Reads the contents of a file at the given path (useful for debugging or validation).
func readFileContent(_ path: String) -> String? {
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: path) {
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            return content
        } catch {
            print("❌ Failed to read file at \(path): \(error.localizedDescription)")
        }
    } else {
        print("⚠️ File does not exist at \(path)")
    }
    return nil
}

// MARK: - User Input Helper Function
func getUserInput(prompt: String) -> String {
    print(prompt, terminator: " ")
    guard let input = readLine(), !input.isEmpty else {
        print("❌ Invalid input. Please try again.")
        return getUserInput(prompt: prompt) // Retry until valid input is received
    }
    return input
}

enum BuilderPattern {
    case selfChaining
    case screenTransitionChaining
    // Add other patterns as needed

    static func fromSelection(_ selection: Int) -> BuilderPattern? {
        switch selection {
        case 1: return .screenTransitionChaining
        case 2: return .selfChaining
        default: return nil
        }
    }
}

// Function to add shared files
func addSharedFiles(basePath: Path) {
    let sharedFiles = [
        ("Support", "BaseTest.swift", generateBaseTestContent()),
        ("Support", "BaseScreen.swift", generateBaseScreenContent()),
        ("Support/Protocols", "ScreenActivitiesProtocol.swift", generateScreenActivitiesProtocolContent()),
        ("Support/Extensions", "XCUIElementQueryExtensions.swift", generateXCUIElementQueryExtensionContent()),
        ("Support/Extensions", "XCUIElementExtensions.swift", generateXCUIElementExtensionContent()),
        ("Support/Enums", "ElementState.swift", generateElementStateEnumContent()),
        ("Support/Enums", "Timeout.swift", generateTimeoutEnumContent()),
        ("Support/Enums", "Icons.swift", generateIconsEnumContent()),
        ("Support/Enums", "TabsExample.swift", generateTabsExampleEnumContent()),
        ("Support/Enums", "Properties.swift", generatePropertiesEnumContent()),
        ("Support/Enums", "SwitchState.swift", generateSwitchStateEnumContent())
    ]

    for (subfolder, fileName, content) in sharedFiles {
        let filePath = basePath + Path(subfolder) + Path(fileName)
        createFileIfNeeded(path: filePath, content: content)
    }
}

// Functions for adding pattern-specific files
func addPatternSpecificFiles(basePath: Path, pattern: BuilderPattern) {
    switch pattern {
    case .selfChaining:
        createFileIfNeeded(path: basePath + Path("Screens") + Path("LaunchScreenExample.swift"), content: generateSelfChainingLaunchScreenExampleContent())
        createFileIfNeeded(path: basePath + Path("Screens") + Path("LoginScreenExample.swift"), content: generateSelfChainingLoginScreenExampleContent())
        createFileIfNeeded(path: basePath + Path("Screens") + Path("HomeScreenExample.swift"), content: generateSelfChainingHomeScreenExampleContent())
        createFileIfNeeded(path: basePath + Path("Tests") + Path("SelfChainingUITestsExample.swift"), content: generateSelfChainingUITestsExampleContent())
        createFileIfNeeded(path: basePath + Path("Support/Protocols") + Path("TabBarProtocolExample.swift"), content: generateSelfChainingTabBarProtocolExampleContent())

    case .screenTransitionChaining:
        createFileIfNeeded(path: basePath + Path("Screens") + Path("LaunchScreenExample.swift"), content: generateTransitionChainingLaunchScreenExampleContent())
        createFileIfNeeded(path: basePath + Path("Screens") + Path("LoginScreenExample.swift"), content: generateTransitionChainingLoginScreenExampleContent())
        createFileIfNeeded(path: basePath + Path("Screens") + Path("HomeScreenExample.swift"), content: generateTransitionChainingHomeScreenExampleContent())
        createFileIfNeeded(path: basePath + Path("Tests") + Path("TransitionChainingUITestsExample.swift"), content: generateTransitionChainingUITestsExample())
        createFileIfNeeded(path: basePath + Path("Support/Protocols") + Path("TabBarProtocolExample.swift"), content: generateScreenTransitionChainingTabBarProtocolExampleContent())
    }
}

// Helper function to create file if it does not already exist
func createFileIfNeeded(path: Path, content: String) {
    if !path.exists {
        do {
            try path.write(content)
            print("✅ Created file '\(path.lastComponent)'.")
        } catch {
            print("❌ Error creating file '\(path.lastComponent)': \(error.localizedDescription)")
        }
    } else {
        print("ℹ️ File '\(path.lastComponent)' already exists.")
    }
}
