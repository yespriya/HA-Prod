//
//  QuizViewModel.swift
//  HelloAlfred
//
//  Created by SS on 07/08/25.
//

import UIKit
import RxSwift

class QuizViewModel {
    
    // Properties
    
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

    private let quizRepository = QuizRepository()
    private let disposeBag = DisposeBag()
    
    var quizResponseData: BaseResponse<QuestionData>?
    // Closures for callback
    var loadingStatus: (() -> Void)?
    var errorMessageAlert: (() -> Void)?
    
    // Fetch quiz questions
    func fetchQuizQuestions(weekNumber: String, completion: ((Bool) -> Void)? = nil) {
        quizRepository.fetchQuizQuestions(weekNumber: weekNumber, isShowLoader: true)
            .subscribe(onSuccess: { [weak self] response in
                
                if let statusCode = response.statuscode, (400..<501).contains(statusCode) {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.redirectToLogin(errorMsg: response.message)
                    }
                }
                
                if response.status ?? false == false {
                    self?.errorMessage = response.message
                    completion?(false)
                } else {
                    self?.quizResponseData = response
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
    
    func evaluateAnswer(with params: [String: Any], completion: @escaping ((QuestionEvaluatedResponseData) -> Void)) {
        isLoading = true
        
        APIClient.evaluateQuizAnswers(params: params) { result in
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
                    if let data = responseData.data {
                        completion(data)
                    }
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
}
