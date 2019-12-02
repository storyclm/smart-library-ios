//
//  CustomBridgeModule.swift
//  SmartLibrary
//
//  Created by Sergey Ryazanov on 16.09.2019.
//  Copyright © 2019 Breffi. All rights reserved.
//

import Foundation
import StoryContent

protocol CustomBridgeModuleDelegate: class {
    func customBridgeModuleDelegateCallback(command: String, params: Any)
}

class CustomBridgeModule: SCLMBridgeModule {

    struct Commands {
        static let command1 = "Mycommand1"
        static let command2 = "Mycommand2"

        static var allCommands: [String] {
            return [ command1, command2 ]
        }
    }

    weak var delegate: CustomBridgeModuleDelegate?

    override func execute(message: SCLMBridgeMessage, result: @escaping (SCLMBridgeResponse?) -> Void) {

        switch message.command {
        case Commands.command1:
            result(commandHandler1(guid: message.guid, command:message.command, data: message.data))
        case Commands.command2:
            result(commandHandler2(guid: message.guid, command:message.command, data: message.data))

        default:
            result(SCLMBridgeResponse(guid: message.guid, responseData: nil, status: SCLMBridgeResponse.Status.failure, errorMessage: "unknown command"))
        }
    }

    private func commandHandler1(guid: String, command: String, data: Any) -> SCLMBridgeResponse {
        // get some job here
        delegate?.customBridgeModuleDelegateCallback(command: command, params: data)

        return SCLMBridgeResponse(guid: guid, responseData: nil, status: SCLMBridgeResponse.Status.success, errorMessage: nil)
    }

    private func commandHandler2(guid: String, command: String, data: Any) -> SCLMBridgeResponse {
        // get some job here
        delegate?.customBridgeModuleDelegateCallback(command: command, params: data)

        return SCLMBridgeResponse(guid: guid, responseData: nil, status: SCLMBridgeResponse.Status.success, errorMessage: nil)
    }
}
