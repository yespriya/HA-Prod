import Foundation
import UIKit
import Alamofire
import RxSwift

class HealthHubViewModel {
    // Properties
    
    var healthHubUpdateStatusRes: HealthHubStatusResponse? {
        didSet {
            self.healthHubStatusUpdateSuccess?()
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

    private let healthRepository = HealthHubRepository()
    private let disposeBag = DisposeBag()
    
    var weeklyUnlockContent: BaseResponse<[String: Bool]>?
    var dropDownResData: [HealthHubDropDownData]?
    var overviewResData: [HealthhubOverView]?
    var weeklyContentResData: HealthData?
    
    // Closures for callback
    var healthHubStatusUpdateSuccess: (() -> Void)?
    var loadingStatus: (() -> Void)?
    var errorMessageAlert: (() -> Void)?
    
    // Fetch Weekly Content
    func fetchWeeklyContent(weekNumber: String, completion: ((Bool) -> Void)? = nil) {
        healthRepository.fetchWeeklyContent(weekNumber: weekNumber, isShowLoader: false)
            .subscribe(onSuccess: { [weak self] response in
                if let statusCode = response.statuscode, (400..<501).contains(statusCode) {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.redirectToLogin(errorMsg: response.message)
                    }
                }
                if response.status ?? false == false {
                    completion?(false)
                } else {
                    self?.weeklyContentResData = response.data
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.errorMessageAlert?()
                self?.error = error
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
    
    // Fetch Week Status
    func fetchWeeklyUnlockContent(completion: ((Bool) -> Void)? = nil) {
        healthRepository.fetchWeeklyUnlockContent(isShowLoader: false)
            .subscribe(onSuccess: { [weak self] response in
                if let statusCode = response.statuscode, (400..<501).contains(statusCode) {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.redirectToLogin(errorMsg: response.message)
                    }
                }
                
                if response.status ?? false == false {
                    completion?(false)
                } else {
                    self?.weeklyUnlockContent = response
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.errorMessageAlert?()
                self?.error = error
                completion?(false)
            })
            .disposed(by: disposeBag)
    }

    // Fetch Week Status
    func fetchHealthHubDropDownData(completion: ((Bool) -> Void)? = nil) {
        healthRepository.fetchHealthHubDropDownData(isShowLoader: false)
            .subscribe(onSuccess: { [weak self] response in
                
                if let statusCode = response.statuscode, (400..<501).contains(statusCode) {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.redirectToLogin(errorMsg: response.message)
                    }
                }
                
                if response.status ?? false == false {
                    completion?(false)
                } else {
                    self?.dropDownResData = response.data
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.errorMessageAlert?()
                self?.error = error
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
    
    // Fetch HealthHub Overview
    func fetechHealthHubOverview(completion: ((Bool) -> Void)? = nil) {
        healthRepository.fetchHealthHubOverviewData(isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                
                if let statusCode = response.statuscode, (400..<501).contains(statusCode) {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.redirectToLogin(errorMsg: response.message)
                    }
                }
                
                if response.status ?? false == false {
                    completion?(false)
                } else {
                    self?.overviewResData = response.data
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.errorMessageAlert?()
                self?.error = error
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
    
    func updateHealthHubStatus(params: [String: Any]) {
        isLoading = true
        APIClient.updateHealthHubStatus(params: params) { result in
            self.isLoading = false
            switch result {
            case .success(let responseData):
                guard let statusCode = responseData.statuscode else {
                    self.errorMessage = "Unknown Error: Status code is nil"
                    self.error = self.error
                    return
                }
                switch statusCode {
                case 200..<300:
                    self.healthHubUpdateStatusRes = responseData
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
    
    func getLatestUnlockedModule() -> HealthHubDropDownData? {
        guard let weekStatus = weeklyUnlockContent?.data,
              let dropDownData = dropDownResData else {
            return nil
        }
        
        // The dropdown list from the API determines the TRUE chronological order.
        // We traverse it backwards to find the last module that is unlocked.
        for module in dropDownData.reversed() {
            guard let weekKey = module.value else { continue }
            
            // Check if this module's value (e.g., "week20") is true/1 in the status response
            if weekStatus[weekKey] == true {
                return module
            }
        }
        
        // Fallback to the first module if nothing is marked as unlocked yet
        return dropDownData.first
    }
}

