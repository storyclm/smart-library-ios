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
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [weak self] (timer) in
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
                
                storyIoT.publishSmall(body: dic, eventId: "story.content.session", userId: user?.userId, entityId: session.sessionId, location: locationManager.location, success: { (response) in
                    print("publishSmall for session with id - \(String(describing: session.sessionId))")
                    self.storage.setSessionSynchronized(withSessionId: session.sessionId!)
                    
                }) { (error) in
                    print(error.localizedDescription)
                    
                }
                
            }
            
        }
        
        // SessionActions
        if let sessionActionsToSync = storage.findNotSynchronizedSessionActions(user: user) {
            
            for sessionAction in sessionActionsToSync {
                
                let dic = sessionAction.asDict()
                print(dic)
                
                storyIoT.publishSmall(body: dic, eventId: "story.content.slide", userId: user?.userId, entityId: sessionAction.id, location: locationManager.location, success: { (response) in
                    print("publishSmall for action with id - \(String(describing: sessionAction.id))")
                    self.storage.setSessionActionSynchronized(withSessionActionId: sessionAction.id!)
                    
                }) { (error) in
                    print(error.localizedDescription)
                    
                }
                
            }
            
        }
        
        // SessionEventActions
        if let sessionEventActionsToSync = storage.findNotSynchronizedSessionEventActions(user: user) {
            
            for sessionEventAction in sessionEventActionsToSync {
            
                let dic = sessionEventAction.asDict()
                print(dic)
                
                storyIoT.publishSmall(body: dic, eventId: "story.content.customevent", userId: user?.userId, entityId: sessionEventAction.id, location: locationManager.location, success: { (response) in
                    print("publishSmall for action with id - \(String(describing: sessionEventAction.id))")
                    self.storage.setSessionEventActionSynchronized(withSessionEventActionId: sessionEventAction.id!)
                    
                }) { (error) in
                    print(error.localizedDescription)
                    
                }
                
            }
            
        }
        
        
    }
    
}
