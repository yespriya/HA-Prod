import Foundation
import UIKit
import Alamofire
import RxSwift

class DashboardViewModel {
    // Properties
    
    private let userRepository = UserRepository()
    private let disposeBag = DisposeBag()
    
    var userStatusRes: UserStatusModel?
    var userStatusUpdateRes: CommonResModel?
    var error: Error?
    var errorMessage: String?
    
    var isLoading: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.loadingStatus?()
            }
        }
    }

    
    // Closures for callback
    var userStatusFetchSuccess: (() -> Void)?
    var statusUpdateSuccess: (() -> Void)?
    var loadingStatus: (() -> Void)?
    var errorMessageAlert: (() -> Void)?
    
    // Fetch User Status Details
    func fetchUserStatusDetails(completion: ((Bool) -> Void)? = nil) {
        userRepository.getUserStatus(isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                if response.status ?? false == false {
                    if (response.statuscode == 401 || response.statuscode == 402) {
                        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                            appDelegate.redirectToLogin(errorMsg: response.message)
                        }
                    }
                    self?.errorMessage = self?.error?.localizedDescription
                    self?.errorMessageAlert?()
                    completion?(false)
                } else {
                    self?.userStatusRes = response.data
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.errorMessageAlert?()
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
    
    // Update User Details
    func setUserStatus(model: UserStatusModel, completion: ((Bool) -> Void)? = nil) {
        userRepository.setUserStatus(with: model, isShowLoader: true)
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
