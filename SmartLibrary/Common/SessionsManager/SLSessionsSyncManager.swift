//
//  SLSessionsSyncManager.swift
//  SmartLibrary
//
//  Created by Oleksandr Yolkin on 6/7/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import Foundation

import StoryContent
import StoryIoT

import CoreLocation
import Alamofire

class SLSessionsSyncManager {
    static let shared = SLSessionsSyncManager()

    let locationManager = SLLocationManager.shared
    let storage = SCLMBridgeStorage()

    let storyIoT: StoryIoT
    var timer: Timer?

    init() {
        storyIoT = StoryIoT(credentials: SC)
    }

    public func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [weak self] timer in
            self?.sync()
        })
    }

    private func sync() {

        let user = SCLMCoreDataManager.shared.user()

        // Sessions
        if let sessionsToSync = storage.findFinishedNotSynchronizedSessions(user: user) {

            print("SLSessionsSyncManager: sessionsToSync - \(sessionsToSync.count)")

            for session in sessionsToSync {

                let dic = session.asDict()
                print(dic)

                var coordinate: CLLocationCoordinate2D?
                if let latitude = session.latitude?.doubleValue, let longitude = session.longitude?.doubleValue {
                    coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }

                let message = SIOTMessageModel(body: dic)
                message.eventId = "story.content.session"
                message.userId = session.userId
                message.entityId = session.sessionId
                message.created = session.created
                message.operationType = session.isRestored ? SIOTMessageModel.OperationType.update : SIOTMessageModel.OperationType.create
                message.coordinate = coordinate
                message.language = self.appLanguage
                message.networkStatus = self.appNetworkStatus()

                storyIoT.publishSmall(message: message, success: { response in
                    print("publishSmall for session with id - \(String(describing: session.sessionId))")
                    self.storage.setSessionSynchronized(withSessionId: session.sessionId!)
                }) { error in
                    print(error.localizedDescription)
                }
            }
        }

        // SessionActions
        if let sessionActionsToSync = storage.findNotSynchronizedSessionActions(user: user) {

            for sessionAction in sessionActionsToSync {

                let dic = sessionAction.asDict()
                print(dic)

                var coordinate: CLLocationCoordinate2D?
                if let latitude = sessionAction.latitude?.doubleValue, let longitude = sessionAction.longitude?.doubleValue {
                    coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }

                let message = SIOTMessageModel(body: dic)
                message.eventId = "story.content.slide"
                message.userId = sessionAction.userId
                message.entityId = sessionAction.id
                message.created = sessionAction.created
                message.operationType = sessionAction.isRestored ? SIOTMessageModel.OperationType.update : SIOTMessageModel.OperationType.create
                message.coordinate = coordinate
                message.language = self.appLanguage
                message.networkStatus = self.appNetworkStatus()

                storyIoT.publishSmall(message: message, success: { response in
                    print("publishSmall for action with id - \(String(describing: sessionAction.id))")
                    self.storage.setSessionActionSynchronized(withSessionActionId: sessionAction.id!)

                }) { error in
                    print(error.localizedDescription)
                }
            }
        }

        // SessionEventActions
        if let sessionEventActionsToSync = storage.findNotSynchronizedSessionEventActions(user: user) {

            for sessionEventAction in sessionEventActionsToSync {

                let dic = sessionEventAction.asDict()
                print(dic)
                
                var coordinate: CLLocationCoordinate2D?
                if let latitude = sessionEventAction.latitude?.doubleValue, let longitude = sessionEventAction.longitude?.doubleValue {
                    coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }

                let message = SIOTMessageModel(body: dic)
                message.eventId = "story.content.customevent"
                message.userId = sessionEventAction.userId
                message.entityId = sessionEventAction.id
                message.created = sessionEventAction.created
                message.operationType = sessionEventAction.isRestored ? SIOTMessageModel.OperationType.update : SIOTMessageModel.OperationType.create
                message.coordinate = coordinate
                message.language = self.appLanguage
                message.networkStatus = self.appNetworkStatus()

                storyIoT.publishSmall(message: message, success: { _ in
                    print("publishSmall for action with id - \(String(describing: sessionEventAction.id))")
                    self.storage.setSessionEventActionSynchronized(withSessionEventActionId: sessionEventAction.id!)

                }) { error in
                    print(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Helpers

    private var appLanguage: String? {
        return Locale.current.languageCode
    }

    private func appNetworkStatus() -> String {
        guard let reachabilityManager = NetworkReachabilityManager() else { return "none" }

        let status = reachabilityManager.networkReachabilityStatus
        if case let NetworkReachabilityManager.NetworkReachabilityStatus.reachable(type) = status {
            switch type {
            case .wwan:
                return "Cellular"
            case .ethernetOrWiFi:
                return "Wi-Fi"
            }
        } else {
            return "none"
        }
    }
}
