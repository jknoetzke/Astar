//
//  CyclingAnalyticsManager.swift
//  
//
//  Created by Justin Knoetzke on 2020-10-12.
//

import Foundation



class CyclingAnalyticsManager {
    
    let url = URL(string: "https://www.cyclinganalytics.com/api/token")
    
    func uploadRide(xml:String, accessToken: String) {

        let parameters = [
            [
                "key": "data",
                "type": "file",
                "format": "tcx",
                "title" : Date().description
            ]] as [[String : Any]]
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        for param in parameters {
            if param["disabled"] == nil {
                let paramName = param["key"]!
                body += "--\(boundary)\r\n"
                body += "Content-Disposition:form-data; name=\"\(paramName)\""
                let paramType = param["type"] as! String
                if paramType == "text" {
                    let paramValue = param["value"] as! String
                    body += "\r\n\r\n\(paramValue)\r\n"
                } else {
                    
                    var data = Data()
                    data.append(xml.data(using: .utf8)!)
                    let fileContent = String(data: data, encoding: .utf8)!
                    body += "; filename=\"Astar.tcx\r\n" + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
                }
            }
        }
        body += "--\(boundary)--\r\n";
        let postData = body.data(using: .utf8)
        
        var request = URLRequest(url: URL(string: "https://www.cyclinganalytics.com/api/me/upload?format=tcx")!,timeoutInterval: Double.infinity)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        request.httpBody = postData
        
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
        }
        task.resume()
    }
    
    
    func auth(completionHandler: @escaping (CyclingAnalyticsData) -> Void) {
        
        
        let defaults = UserDefaults.standard
               
        let userName = defaults.string(forKey: "cycling_analytics_username")
        let password = defaults.string(forKey: "cycling_analytics_password")
        
        if userName == nil || password == nil {
            return
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.cyclinganalytics.com"
        components.path = "/api/token"
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "password"),
            URLQueryItem(name: "client_id", value: "4577341"),
            URLQueryItem(name: "username", value: userName),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "scope", value: "create_rides,read_rides")
        ]

        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"

        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error returning: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Unexpected response status code: \(String(describing: response))")
                return
            }
            
            if let data = data,
               let cyclingAnalytics = try? JSONDecoder().decode(CyclingAnalyticsData.self, from: data) {
                completionHandler(cyclingAnalytics)
                print("Uploaded to Cycling Analytics: \(cyclingAnalytics)")
            }
        }
        task.resume()
    }
}


