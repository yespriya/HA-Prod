import Foundation
import UIKit
import Alamofire
import RxSwift

class AuthViewModel {
    // Properties
    private let userRepository = UserRepository()
    private let disposeBag = DisposeBag()
    
    var commonTokenResponse: BaseResponse<AccessToken>?
    var termsAndConditionsRes: TermsAndConditionsModel?

    var signInData: SigninResModel?
    var error: Error?
    var errorMessage: String?
    var isError = false
    
    var isLoading: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.loadingStatus?()
            }
        }
    }

    
    // Closures for callback
    var registerSuccess: (() -> Void)?
    var generateOTPSuccess: (() -> Void)?
    var verifyOTPSuccess: (() -> Void)?
    var updatePasswordSuccess: (() -> Void)?
    var changePasswordSuccess: (() -> Void)?
    var fetchTermsAndContionsSuccess: (() -> Void)?
    var sendTNCSuccess: (() -> Void)?


    var signInSuccess: (() -> Void)?
    var loadingStatus: (() -> Void)?
    var errorMessageAlert: (() -> Void)?

    // Signup User
    /*
    func signupUser(params: [String: Any]) {
        isLoading = true
        APIClient.signupUser(params: params) { result in
            self.isLoading = false

            switch result {
            case .success(let responseData):
                guard let statusCode = responseData.statuscode else {
                    debugPrint("Unknown Error: Status code is nil")
                    return
                }

                switch statusCode {
                case 200..<300:
                    self.signupRes = responseData
                    self.registerSuccess?()
                case 400..<501:
                    self.errorMessage = responseData.message
                    self.errorMessageAlert?()
                default:
                    debugPrint("Unknown Error: Status code \(statusCode)")
                }

            case .failure(let error):
                debugPrint("Request failed with error: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                self.error = error
            }
        }
    }
    */

    // Sign up
    func signUp(model: SignupRequestModel, completion: ((Bool) -> Void)? = nil) {
        userRepository.signup(with: model, isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                self?.commonTokenResponse = response
                if response.status ?? false == false {
                    self?.errorMessage = response.message
                    self?.isError = true
                    self?.errorMessageAlert?()
                    completion?(false)
                } else {
                    KeychainManager.shared.save(key: "accessToken", value: response.data?.token ?? "")
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.isError = true
                self?.errorMessageAlert?()
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
    
    // Signin User with Email
    func signIn(model: SignInRequestModel, completion: ((Bool) -> Void)? = nil) {
        userRepository.signIn(with: model, isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                self?.commonTokenResponse = response
                if response.status ?? false == false {
                    self?.errorMessage = response.message
                    self?.isError = true
                    self?.errorMessageAlert?()
                    completion?(false)
                } else {
                    KeychainManager.shared.save(key: "accessToken", value: response.data?.token ?? "")
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.isError = true
                self?.errorMessageAlert?()
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
    
    // Signin User
    func socialSignIn(model: SignInRequestModel, completion: ((Bool) -> Void)? = nil) {
        userRepository.socialAuth(with: model, isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                self?.commonTokenResponse = response
                if response.status ?? false == false {
                    self?.errorMessage = response.message
                    self?.isError = true
                    self?.errorMessageAlert?()
                    completion?(false)
                } else {
                    KeychainManager.shared.save(key: "accessToken", value: response.data?.token ?? "")
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.isError = true
                self?.errorMessageAlert?()
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
    
    // Signin User
    func generateOTP(model: OTPRequestModel, completion: ((Bool) -> Void)? = nil) {
        userRepository.generateOTP(with: model, isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                self?.commonTokenResponse = response
                if response.status ?? false == false {
                    self?.errorMessage = response.message
                    self?.isError = true
                    self?.errorMessageAlert?()
                    completion?(false)
                } else {
                    KeychainManager.shared.save(key: "accessToken", value: response.data?.token ?? "")
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.isError = true
                self?.errorMessageAlert?()
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
    
    // Signin User
    func verifyOTP(email: String, otp: String, completion: ((Bool) -> Void)? = nil) {
        userRepository.verifyOTP(with: email, otp: otp, isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                self?.commonTokenResponse = response
                if response.status ?? false == false {
                    self?.errorMessage = response.message
                    self?.isError = true
                    self?.errorMessageAlert?()
                    completion?(false)
                } else {
                    KeychainManager.shared.save(key: "accessToken", value: response.data?.token ?? "")
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.isError = true
                self?.errorMessageAlert?()
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
    
    // Update Password
    func updatePassword(model: SignInRequestModel, completion: ((Bool) -> Void)? = nil) {
        userRepository.updatePassword(with: model, isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                self?.commonTokenResponse = response
                if response.status ?? false == false {
                    self?.errorMessage = response.message
                    self?.isError = true
                    self?.errorMessageAlert?()
                    completion?(false)
                } else {
                    KeychainManager.shared.save(key: "accessToken", value: response.data?.token ?? "")
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.isError = true
                self?.errorMessageAlert?()
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
    
    // Change Password
    func changePassword(old: String, new: String, completion: ((Bool) -> Void)? = nil) {
        userRepository.changePassword(with: old, newPassword: new, isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                self?.commonTokenResponse = response
                if response.status ?? false == false {
                    self?.errorMessage = response.message
                    self?.isError = true
                    self?.errorMessageAlert?()
                    completion?(false)
                } else {
                    KeychainManager.shared.save(key: "accessToken", value: response.data?.token ?? "")
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.isError = true
                self?.errorMessageAlert?()
                completion?(false)
            })
            .disposed(by: disposeBag)
    }

    func sendTNC(email: String, completion: ((Bool) -> Void)? = nil) {
        userRepository.sendTNC(with: email, isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                self?.commonTokenResponse = response
                if response.status ?? false == false {
                    self?.errorMessage = response.message
                    self?.isError = true
                    self?.errorMessageAlert?()
                    completion?(false)
                } else {
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.isError = true
                self?.errorMessageAlert?()
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
}

