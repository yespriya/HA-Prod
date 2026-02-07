//
//  ProfileModels.swift
//  HA Prod
//
//  Created by Prit  on 07/02/26.
//

import Foundation

struct UserProfileRequest: Codable {
    let username: String?
    let dob: String?
    let gender: String?
    let mobile: String?
    let rtype: String?
    let education: String?
    let ssn: String?
    let feet: String?
    let inch: String?
    let weight: String?
    let bloodtype: String?
}

struct UserProfileImage : Codable {
    let profile_img: String?
}
