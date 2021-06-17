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
    var stravaCode = "337f15bafa8de590ea96d9e39771cf3d1f4a8359"
    var accessCode = ""
    let clientSecret = "69e26bcc0183fb52e446f62cf61c3e4773b6c11d"
    let clientID = "54604"
    
    var accessToken = ""
    var expiresAt = 0
    var expiresIn = 0
    var refreshToken = ""
    
    let appOAuthUrlStravaScheme = URL(string: "strava://oauth/mobile/authorize?client_id=54604&redirect_uri=astar://shampoo.ca&response_type=code&approval_prompt=force&scope=activity%3Awrite%2Cread&state=test")!
    
    init() {
        
        let defaults = UserDefaults.standard
        accessToken = defaults.string(forKey: "accessToken") ?? ""
        expiresAt = defaults.integer(forKey: "expiresAt")
        expiresIn = defaults.integer(forKey: "expiresIn")
        refreshToken = defaults.string(forKey: "refreshToken") ?? ""
        
    }
    
    func refresh(completionHandler: @escaping (StravaData) -> Void) {
        
        var request = URLRequest(url: URL(string: "https://www.strava.com/oauth/token?client_id=\(clientID)&client_secret=\(clientSecret)&refresh_token=\(refreshToken)&grant_type=refresh_token")!,timeoutInterval: Double.infinity)
        request.addValue("_strava4_session=r1lko2eduj089hbhjllafegg00fut9u1", forHTTPHeaderField: "Cookie")
        
        request.httpMethod = "POST"
        
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
               let strava = try? JSONDecoder().decode(StravaData.self, from: data) {
                completionHandler(strava)
            }
        }
        task.resume()
    }
    
    func storeTokens(tokenData: StravaData) {
        
        print("Setting Access Tokens..")
        accessToken = tokenData.access_token
        refreshToken = tokenData.refresh_token
        let defaults = UserDefaults.standard
        defaults.set(accessToken, forKey: "accessToken")
        defaults.set(refreshToken, forKey: "refreshToken")
    }
    
    //Get valid tokens
    func authenticate() {
        if UIApplication.shared.canOpenURL(appOAuthUrlStravaScheme) {
            UIApplication.shared.open(appOAuthUrlStravaScheme, options: [:])
            
            //   } else {
            //      authSession = ASWebAuthenticationSession(url: appOAuthUrlStravaScheme!, callbackURLScheme: "Astar://") { url, error in
            
            //    }
            authSession?.start()
        }
    }
    
    func token(completionHandler: @escaping (StravaData) -> Void) {
        
        let defaults = UserDefaults.standard
        if let strava_code = defaults.string(forKey: "strava_code") {
            stravaCode = strava_code
        } else {
            return
        }
        
        var request = URLRequest(url: URL(string: "https://www.strava.com/oauth/token?client_id=\(clientID)&client_secret=\(clientSecret)&code=\(stravaCode)&grant_type=authorization_code")!,timeoutInterval: Double.infinity)
        request.addValue("Bearer \(accessCode)", forHTTPHeaderField: "Authorization")
        request.addValue("_strava4_session=rjfdlc1qrbkpmnhl3uces8nqf2ndh7to", forHTTPHeaderField: "Cookie")
        
        request.httpMethod = "POST"
        
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
               let strava = try? JSONDecoder().decode(StravaData.self, from: data) {
                completionHandler(strava)
            }
        }
        task.resume()
    }
    
    func setStravaCode(_stravaCode: String) {
        stravaCode = _stravaCode
        print("Strava code: \(stravaCode)")
        let defaults = UserDefaults.standard
        defaults.set(stravaCode, forKey: "strava_code")
        
        //Let's get a refresh token
        token() { (StravaData) in
            print("Storing Strava Refresh Token: \(StravaData.refresh_token)")
            self.storeTokens(tokenData: StravaData)
        }
    }
    
    func uploadRide(xml: String, title:String) {
        print("Uploading Ride with accessToken: \(accessToken)")
        let semaphore = DispatchSemaphore (value: 0)
        
        let parameters = [
            [
                "key": "file",
                "src": "data",
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
        
        
        
        let queryItems = [URLQueryItem(name: "data_type", value: "tcx"), URLQueryItem(name: "name", value: title)]
        var urlComps = URLComponents(string: "https://www.strava.com/api/v3/uploads")!
        urlComps.queryItems = queryItems
        let url = urlComps.url!
        
        var request = URLRequest(url: url,timeoutInterval: Double.infinity)
        
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
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
