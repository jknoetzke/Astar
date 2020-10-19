//
//  CyclingAnalyticsManager.swift
//  
//
//  Created by Justin Knoetzke on 2020-10-12.
//

import Foundation



class CyclingAnalyticsManager {
    
    //let domainUrlString = "https://www.cyclinganalytics.com/api/token?"
    let url = URL(string: "https://www.cyclinganalytics.com/api/token")
    
    
    func uploadRide(xml: String, accessToken: String) {
        
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
        
        var request = URLRequest(url: URL(string: "https://www.cyclinganalytics.com/api/me/upload?format=tcx&title=Test%20Ride")!,timeoutInterval: Double.infinity)
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
        //parseJSON(cyclingData: data!)
        task.resume()
    }
    
    
    func auth(completionHandler: @escaping (CyclingAnalyticsData) -> Void) {
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "grant_type=password&client_id=4577341&username=justin@shampoo.ca&password=xQFQfUP3LX3@T1kRtiYqsK4LmURzR%26hc&scope=read_rides,create_rides";
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
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
               let film = try? JSONDecoder().decode(CyclingAnalyticsData.self, from: data) {
                completionHandler(film)
            }
        }
        task.resume()
    }
}


