//
//  WebServices.swift
//  TapResearchTest
//
//  Created by Ken Nyame on 6/30/21.
//

import Foundation
import UIKit

enum MyDevice {
    static let uuid = UIDevice.current.identifierForVendor?.uuidString
    static let testUUID = "00008030-001215C40E29802E"
}

enum TapResearchAPI {
    static let apiBaseURL = "https://www.tapresearch.com/supply_api"
    static let apiToken = "f47e5ce81688efee79df771e9f9e9994"
    static let userIdentifier = "codetest123"
    enum EndPoints {
        static let surveysOffer = "/surveys/offer"
    }
}

public class WebServices: NSObject {
    private func sendGetRequest(_ url: URL, parameters: [String: String], completion: @escaping (Data?, Error?) -> Void) {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data,                            // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                error == nil else {                           // was there no error, otherwise ...
                    completion(nil, error)
                    return
            }
            
            completion(data, nil)
        }
        task.resume()
    }
    
    private func sendGetRequest(_ url: URL, completion: @escaping (Data?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                  error == nil else {
                completion(nil, error)
                return
            }
            completion(data, nil)
        }
        task.resume()
    }
    
    func sendPostRequest(_ url: String, parameters: [String: String], completion: @escaping (Data?, Error?) -> Void) {
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST" //set http method as POST
        
        let postString = parameters.map { "\($0)=\($1)" }
                                           .joined(separator: "&")
        
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Accept")
        request.httpBody = postString.data(using: .utf8)
        
        //request.addValue(self.appAccessToken, forHTTPHeaderField: "access-token")
        //request.addValue(self.appClientKey, forHTTPHeaderField: "client")
        //request.addValue(self.appUid, forHTTPHeaderField: "uid")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                            // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                error == nil else {                           // was there no error, otherwise ...
                    completion(nil, error)
                    return
            }
            completion(data, nil)
        }
        task.resume()
    }
    
    func getSurveysOffer(completion: @escaping (SurveyOffer?, Error?) -> Void) {
        
        sendPostRequest(TapResearchAPI.apiBaseURL + TapResearchAPI.EndPoints.surveysOffer,
                        parameters: [
                            "device_identifier" : MyDevice.testUUID,
                            "api_token": TapResearchAPI.apiToken,
                            "user_identifier": TapResearchAPI.userIdentifier
                        ]) {(data, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
            }
            else{

                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if let offer = try? jsonDecoder.decode(SurveyOffer.self, from: data!) {
                    print(offer)
                    completion(offer, nil)
                }
                else {
                    completion(nil, nil)
                }
            }
        }
    }

}
