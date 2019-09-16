//
//  CustomBridgeModule.swift
//  SmartLibrary
//
//  Created by Sergey Ryazanov on 16.09.2019.
//  Copyright © 2019 Breffi. All rights reserved.
//

import Foundation
import ContentComponent

class CustomBridgeModule: SCLMBridgeModule {

    let commands = [ "Mycommand1", "Mycommand2" ]

    override func execute(message: SCLMBridgeMessage, result: @escaping (SCLMBridgeResponse?) -> Void) {
        print(message.command) // Имя команды
        print(message.data) // Тело команды

        result(SCLMBridgeResponse(guid: message.guid, responseData: nil, errorCode: ResponseStatus.success, errorMessage: nil))
    }
}
