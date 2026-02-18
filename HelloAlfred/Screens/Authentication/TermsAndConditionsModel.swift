//
//  UserRepository.swift
//  HA Prod
//
//  Created by Prit  on 18/02/26.
//

import Foundation

struct TermsAndConditionsData : Codable {
    let content_html: String?
    let status: String?
    let title: String?
    let version: String?
}

struct Terms: Codable {
    let accepted: Bool?
    let required: Bool?
    let version: String?
}

struct TermsAcceptRequest: Codable {
    let version: String?
    let email: String?
    let source: String?
    var user_id: String? = nil
}
