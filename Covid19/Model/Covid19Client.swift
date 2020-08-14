//
//  Covid19Client.swift
//  Covid19
//
//  Created by user on 19.04.2020.
//  Copyright © 2020 ulkoart. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Covid19Client {
    enum Endpoints {
        static let baseUrl = "https://api.covid19api.com/"
        
        case countries
        case countryData(String)
        
        var url: URL {
            return URL(string: self.stringValue)!
        }
        
        var stringValue: String {
            switch self {
            case .countries:
                return Covid19Client.Endpoints.baseUrl + "countries"
            case .countryData(let slug):
                return Covid19Client.Endpoints.baseUrl + "live/country/" + slug.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            }
        }
    }
}

extension Covid19Client {
    class func loadCountries(dataController:DataController, completionHandler: @escaping ([Country], Error?) -> Void) {
        let _ = taskGETRequest(url: Endpoints.countries.url, responseType: [Country].self) { countries, error in
            guard let countries = countries else {
                completionHandler([], error)
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                countries.forEach { (country) in
                    self.getCountryData(slug: country.slug) { (countryData, error) in
                                                
                        guard error == nil else {
                            completionHandler([], error)
                            return
                        }

                        if let countryData = countryData {
                            let fetchRequest:NSFetchRequest<CountryData> = CountryData.fetchRequest()
                            let predicate = NSPredicate(format: "slug == %@", country.slug)
                            fetchRequest.predicate = predicate
                            
                            if let result = try? dataController.backgroundContext.fetch(fetchRequest) {
                                                
                                dataController.backgroundContext.perform {
                                    var cdToSave: CountryData
                                    if (result.count > 0) {
                                        cdToSave = result[0] as CountryData
                                    } else {
                                        cdToSave = CountryData(context: dataController.backgroundContext)
                                    }
                                    cdToSave.name = country.country
                                    cdToSave.lat = Double(countryData.lat)!
                                    cdToSave.lon = Double(countryData.lon)!
                                    cdToSave.confirmed = countryData.confirmed
                                    cdToSave.deaths = countryData.deaths
                                    cdToSave.recovered = countryData.recovered
                                    cdToSave.active = countryData.active
                                    cdToSave.slug = country.slug
                                    try? dataController.backgroundContext.save()
                                }
                            }
                        }
                    }
                }
            }
            completionHandler(countries, nil)
            return
        }
    }
    
    class func getCountryData(slug: String, completionHandler: @escaping (CountryDataResponse?, Error?) -> Void) {
        let _ = taskGETRequest(url: Endpoints.countryData(slug).url, responseType: [CountryDataResponse].self) { data, error in
            guard let data = data else {
                completionHandler(nil, error)
                return
            }
            
            if data.count > 0 {
                let countryData: CountryDataResponse = CountryDataResponse(
                    lat: data.last!.lat,
                    lon: data.last!.lon,
                    confirmed: data.last!.confirmed,
                    deaths: data.last!.deaths,
                    recovered: data.last!.recovered,
                    active: data.last!.active
                )
                completionHandler(countryData, nil)
            } else {
                completionHandler(nil, nil)
            }
        }
    }
}

extension Covid19Client {
    class func taskGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                
                DispatchQueue.main.async {
                    completionHandler(responseObject, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    let dataStr = String(decoding: data, as: UTF8.self)
                    print(dataStr)
                    completionHandler(nil, error)
                }
            }

        }
        task.resume()
        return task
    }
}
