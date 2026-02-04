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
    
    // signup
    func signIn(with model: SignInRequestModel, isShowLoader: Bool) -> Single<BaseResponse<AccessToken>> {
        return api.request(router: .signIn(model: model), checking: isShowLoader ? .checked : .unchecked)
    }

}
