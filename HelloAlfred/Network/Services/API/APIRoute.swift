//
//  APIRoute.swift
//  HA Prod
//
//  Created by Prit  on 04/02/26.
//

import Foundation
import Alamofire

enum APIRoute {
    
    // users
    case signup(model: SignupRequestModel)
    case signIn(model: SignInRequestModel)
    case socialAuth(model: SignInRequestModel)
    case updatePassword(model: SignInRequestModel)
    case generateOtp(model: OTPRequestModel)
    case verifyOTP(email: String, otp: String)
    case changePassword(old: String, new: String)
    case sendTNC(email: String)
    
    var method: HTTPMethod {
        switch self {
        case .signup, .signIn, .socialAuth, .generateOtp, .verifyOTP, .sendTNC:
            return .post
        case .updatePassword, .changePassword:
            return .put
        default:
            return .get
        }
    }
    
    var url: String {
        switch self {
        default:
            return DataService.developmentBaseURL
        }
    }
    
    var path: String {
        switch self {
        case .signup:
            return "common/create_account"
        case .signIn:
            return "common/login_account"
        case .socialAuth:
            return "common/socialauth"
        case .generateOtp:
            return "common/generate_otp"
        case .updatePassword:
            return "common/update_password"
        case .changePassword:
            return "change-password"
        case .verifyOTP:
            return "common/verify_otp"
        case .sendTNC:
            return "common/send_tnc"
        }
    }
    
    var params: [String: Any]? {
        switch self {
        case .signup(let model):
            return parseModel(data: model)
            
        case .signIn(let model):
            return parseModel(data: model)
            
        case .socialAuth(let model):
            return parseModel(data: model)
            
        case .generateOtp(let model):
            return parseModel(data: model)
        
        case .updatePassword(let model):
            return parseModel(data: model)
        
        case .verifyOTP(let email, let otp):
            return ["email": email, "otp": otp]
        
        case .changePassword(let old, let new):
            return ["old_password": old, "new_password": new]
        
        case .sendTNC(let email):
            return ["email": email]
            
        default:
            return nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .signIn, .signup, .socialAuth, .generateOtp, .updatePassword, .verifyOTP, .sendTNC, .changePassword:
            return JSONEncoding.default
        default:
            return URLEncoding.queryString
        }
    }
    
    var needAuthorization: Bool {
        switch self {
        case .signIn, .signup, .socialAuth, .generateOtp, .updatePassword, .verifyOTP, .sendTNC, .changePassword:
            return true
        default:
            return false
        }
    }
    
    func convertJsonToDictionary(jsonData: Data) -> [String: Any]? {
        do {
            if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                return jsonDict
            }
        } catch let error {
            print("Failed to convert JSON to dictionary: \(error.localizedDescription)")
        }
        return nil
    }
    
    func parseModel<T: Codable>(data: T) -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(data) else { return nil }
        return convertJsonToDictionary(jsonData: data)
    }
    
    var header: [String: String] {
        var header = ["Content-Type": "application/json; charset=utf-8",
                      "Accept": "application/json"]
        
        if needAuthorization {
            let token = KeychainManager.shared.retrieve(for: "accessToken") ?? ""
            header["Authorization"] = "Bearer \(token)"
        } else {
            print("Auth token is not passed in ", self.path)
        }
        return header
    }
    
}

extension APIRoute: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        let url = path.isEmpty ? try url.asURL() : try url.asURL().appendingPathComponent(path)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.cachePolicy = .reloadIgnoringCacheData
        urlRequest.timeoutInterval = 60
        urlRequest.headers = HTTPHeaders(header)
        urlRequest = try encoding.encode(urlRequest, with: params)
        return urlRequest
    }
    
    func multipartFormData() -> MultipartFormData {
        let multipartFormData = MultipartFormData()
        switch self {
            /*
        case let .uploadSecretImage(uploadData):
            multipartFormData.appendUploadData(uploadData)
        case let .uploadMultipleImages(uploadDataList):
            uploadDataList.forEach { multipartFormData.appendUploadData($0) }
            */
        default:
            break
        }
        return multipartFormData
    }
}
