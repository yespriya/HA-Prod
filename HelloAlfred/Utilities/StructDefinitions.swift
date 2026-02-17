//
//  StructDefinitions.swift
//  HelloAlfred
//
//  Created by admin on 02/09/24.
//

import Foundation
import UIKit

struct Category {
    let name: String
    let unit: String
    let image: String
    let bgColor: String
    let value: String
    
}

struct Categories {
    var lifeStyleCategories: [Category]
    var riskFactorsCategories: [Category]
    var afibCategories: [Category]
}

// MARK: - CategoryDetails Struct

struct CategoryDetails {
    let name: String
    let unit: String
    let image: String
    let bgColor: String
    let value: String
    let unfilledColour: String
    let filledColour: String
}
struct CardDetailsView
{
    let cardNumber:String;
    let bankName:String
    let bankLogo:String
}
struct SignupUserData{
    var firstName: String?  = nil
    var lastName: String? = nil
    var email: String? = nil
    var dob: String? = nil
    var gender: String? = nil
    var mobile: String? = nil
    var rtype: String? = nil
    var education: String? = nil
    var ssn: String? = nil
    var insuranceurl: String? = nil
    var password: String? = nil
    var nationality: String? = nil


       
}
struct QAObject {
    var question_id: String
    var answer: String
}

struct IntroData
{
    var introImage: UIImage
    var title: String
    var description: String
}

struct UserSymptomsData {
        var categoryIndex: Int?
        var frequency: String?
        var severity: String?
        var eql: Bool?
}

struct Message {
    var text: String
    var isSender: Bool // true if sender, false if receiver
    var isLoading: Bool = false // optional parameter with default value as false
    var isLiked: Bool = false
    var isDisLiked: Bool = false
    var isDislikePopupOpened: Bool = false
}
