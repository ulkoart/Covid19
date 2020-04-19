//
//  CountriesResponse.swift
//  Covid19
//
//  Created by user on 19.04.2020.
//  Copyright © 2020 ulkoart. All rights reserved.
//

import Foundation

struct Country: Codable {
    let country: String
    let slug: String
    let ISO2: String
    
    enum CodingKeys: String, CodingKey {
        case country = "Country"
        case slug = "Slug"
        case ISO2
    }
    
}
