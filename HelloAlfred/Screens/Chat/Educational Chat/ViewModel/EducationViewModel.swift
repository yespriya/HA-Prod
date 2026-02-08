//
//  EducationViewModel.swift
//  HelloAlfred
//
//  Created by SS on 15/10/25.
//

import Foundation
import Alamofire
import UIKit
import RxSwift

class EducationChatViewModel {
    // Properties
    private let educationChatRepository = EducationChatRepository()
    private let disposeBag = DisposeBag()
    
    var staticMessageRes: BaseResponse<BotStaticMessage>?
    var preferenceChatRes: SimpleResponse?
    
    var errorMessage: String?
    var loadingStatus: (() -> Void)?
    var errorMessageAlert: (() -> Void)?
    
    // Fetch Static Message
    func fetchStaticMessage(completion: ((Bool) -> Void)? = nil) {
        educationChatRepository.getBotStaticMessage(isShowLoader: true)
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
                    self?.staticMessageRes = response
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.errorMessageAlert?()
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
    
    func preferenceChat(model: PrefereceChatModel, isShowLoader: Bool, completion: ((Bool) -> Void)? = nil) {
        educationChatRepository.pereferenceChat(with: model, isShowLoader: true)
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
                    self?.preferenceChatRes = response
                    completion?(true)
                }
            }, onFailure: { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.errorMessageAlert?()
                completion?(false)
            })
            .disposed(by: disposeBag)
    }
    
    func saveChat(model: ChatSaveModel, completion: ((Bool) -> Void)? = nil) {
        educationChatRepository.saveChat(with: model, isShowLoader: false)
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
