//
//  SignInResModel.swift
//  HelloAlfred
//
//  Created by admin on 02/04/24.
//

import Foundation
struct SigninResModel : Codable 
{
    let statuscode : Int?
    let status : Bool?
    let message : String?
    let data : AccessToken?

    enum CodingKeys: String, CodingKey {

        case statuscode = "statuscode"
        case status = "status"
        case message = "message"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        statuscode = try values.decodeIfPresent(Int.self, forKey: .statuscode)
        status = try values.decodeIfPresent(Bool.self, forKey: .status)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        data = try values.decodeIfPresent(AccessToken.self, forKey: .data)
    }

}

struct SignupRequestModel: Codable {
    var email: String
    var dob: String
    var gender: String
    var mobile: String
    var rtype: String
    var education: String
    var ssn: String
    var insuranceurl: String
    var password: String
    var username: String
    var nationality: String
}

struct SignInRequestModel: Codable {
    var username: String
    var password: String
    var session_id: String
    var subdomain: String
}
