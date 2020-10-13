//
//  CyclingAnalyticsManager.swift
//  
//
//  Created by Justin Knoetzke on 2020-10-12.
//

import Foundation


class CyclingAnalyticsManager {
    
    var accessToken: String?
    
    func auth(urlString: String) {
        
        let url = URL(string: "https://www.cyclinganalytics.com/api/token")
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "grant_type=password&client_id=4577341&username=justin@shampoo.ca&password=xQFQfUP3LX3@T1kRtiYqsK4LmURzR%26hc&scope=read_rides,create_rides";
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
            }
            
            self.parseJSON(cyclingData: data!)
            
            
        }
        task.resume()
        
    }
    
    func parseJSON(cyclingData: Data) {
        
        let decoder = JSONDecoder()
        
        do {
           let decodedData = try decoder.decode(CyclingAnalyticsData.self, from: cyclingData)
            accessToken = decodedData.access_token
            
        } catch {
            print(error)
        }
    }
}
