import Foundation
import UIKit
import Alamofire
import RxSwift

class ProfileViewModel {
    // Properties
    
    var profileCompletionRes: ProfileCompletionModel? {
        didSet {
            self.profileCompletionFetchSuccess?()
        }
    }

    var error: Error? {
        didSet {
            self.errorMessageAlert?()
        }
    }

    var errorMessage: String?

    var isLoading: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.loadingStatus?()
            }
        }
    }
    
    private let userRepository = UserRepository()
    private let disposeBag = DisposeBag()
    
    var profileDetailsRes: ProfileData?
    var userUpdateRes: BaseResponse<Empty>?
    var uploadProfileResponse: BaseResponse<UserProfileImage>?
    
    // Closures for callback
    var profileFetchSuccess: (() -> Void)?
    var profileCompletionFetchSuccess: (() -> Void)?

    var loadingStatus: (() -> Void)?
    var errorMessageAlert: (() -> Void)?

    // Fetch User Details
    func fetchUserDetails(completion: ((Bool) -> Void)? = nil) {
        userRepository.userDetails(isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                if response.status ?? false == false {
                    if response.statuscode == 401 {
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.redirectToLogin(errorMsg: response.message)
                        }
                    }
                    completion?(false)
                } else {
                    self?.profileDetailsRes = response.data
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.errorMessageAlert?()
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
    
    // Fetch Profile Completion Status
    func fetchProfileCompletionStatus(params: [String: Any]) {
        isLoading = true

        APIClient.fetchProfileCompletion(params: params) { result in
            self.isLoading = false

            switch result {
            case .success(let responseData):
                guard let statusCode = responseData.statuscode else {
                    self.errorMessage = "Unknown Error: Status code is nil"
                    self.errorMessageAlert?()
                    return
                }

                switch statusCode {
                case 200..<300:
                    self.profileCompletionRes = responseData
                case 401:
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.redirectToLogin(errorMsg: responseData.message)
                    }
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

    // Update User Details
    func updateUserDetails(model: UserProfileRequest, completion: ((Bool) -> Void)? = nil) {
        userRepository.updateUserDetails(with: model, isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                if response.status ?? false == false {
                    if response.statuscode == 401 {
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.redirectToLogin(errorMsg: response.message)
                        }
                    }
                    completion?(false)
                } else {
                    self?.userUpdateRes = response
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.errorMessageAlert?()
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
    
    // Delete Profile Image
    func uploadProfileImage(image: UIImage, completion: ((Bool) -> Void)? = nil) {
        
        let uploadData = APIUploadData(
            id: UUID().uuidString,
            image: image.jpegData(compressionQuality: 0.7),
            fileType: "",
            mimeType: "image/jpeg",
            fileName: "\(UUID().uuidString).png"
        )
        
        userRepository.uploadProfileImage(data: uploadData, isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                if response.status ?? false == false {
                    if response.statuscode == 401 {
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.redirectToLogin(errorMsg: response.message)
                        }
                    }
                    self?.errorMessage = response.message
                    self?.errorMessageAlert?()
                    completion?(false)
                } else {
                    self?.uploadProfileResponse = response
                    print(response)
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.errorMessageAlert?()
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
    
    // Delete Profile Image
    func deleteProfileImage(completion: ((Bool) -> Void)? = nil) {
        userRepository.deleteProfileImage(isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                if response.status ?? false == false {
                    if response.statuscode == 401 {
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.redirectToLogin(errorMsg: response.message)
                        }
                    }
                    self?.errorMessage = response.message
                    self?.errorMessageAlert?()
                    completion?(false)
                } else {
                    self?.userUpdateRes = response
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.errorMessageAlert?()
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
}

