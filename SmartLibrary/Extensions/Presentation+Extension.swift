//
//  Presentation+Extension.swift
//  SmartLibrary
//
//  Created by Sergey Ryazanov on 15.12.2019.
//  Copyright © 2019 Breffi. All rights reserved.
//

import StoryContent

extension Presentation {

    func sclmIsIndexExist() -> Bool {
        if let sourcesFolderUrl = sourcesFolderUrl() {
            do {
                let contentOfDir = try FileManager.default.contentsOfDirectory(at: sourcesFolderUrl, includingPropertiesForKeys: nil, options: [])
                for contentURL in contentOfDir {
                    if contentURL.lastPathComponent == "index.html" {
                        return true
                    }
                }
            } catch {
                return false
            }
        }
        return false
    }
}
