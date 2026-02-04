//
//  APIRoute.swift
//  HA Prod
//
//  Created by Prit  on 04/02/26.
//

import Foundation
import Alamofire

enum APIRoute {
    /// cars
    case fetchAddress(input: String)
    case signup(model: SignupRequestModel)
    case signIn(model: SignInRequestModel)
    
    var method: HTTPMethod {
        switch self {
        case .signup, .signIn:
            return .post
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
        case .fetchAddress:
            return "address/search"
        }
    }
    
    var params: [String: Any]? {
        switch self {
        case .signup(let model):
            return parseModel(data: model)
        case .signIn(let model):
            return parseModel(data: model)
        case .fetchAddress(let input):
            let params: [String: Any] = ["input": input]
            return params
        default:
            return nil
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
    
    var encoding: ParameterEncoding {
        switch self {
        case .signIn:
            return JSONEncoding.default
        default:
            return URLEncoding.queryString
        }
    }
    
    var needAuthorization: Bool {
        switch self {
        case .fetchAddress:
            return true
        default:
            return false
        }
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
