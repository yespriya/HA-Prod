
import Foundation

struct CommonResModel : Codable {
	let message : String?
	let statuscode : Int?
	let status : Bool?
    let data : AccessToken?
}

struct AccessToken : Codable {
    let token : String?
    let terms: Terms?
}

import Foundation

// MARK: - WelcomeElement
struct HealthHubStatusResponse: Codable {
    let status: Bool?
    let statuscode: Int?
    let message: String?
    let data: DataUnion?
}

enum DataUnion: Codable {
    case bool(Bool)
    case dataClass(DataClass)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
            return
        }
        
        if let x = try? container.decode(Bool.self) {
            self = .bool(x)
            return
        }
        if let x = try? container.decode(DataClass.self) {
            self = .dataClass(x)
            return
        }
        throw DecodingError.typeMismatch(DataUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for DataUnion"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let x):
            try container.encode(x)
        case .dataClass(let x):
            try container.encode(x)
        case .null:
            try container.encodeNil()
        }
    }
}

// MARK: - DataClass
struct DataClass: Codable {
    let quizStatus: Bool

    enum CodingKeys: String, CodingKey {
        case quizStatus = "quiz_status"
    }
}
