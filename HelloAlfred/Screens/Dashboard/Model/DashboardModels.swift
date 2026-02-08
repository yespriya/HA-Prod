//
//  DashboardModels.swift
//  HA Prod
//
//  Created by Prit  on 08/02/26.
//

import Foundation

struct UserStatusModel: Codable {
    var health_hub: Int? = nil
    var list_your_symptoms: Int? = nil
    var lifestyle_goals: Int? = nil
    var expert_monitoring: Int? = nil
    var optimal_risk_managemment: Int? = nil
    
}
