//
//  CountryData.swift
//  Covid19
//
//  Created by user on 19.04.2020.
//  Copyright © 2020 ulkoart. All rights reserved.
//

import Foundation

struct CountryDataResponse: Codable {
    let lat: String
    let lon: String
    let confirmed: Int32
    let deaths: Int32
    let recovered: Int32
    let active: Int32

    enum CodingKeys: String, CodingKey {
        case lat = "Lat"
        case lon = "Lon"
        case confirmed = "Confirmed"
        case deaths = "Deaths"
        case recovered = "Recovered"
        case active = "Active"

    }

}
