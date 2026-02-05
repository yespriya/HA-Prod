//
//  UserRepository.swift
//  HA Prod
//
//  Created by Prit  on 04/02/26.
//

import Foundation
import RxSwift

struct UserRepository {
    let api: APIService = .shared
    
    // signup
    func signup(with model: SignupRequestModel) -> Single<BaseResponse<AccessToken>> {
        return api.request(router: .signup(model: model))
    }
    
    // signIn
    func signIn(with model: SignInRequestModel, isShowLoader: Bool) -> Single<BaseResponse<AccessToken>> {
        return api.request(router: .signIn(model: model), checking: isShowLoader ? .checked : .unchecked)
    }
    
    // socialAuth
    func socialAuth(with model: SignInRequestModel, isShowLoader: Bool) -> Single<BaseResponse<AccessToken>> {
        return api.request(router: .socialAuth(model: model), checking: isShowLoader ? .checked : .unchecked)
    }
     
    // generate OTP
    func generateOTP(with model: OTPRequestModel, isShowLoader: Bool) -> Single<BaseResponse<AccessToken>> {
        return api.request(router: .generateOtp(model: model), checking: isShowLoader ? .checked : .unchecked)
    }
}
