//
//  HealthHubRepository.swift
//  HA Prod
//
//  Created by Prit  on 21/02/26.
//

import Foundation
import RxSwift
import Alamofire

struct HealthHubRepository {
    let api: APIService = .shared
    
    // fetch weekly unlock content
    func fetchWeeklyUnlockContent(isShowLoader: Bool) -> Single<BaseResponse<[String: Bool]>> {
        return api.request(router: .fetchWeeklyUnlockContent, checking: isShowLoader ? .checked : .unchecked)
    }
    
    // fetch dropdown data
    func fetchHealthHubDropDownData(isShowLoader: Bool) -> Single<BaseResponse<[HealthHubDropDownData]>> {
        return api.request(router: .fetchHealthHubDropDownData, checking: isShowLoader ? .checked : .unchecked)
    }
    
    // fetch dropdown data
    func fetchHealthHubOverviewData(isShowLoader: Bool) -> Single<BaseResponse<[HealthhubOverView]>> {
        return api.request(router: .fetchHealthHubOverviewData, checking: isShowLoader ? .checked : .unchecked)
    }
    
    // fetch Weekly Content
    func fetchWeeklyContent(weekNumber: String, isShowLoader: Bool) -> Single<BaseResponse<HealthData>> {
        return api.request(router: .fetchWeeklyContent(weekNumber: weekNumber), checking: isShowLoader ? .checked : .unchecked)
    }
}
