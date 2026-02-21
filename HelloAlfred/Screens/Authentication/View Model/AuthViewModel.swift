import Foundation
import UIKit
import Alamofire
import RxSwift

class AuthViewModel {
    // Properties
    private let userRepository = UserRepository()
    private let disposeBag = DisposeBag()
    
    var commonTokenResponse: BaseResponse<AccessToken>?
    var simpleResponse: SimpleResponse?
    var termsAndCondtionsResponse: TermsAndConditionsData?

    var error: Error?
    var errorMessage: String?
    var isError = false
    var errorMessageAlert: (() -> Void)?

    // Sign up
    func signUp(model: SignupRequestModel, completion: ((Bool) -> Void)? = nil) {
        userRepository.signup(with: model, isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                self?.commonTokenResponse = response
                if response.status ?? false == false {
                    if response.statuscode == 401 {
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.redirectToLogin(errorMsg: response.message)
                        }
                    }
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
                    if response.statuscode == 401 {
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.redirectToLogin(errorMsg: response.message)
                        }
                    }
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
    
    // Generate OTP
    func generateOTP(model: OTPRequestModel, completion: ((Bool) -> Void)? = nil) {
        userRepository.generateOTP(with: model, isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                self?.simpleResponse = response
                if response.status ?? false == false {
                    if response.statuscode == 401 {
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.redirectToLogin(errorMsg: response.message)
                        }
                    }
                    self?.errorMessage = response.message
                    self?.isError = true
                    self?.errorMessageAlert?()
                    completion?(false)
                } else {
                    if response.statuscode == 400 {
                        self?.errorMessage = response.message ?? ""
                        self?.isError = true
                        self?.errorMessageAlert?()
                        completion?(false)
                    } else {
                        completion?(true)
                    }
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.isError = true
                self?.errorMessageAlert?()
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
    
    // Verify OTP
    func verifyOTP(email: String, otp: String, completion: ((Bool) -> Void)? = nil) {
        userRepository.verifyOTP(with: email, otp: otp, isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                self?.simpleResponse = response
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
    
    // Update Password
    func updatePassword(model: SignInRequestModel, completion: ((Bool) -> Void)? = nil) {
        userRepository.updatePassword(with: model, isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                self?.simpleResponse = response
                if response.status ?? false == false {
                    if response.statuscode == 401 {
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.redirectToLogin(errorMsg: response.message)
                        }
                    }
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
    
    // Change Password
    func changePassword(old: String, new: String, completion: ((Bool) -> Void)? = nil) {
        userRepository.changePassword(with: old, newPassword: new, isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                self?.simpleResponse = response
                if response.status ?? false == false {
                    if response.statuscode == 401 {
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.redirectToLogin(errorMsg: response.message)
                        }
                    }
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

    // Accept Terms and Condtions
    func acceptTermsAndConditions(model: TermsAcceptRequest, completion: ((Bool) -> Void)? = nil) {
        userRepository.acceptTermsAndConditions(with: model, isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                self?.simpleResponse = response
                if response.status ?? false == false {
                    if response.statuscode == 401 {
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.redirectToLogin(errorMsg: response.message)
                        }
                    }
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
    
    // Fetch Terms and Conditions
    func fetchTermsAndCondtions(completion: ((Bool) -> Void)? = nil) {
        userRepository.fetchTermsAndConditions(isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                if response.status ?? false == false {
                    if response.statuscode == 401 {
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.redirectToLogin(errorMsg: response.message)
                        }
                    }
                    completion?(false)
                } else {
                    self?.termsAndCondtionsResponse = response.data
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.errorMessageAlert?()
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
    
    // Send Terms and Conditions
    func sendTNC(email: String, completion: ((Bool) -> Void)? = nil) {
        userRepository.sendTNC(with: email, isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                self?.simpleResponse = response
                if response.status ?? false == false {
                    if response.statuscode == 401 {
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.redirectToLogin(errorMsg: response.message)
                        }
                    }
                    
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

