//
//  Message.swift
//  Chat App
//
//  Created by Kevin Li on 10/21/19.
//  Copyright © 2019 Kevin Li. All rights reserved.
//

import Firebase
import MessageKit
import FirebaseFirestore

struct Message: MessageType {
    
    var sender: SenderType
    let content: String
    let sentDate: Date
    let id: String?
    
    var kind: MessageKind {
        return .text(content)
    }
    
    var messageId: String {
        return id ?? UUID().uuidString
    }
    
    
    init(user: User, content: String) {
        sender = Sender(id: user.uid, displayName: AppSettings.displayName)
        self.content = content
        sentDate = Date()
        id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        print(data)
        
        guard let sentDate = data["created"] as? Timestamp else {
            print("sent date nil")
            return nil
        }
        guard let senderID = data["senderID"] as? String else {
            print("sender id nil")
            return nil
        }
        guard let senderName = data["senderName"] as? String else {
            print("sender name nil")
            return nil
        }
        
        id = document.documentID
        
        self.sentDate = sentDate.dateValue()
        sender = Sender(id: senderID, displayName: senderName)
        
        if let content = data["content"] as? String {
            self.content = content
        } else {
            print("content nil")
            return nil
        }
    }
    
}

extension Message: DatabaseRepresentation {
    
    var representation: [String : Any] {
        var rep: [String : Any] = [
            "created": sentDate,
            "senderID": sender.senderId,
            "senderName": sender.displayName
        ]
        
        rep["content"] = content
        
        return rep
    }
    
}

extension Message: Comparable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}
