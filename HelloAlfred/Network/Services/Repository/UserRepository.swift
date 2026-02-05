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
    func signup(with model: SignupRequestModel, isShowLoader: Bool) -> Single<BaseResponse<AccessToken>> {
        return api.request(router: .signup(model: model), checking: isShowLoader ? .checked : .unchecked)
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
    
    // updatePassword
    func updatePassword(with model: SignInRequestModel, isShowLoader: Bool) -> Single<BaseResponse<AccessToken>> {
        return api.request(router: .updatePassword(model: model), checking: isShowLoader ? .checked : .unchecked)
    }
    
    // verify otp
    func verifyOTP(with email: String, otp: String, isShowLoader: Bool) -> Single<BaseResponse<AccessToken>> {
        return api.request(router: .verifyOTP(email: email, otp: otp), checking: isShowLoader ? .checked : .unchecked)
    }
    
    // change password
    func changePassword(with oldPassword: String, newPassword: String, isShowLoader: Bool) -> Single<BaseResponse<AccessToken>> {
        return api.request(router: .changePassword(old: oldPassword, new: newPassword), checking: isShowLoader ? .checked : .unchecked)
    }

    // sendTNC
    func sendTNC(with email: String, isShowLoader: Bool) -> Single<BaseResponse<AccessToken>> {
        return api.request(router: .sendTNC(email: email), checking: isShowLoader ? .checked : .unchecked)
    }
}
