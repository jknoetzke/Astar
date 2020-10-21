//
//  StravaManager.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-10-20.
//

import Foundation
import AuthenticationServices

class StravaManager {

    
    
    
    
    private var authSession: ASWebAuthenticationSession?
    static let sharedInstance = StravaManager()
    var stravaCode = "a79afd907fe3b150302c490a9b02c75dbf908aea"
    var accessCode = "27d32f3505daedc65857b792b46081220c2ac784"
    
    let appOAuthUrlStravaScheme = URL(string: "strava://oauth/mobile/authorize?client_id=54604&redirect_uri=astar://shampoo.ca&response_type=code&approval_prompt=force&scope=activity%3Awrite%2Cread&state=test")!
    // let webOAuthUrl = URL(string: "https://www.strava.com/oauth/mobile/authorize?client_id=54604&redirect_uri= YourApp%3A%2F%2Fwww.yourapp.com%2Fen-US&response_type=code&approval_prompt=auto&scope=activity%3Awrite%2Cread&state=test")
    
    func authenticate() {
        if UIApplication.shared.canOpenURL(appOAuthUrlStravaScheme) {
            UIApplication.shared.open(appOAuthUrlStravaScheme, options: [:])
            
     //   } else {
      //      authSession = ASWebAuthenticationSession(url: appOAuthUrlStravaScheme!, callbackURLScheme: "Astar://") { url, error in
                
        //    }
            authSession?.start()
        }
    }
    
    
    func setStravaCode(_stravaCode: String) {
        stravaCode = _stravaCode
    }

    /*
    func uploadRide(xml: String) {
        let parameters = [
            [
                "key": "file",
                "type": "file"
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
        
        var request = URLRequest(url: URL(string: "https://www.strava.com/api/v3/uploads?name=Test%20Ride&data_type=tcx")!,timeoutInterval: Double.infinity)
        request.addValue("Bearer \(accessCode)", forHTTPHeaderField: "Authorization")
        request.addValue("_strava4_session=rjfdlc1qrbkpmnhl3uces8nqf2ndh7to", forHTTPHeaderField: "Cookie")
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
    */
    func uploadRide(xml: String) {
        let semaphore = DispatchSemaphore (value: 0)

        let parameters = [
          [
            "key": "file",
            "src": "/Users/justin/Downloads/testride.tcx",
            "type": "file"
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
              let paramSrc = param["src"] as! String
              
                var data = Data()
                data.append(xml.data(using: .utf8)!)
              let fileContent = String(data: data, encoding: .utf8)!
              body += "; filename=\"\(paramSrc)\"\r\n"
                + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
            }
          }
        }
        body += "--\(boundary)--\r\n";
        let postData = body.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://www.strava.com/api/v3/uploads?&data_type=tcx")!,timeoutInterval: Double.infinity)
        request.addValue("Bearer \(accessCode)", forHTTPHeaderField: "Authorization")
        request.addValue("_strava4_session=rjfdlc1qrbkpmnhl3uces8nqf2ndh7to", forHTTPHeaderField: "Cookie")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
          print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
    }
    
}
