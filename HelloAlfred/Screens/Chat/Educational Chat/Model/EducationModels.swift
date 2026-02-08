//
//  ShareChatEmail.swift
//  HelloAlfred
//
//  Created by SS on 06/09/25.
//

import Foundation

struct ShareChatEmail : Codable {
    let status : Bool?
    let statuscode : Int?
    let message : String?
    let data : String?
}

struct ChatSaveModel: Codable {
    let session_id: String?
    let alfred: String?
    let user: String?
    let refference: [String: String]?
}

struct PrefereceChatModel: Codable {
    let question: String?
    let message: String?
    let preference: Bool?
    let comment: String?
}

struct BotStaticMessage: Codable {
    let message_type: String?
    let welcome_message: String?
}
