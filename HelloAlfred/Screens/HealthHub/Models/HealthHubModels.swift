
import Foundation

// Healthhub weekly content

struct HealthData : Codable {
    let week_title : String?
    let week_desc : String?
    let week_objective : String?
    let week_explanation : String?
    let week_activity : String?
    let content : [WeeklyContent]?

    enum CodingKeys: String, CodingKey {

        case week_title = "week_title"
        case week_desc = "week_desc"
        case content = "content"
        case week_objective = "week_objective"
        case week_explanation = "week_explanation"
        case week_activity = "week_activity"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        week_title = try values.decodeIfPresent(String.self, forKey: .week_title)
        week_desc = try values.decodeIfPresent(String.self, forKey: .week_desc)
        week_objective = try values.decodeIfPresent(String.self, forKey: .week_objective)
        week_explanation = try values.decodeIfPresent(String.self, forKey: .week_explanation)
        week_activity = try values.decodeIfPresent(String.self, forKey: .week_activity)
        content = try values.decodeIfPresent([WeeklyContent].self, forKey: .content)
    }

}

struct WeeklyContent : Codable {
    let photo : String?
    let title : String?
    let video : String?
    let causes : Causes?
    let description : String?
    let thumbnail : String?

    enum CodingKeys: String, CodingKey {

        case photo = "photo"
        case title = "title"
        case video = "video"
        case causes = "Causes"
        case description = "description"
        case thumbnail = "thumbnail"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        photo = try values.decodeIfPresent(String.self, forKey: .photo)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        video = try values.decodeIfPresent(String.self, forKey: .video)
        causes = try values.decodeIfPresent(Causes.self, forKey: .causes)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        thumbnail = try values.decodeIfPresent(String.self, forKey: .thumbnail)
    }

}

struct Causes : Codable {
    let other_Factors : String?
    let heart_Conditions : String?

    enum CodingKeys: String, CodingKey {

        case other_Factors = "Other_Factors"
        case heart_Conditions = "Heart_Conditions"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        other_Factors = try values.decodeIfPresent(String.self, forKey: .other_Factors)
        heart_Conditions = try values.decodeIfPresent(String.self, forKey: .heart_Conditions)
    }

}

// Healthhub Dropdown
struct HealthHubDropDownData : Codable {
    let value : String?
    let label : String?
    let quizKey : String?
    let title: String?
}

// Healthhub Overview
struct HealthhubOverView: Codable {
    let week: Week
    let title: String
    let list: [String]
}

enum Week: Codable {
    case string(String)
    case stringArray([String])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([String].self) {
            self = .stringArray(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(Week.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Week"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
        case .stringArray(let x):
            try container.encode(x)
        }
    }
}
