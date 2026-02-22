//
//  QuizRepository.swift
//  HA Prod
//
//  Created by Prit  on 22/02/26.
//

import Foundation
import RxSwift
import Alamofire

struct QuizRepository {
    let api: APIService = .shared
    
    // fetch quiz questions
    func fetchQuizQuestions(weekNumber: String, isShowLoader: Bool) -> Single<BaseResponse<QuestionData>> {
        return api.request(router: .fetchQuizQuestions(weekNumber: weekNumber), checking: isShowLoader ? .checked : .unchecked)
    }
}
