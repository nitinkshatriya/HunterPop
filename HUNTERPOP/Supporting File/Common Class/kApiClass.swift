//
//  kApiClass.swift
//  DriverCity
//
//  Created by Kavin Soni on 28/05/17.
//  Copyright © 2017 Kavin Soni. All rights reserved.
//

import UIKit
import Alamofire
//import SwiftLoader


typealias ApiCallSuccessBlock = (Bool,NSDictionary) -> Void
typealias ApiCallFailureBlock = (Bool,NSError?,NSDictionary?) -> Void
typealias APIResponseBlock = ((_ response: NSDictionary?,_ isSuccess: Bool,_ error: Error?)->())

class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}


enum kAPIType {
    case register
    case login
    case validateOtp
    case forgetpassword
    case getProfile
     case resetPassword
    case changePassword
    case updateProfile
     case carlist
    case storelocation
    case addCar
    case deleteCar
    
    
    
    
    
    func getEndPoint() -> String {
        switch self {
        // "\(Constant.AppInfo.baseURL)/\(Constant.Endpoint.Subcategory_LIST)/\("4bf58dd8d48988d11e941735")
       
        case .register:
            return "doSignUp"
        case .login:
            return "doLogin"
        case .validateOtp:
            return "validateSignup"
        case .forgetpassword:
            return "forgotPassword"
        case .getProfile:
            return "getProfile"
        case .resetPassword:
            return "resetPassword"
        case .changePassword:
            return "changePassword"
        case .updateProfile:
            return "updateProfileImage"
        case .carlist:
            return "carLists"
        case .storelocation:
            return "getServiceStore"
        case .addCar:
            return "addUpdateCar"
        case .deleteCar:
            return "deleteCars"
            
       
      
    }
    }
    
        
    }
    
  





class kApiClass: NSObject {
    
    //MARK:- Singleton
    static let shared = kApiClass()
    
   let baseURL = "http://chargd.theappguys.xyz/api/"
   
 //let baseURL = "http://lightofweb.com/API/Promove/process.php?action="
    
    
    static var previousAPICallRequestParams:(kAPIType,[String:Any]?)?
    
    static var previousAPICallRequestMultiParams:(kAPIType,[[String:Any]]?)?
    
    
    func callAPI(WithType apiType:kAPIType, WithParams params:[String:Any], Success successBlock:@escaping APIResponseBlock, Failure failureBlock:@escaping APIResponseBlock) -> Void
    {
        
        if Connectivity.isConnectedToInternet() {
            print("Yes! internet is available.")
            // do some tasks..
            /* API URL */
            
            print("------  Parameters --------")
            print(params)
            print("------  Parameters --------")
            
            
            let token:String = UserDefaults.standard.object(forKey: "token") as! String
            
            let apiUrl:String = "\(self.baseURL)\(apiType.getEndPoint())"
             print(apiUrl)
            let headers: HTTPHeaders = [
                "device_type": "iphone",
                "ContentType": "application/json",
                "device_token": "123456",
                "app_version": "0.0.1",
                "User-Auth-Token": token,
               
            ]
           
         print(headers)
               
            
           
            Alamofire.request(apiUrl, method: .post, parameters:params, encoding: URLEncoding.default, headers:headers).responseJSON
                { (response) in
                    
                    switch response.result{
                        
                    case .success(let json):
                        //SwiftLoader.hide()
                         customLoader.hide()
                        // You got Success :)
                        print(json)
                        //  print("Response Status Code :: \(response.response?.statusCode)")
                        //                        print(json as! NSDictionary)
                        let mainStatusCode:Int = (response.response?.statusCode)!
                        
                        if let jsonResponse = json as? NSDictionary
                        {
                            
                            print(mainStatusCode)
                            print(jsonResponse)
                            
                            //var myBool = true

                            
//                            let boolAsString = jsonResponse.value(forKey: "error") as! Bool
//                             print(boolAsString)
                            
                            if (mainStatusCode == 200){
                                
                                if ((jsonResponse.value(forKey: "response") as? NSDictionary) != nil){
                                    
                                    let resultDict = jsonResponse.value(forKey: "response") as? NSDictionary
                                    successBlock(resultDict, true, nil)
                                }else{
                                    if jsonResponse.allKeys.count > 0 {
                                        successBlock(jsonResponse, true, nil)
                                    }
                                    
                                }
                            }
                           else if (mainStatusCode == 201){
                                
                                if ((jsonResponse.value(forKey: "response") as? NSDictionary) != nil){
                                    
                                    let resultDict = jsonResponse.value(forKey: "response") as? NSDictionary
                                    successBlock(resultDict, true, nil)
                                }else{
                                    if jsonResponse.allKeys.count > 0 {
                                        successBlock(jsonResponse, true, nil)
                                    }
                                    
                                }
                            }
                            else{
                                customLoader.hide()
                                let boolAsString = jsonResponse.value(forKey: "error") as! Bool
                                print(boolAsString)
                                if (boolAsString){
                                    //let errorMessage = jsonResponse.value(forKey: "response") as? String
                                    
                                    let errorMessage = jsonResponse.value(forKey: "code") as! Int
                                    
                                    let dict = ["error":errorMessage]
                                    
                                    //let dict = ["error":errorMessage]
                                    successBlock(dict as NSDictionary?, false,nil)
                                }else{
                                    
                                    successBlock(nil, false, nil)
                                }
                                
                            }
                            
                        }else{
                             customLoader.hide()
                            print("Json Object is not NSDictionary : Please Check this API \(apiType.getEndPoint())")
                            successBlock(nil, true, nil)
                        }
                        
                        break
                    case .failure(let error):
                        // You Got Failure :(
                        //SwiftLoader.hide()
                        customLoader.hide()
                        print("Response Status Code :: \(String(describing: response.response?.statusCode))")
                        let datastring = NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue)
                        print(datastring ?? "Test")
                        failureBlock(nil,false,error)
                        break
                    }
            }
        }else{
            let alertController = UIAlertController(title: "Drinker", message: "Please check your internet connection", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
           
            let keyWindow: UIWindow? = UIApplication.shared.keyWindow

           // let appWindow: UIWindow = UIWindow(frame: UIScreen.main.bounds)
           // keyWindow.makeKeyAndVisible()
            keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)

//            (alertController, animated: true, completion: nil)
        }
    }
    
    func callMultiPartAPI(WithType apiType:kAPIType, WithParams params:[String:Any], Success successBlock:@escaping APIResponseBlock, Failure failureBlock:@escaping APIResponseBlock) -> Void
    {
        if Connectivity.isConnectedToInternet() {
            
            let apiUrl:String = "\(self.baseURL)\(apiType.getEndPoint())"
            print(apiUrl)
            //SwiftLoader.show(animated: true)
            //SwiftLoader.show(title: "Loading...", animated: true)
             print(params)
            let token:String = UserDefaults.standard.object(forKey: "token") as! String
            let headers: HTTPHeaders = [
                "device_type": "iphone",
                "ContentType": "application/json",
                "device_token": "123456",
                "app_version": "0.0.1",
                "User-Auth-Token": token,
                
                ]
            
            print(headers)
            
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
               
                for (key, value) in params {
                    
                    print(key)
                    print(value)
                    
                    
                    if key == "image"
                   {
                    //multipartFormData.append(value as! Data, withName: key)
                    
                    multipartFormData.append(value as! Data, withName: "image", fileName: "profile.jpeg", mimeType: "image/jpeg")
                    
                   }
                    
                    else
                    {
                        multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    }
                    
                    
                }
            }, to:apiUrl,headers:headers)
            { (result) in
                switch result {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (Progress) in
                print("Upload Progress: \(Progress.fractionCompleted)")
                    })
                    
                   
                    
                    upload.responseJSON { response in
                         customLoader.hide()
                        //self.delegate?.showSuccessAlert()
                        print(response.request!)  // original URL request
                        print(response.response!) // URL response
                        print(response.data!)     // server data
                        print(response.result)   // result of response serialization
                        //                        self.showSuccesAlert()
                        //self.removeImage("frame", fileExtension: "txt")
                        
                         //SwiftLoader.hide()
                        
                        if let JSON = response.result.value {
                            print("JSON: \(JSON)")
                            
                            if let jsonResponse = JSON as? NSDictionary
                            {
                                
                                print(jsonResponse)
                                
                                
                                
//                                let code = jsonResponse.value(forKey: "status") as! Int
//
//                                // let mainStatusCode:Int = (response.response?.statusCode)!
//                                print(code)
//
//                                let stringCode = String(describing: code)
//
//                                if stringCode  == "1"{
                                
                                    if ((jsonResponse.value(forKey: "response") as? NSDictionary) != nil){
                                        
                                        let resultDict = jsonResponse.value(forKey: "response") as? NSDictionary
                                        successBlock(resultDict, true, nil)
                                    }else{
                                        if jsonResponse.allKeys.count > 0 {
                                            successBlock(jsonResponse, true, nil)
                                        }
                                        
                                    }
//                                }else {
//                                    //if stringCode  == "1013"{
//                                        let errorMessage = jsonResponse.value(forKey: "status") as! Int
//                                        
//                                        print(errorMessage as AnyObject);
//                                        
//                                        let dict = ["error":errorMessage]
//                                        print(dict);
//                                        successBlock(dict as NSDictionary?, false,nil)
////                                    }else{
////
////                                        successBlock(nil, false, nil)
//                                    //}
//                                    
//                                }
                                
                                
                            }else{
                                print("Json Object is not NSDictionary : Please Check this API \(apiType.getEndPoint())")
                                successBlock(nil, true, nil)
                            }
                            
                        }
                        
                        
                      /*
                         */
                        
                    }
                    
                case .failure(let encodingError):
                    //self.delegate?.showFailAlert()
                    //SwiftLoader.hide()
                    
                    failureBlock(nil,false,encodingError)
                }
                
            }
            
        }
        else{
            let alertController = UIAlertController(title: "DiverCity", message: "Please check your internet connection", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            let keyWindow: UIWindow? = UIApplication.shared.keyWindow
            
            // let appWindow: UIWindow = UIWindow(frame: UIScreen.main.bounds)
            // keyWindow.makeKeyAndVisible()
            keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
            
            //            (alertController, animated: true, completion: nil)
        }
    }
    
}


