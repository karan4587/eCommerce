//
//  NetworkManager.swift
//  eCommerce

import Foundation
import Alamofire
typealias completionHandler = (Any?, Any?, AnyObject)-> Void

public enum HTTPMethodsName: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
}

class NetworkManager: NSObject {
    //MARK:- Get Category, SubCategory and Products Response
    static func callCategoriesApi(parameters: [String: Any], completionBlock: @escaping completionHandler){
        let url = ApiName.getAllCategories.rawValue
        callAlamofireRequest(withApiUrl: url, parameters: parameters, httpMethodString: .get) { (status, info, result) in
            completionBlock(status, info, result)
        }
    }
}

//MARK:- API Calling & Parsing extension
extension NetworkManager {
    
    private static func getAndSetHeader() -> [String: String] {
        let header = ["Content-Type": "application/json"]
        return header
    }
    
    private static func callAlamofireRequest(withApiUrl: String, parameters: [String: Any]? = nil, httpMethodString: HTTPMethodsName , apiHeader: [String: String]? = nil, completionBlock: @escaping completionHandler) {
        
//        print("API URL <<<<<<< \(withApiUrl)")
//        print("API URL <<<<<<< \(parameters as Any)")
        var customeHeader = apiHeader
        if apiHeader == nil
        {
            customeHeader = getAndSetHeader()
        }
        switch httpMethodString {
        case .get:
            Alamofire.request(withApiUrl, method: .get, encoding: JSONEncoding.default, headers: customeHeader).responseJSON { (response) in
                //  print(response.result.value as Any)
                parseApiResponse(response: response, completionBlock: { (status, info, result) in
                    completionBlock(status, info, result)
                })
            }
        case .post:
            Alamofire.request(withApiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: customeHeader).responseJSON { (response) in
                //print(response.result.value as Any)
                parseApiResponse(response: response, completionBlock: { (status, info, result) in
                    completionBlock(status, info, result)
                })
            }
        case .put:
            Alamofire.request(withApiUrl, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: customeHeader).responseJSON { (response) in
                //print(response.result.value as Any)
                parseApiResponse(response: response, completionBlock: { (status, info, result) in
                    completionBlock(status, info, result)
                })
            }
        }
    }
    
    private static func parseApiResponse(response: DataResponse<Any>, completionBlock: completionHandler)  {
        
        if response.result.value != nil{
            if response.result.isSuccess {
                completionBlock(ApiResponseCase.success, response.data, response.result.value as AnyObject)
            } else {
                completionBlock(ApiResponseCase.not_found ,nil, response as AnyObject)
            }
        } else {
            completionBlock(ApiResponseCase.not_found, nil, response as AnyObject)
        }
    }
}
extension String{
    func convertToDictionary() -> Any?{
        let data =  self.data(using: .utf8)
        guard let json = try? JSONSerialization.jsonObject(with: data!, options: []) else {
            return nil
        }
        return json
    }
}
