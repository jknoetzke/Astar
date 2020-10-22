//
//  StravaAnalyticsData.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-10-21.
//

import Foundation

struct StravaData: Decodable {
    
    let expires_at: Int
    let expires_in: Int
    let refresh_token: String
    let access_token: String
    
    
}
