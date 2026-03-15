//
//  XcodeProjectHelper.swift
//  XCUIBuilder
//

import Foundation
import XcodeProj
import PathKit

func setupFolderStructureForExistingTarget(projectPath: String, targetName: String) throws {
    let projectFilePath = Path(projectPath)

    guard projectPath.hasSuffix(".xcodeproj") else {
        throw NSError(domain: "XCUIBuilder", code: 1, userInfo: [NSLocalizedDescriptionKey: "Provided path is not a valid .xcodeproj path."])
    }

    let xcodeProj = try XcodeProj(path: projectFilePath)
    let pbxproj = xcodeProj.pbxproj

    guard let _ = pbxproj.targets(named: targetName).first else {
        throw NSError(domain: "XCUIBuilder", code: 2, userInfo: [NSLocalizedDescriptionKey: "Target '\(targetName)' not found in the project. Please re-run the script and enter a valid target name."])
    }

    print("🚀 Adding Folder Structure to the Target...")

    let targetFolderPath = projectFilePath.parent() + Path(targetName)
    if !targetFolderPath.exists {
        try targetFolderPath.mkpath()
        print("✅ Created target folder '\(targetName)' in the filesystem.")
    } else {
        print("ℹ️ Target folder '\(targetName)' already exists in the filesystem.")
    }

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

func addGeneratedFilesToXcodeProject(projectPath: String, targetName: String) throws {
    let projectFilePath = Path(projectPath)
    let xcodeProj = try XcodeProj(path: projectFilePath)
    let pbxproj = xcodeProj.pbxproj

    guard let target = pbxproj.targets(named: targetName).first else {
        throw NSError(domain: "XCUIBuilder", code: 2, userInfo: [
            NSLocalizedDescriptionKey: "Target '\(targetName)' not found."
        ])
    }

    // Auto-detect: folder sync (Xcode 16+) vs traditional groups
    if let syncGroups = target.fileSystemSynchronizedGroups, !syncGroups.isEmpty {
        print("✅ Project uses folder sync — files will appear in Xcode automatically.")
        return
    }

    // Traditional groups: register files manually in the project
    print("📎 Project uses traditional groups — registering files in .xcodeproj...")

    guard let sourcesBuildPhase = try target.sourcesBuildPhase() else {
        throw NSError(domain: "XCUIBuilder", code: 3, userInfo: [
            NSLocalizedDescriptionKey: "No sources build phase found for target '\(targetName)'."
        ])
    }

    guard let rootGroup = try pbxproj.rootGroup() else {
        throw NSError(domain: "XCUIBuilder", code: 4, userInfo: [
            NSLocalizedDescriptionKey: "Could not find root group in project."
        ])
    }

    let targetGroup = findOrCreateGroup(named: targetName, in: rootGroup, pbxproj: pbxproj)
    let targetFolderPath = projectFilePath.parent() + Path(targetName)

    try addFilesFromDirectory(
        dirPath: targetFolderPath,
        toGroup: targetGroup,
        sourcesBuildPhase: sourcesBuildPhase,
        pbxproj: pbxproj
    )

    try xcodeProj.write(path: projectFilePath)
    print("✅ Successfully registered all generated files in the Xcode project.")
}

@discardableResult
private func findOrCreateGroup(named name: String, in parent: PBXGroup, pbxproj: PBXProj) -> PBXGroup {
    if let existing = parent.children.first(where: {
        ($0 as? PBXGroup)?.path == name || ($0 as? PBXGroup)?.name == name
    }) as? PBXGroup {
        return existing
    }
    let group = PBXGroup(children: [], sourceTree: .group, path: name)
    pbxproj.add(object: group)
    parent.children.append(group)
    return group
}

private func addFilesFromDirectory(
    dirPath: Path,
    toGroup: PBXGroup,
    sourcesBuildPhase: PBXSourcesBuildPhase,
    pbxproj: PBXProj
) throws {
    let children = try dirPath.children().sorted { $0.string < $1.string }

    for childPath in children {
        if childPath.isDirectory {
            let subGroup = findOrCreateGroup(named: childPath.lastComponent, in: toGroup, pbxproj: pbxproj)
            try addFilesFromDirectory(
                dirPath: childPath,
                toGroup: subGroup,
                sourcesBuildPhase: sourcesBuildPhase,
                pbxproj: pbxproj
            )
        } else if childPath.extension == "swift" {
            let fileName = childPath.lastComponent
            guard !toGroup.children.contains(where: { $0.path == fileName || $0.name == fileName }) else {
                print("ℹ️ '\(fileName)' already in project, skipping.")
                continue
            }
            let fileRef = PBXFileReference(
                sourceTree: .group,
                lastKnownFileType: "sourcecode.swift",
                path: fileName
            )
            pbxproj.add(object: fileRef)
            toGroup.children.append(fileRef)

            let buildFile = PBXBuildFile(file: fileRef)
            pbxproj.add(object: buildFile)
            if sourcesBuildPhase.files == nil { sourcesBuildPhase.files = [] }
            sourcesBuildPhase.files?.append(buildFile)

            print("✅ Registered '\(fileName)' in Xcode project.")
        }
    }
}
