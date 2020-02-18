//
//  eCommerceServiceModel.swift
//  eCommerce

import Foundation
import Alamofire

class eCommerceServiceModel: NSObject {
    typealias completion = (ApiResponseCase, AnyObject?, AnyObject?)->Void
    
    // MARK: - Get Contact List
    class func getCategoriesData(busiParams: [String: AnyObject],completionBlock: @escaping completion) {
        NetworkManager.callCategoriesApi(parameters: [:]) { (status, info, result) in
            completionBlock(status as! ApiResponseCase, info as AnyObject, result as AnyObject)
        }
    }
}

//MARK:-Category AND Product Filter Logic
extension eCommerceServiceModel {
    class func getCategoriesAndRatingsArray(productRatingType : RatingType, categoryData : [String : Any]) -> [[String : Any]] {
        let productsArray = self.filterProductsDataBasedOnType(productRatingType: productRatingType, categoryData: categoryData)
        let categoriesArray = self.getCategoryProductsArray(categoryData: categoryData)
        return self.getFilterProductsArray(ratingProductsArray: productsArray, categoriesArray: categoriesArray, productRatingType: productRatingType)
    }
    
    class func filterProductsDataBasedOnType(productRatingType : RatingType, categoryData : [String : Any]) -> [[String : Any]] {
        let productsArray = self.getRatingArray(productRatingType : productRatingType, categoryData: categoryData)
        if !productsArray.isEmpty {
            return productsArray
        }
        return []
    }
    
    class func getRatingArray(productRatingType : RatingType, categoryData : [String : Any]) -> [[String : Any]] {
        if !categoryData.isEmpty {
            if let ratingsArray = categoryData["rankings"] as? [[String : Any]], !ratingsArray.isEmpty {
                switch productRatingType {
                case .MostViewedProducts:
                    if let productsArray = ratingsArray[0]["products"] as? [[String : Any]], !productsArray.isEmpty {
                        return productsArray
                    }
                    break
                case .MostOrderedProducts:
                    if let productsArray = ratingsArray[1]["products"] as? [[String : Any]], !productsArray.isEmpty {
                        return productsArray
                    }
                    break
                case .MostSharedProducts:
                    if let productsArray = ratingsArray[2]["products"] as? [[String : Any]], !productsArray.isEmpty {
                        return productsArray
                    }
                    break
                case .CategoryWiseProducts:
                    break
                case .ChildCategoryWiseProducts:
                    break
                case .ShowProducts:
                    break
                }
            }
        }
        return []
    }
    
    class func getCategoryProductsArray(categoryData : [String : Any]) -> [[String : Any]] {
        if !categoryData.isEmpty {
            if let categoriesArray = categoryData["categories"] as? [[String : Any]], !categoriesArray.isEmpty {
                return categoriesArray
            }
        }
        return []
    }
    
    class func getFilterProductsArray(ratingProductsArray : [[String : Any]], categoriesArray : [[String : Any]], productRatingType : RatingType) -> [[String : Any]] {
        var filterCategoriesProductArray : [[String : Any]] = []
        var finalFilterProductsArray : [[String : Any]] = []
        var updatedFilterCategoriesProductArray : [[String : Any]] = []
        
        for i in 0..<categoriesArray.count {
            if let categoryProductsArray = categoriesArray[i]["products"] as? [[String : Any]], !categoryProductsArray.isEmpty {
                filterCategoriesProductArray.append(contentsOf: categoryProductsArray)
            }
        }
        
        for x in 0..<ratingProductsArray.count {
            updatedFilterCategoriesProductArray = filterCategoriesProductArray.filter{$0["id"] as? Int == ratingProductsArray[x]["id"] as? Int}
            if !updatedFilterCategoriesProductArray.isEmpty {
                var ratingViewCountValue = 0
                switch productRatingType {
                case .MostViewedProducts:
                    ratingViewCountValue = ratingProductsArray[x]["view_count"] as? Int ?? 0
                    updatedFilterCategoriesProductArray[0]["view_count"] = ratingViewCountValue
                    break
                case .MostOrderedProducts:
                    ratingViewCountValue = ratingProductsArray[x]["order_count"] as? Int ?? 0
                    updatedFilterCategoriesProductArray[0]["order_count"] = ratingViewCountValue
                    break
                case .MostSharedProducts:
                    ratingViewCountValue = ratingProductsArray[x]["shares"] as? Int ?? 0
                    updatedFilterCategoriesProductArray[0]["shares"] = ratingViewCountValue
                    break
                default:
                    break
                }
                finalFilterProductsArray += updatedFilterCategoriesProductArray
            }
        }
        return finalFilterProductsArray
    }
    
    class func getChildCategoryProductsArray(childCategoryIdArray : [Int], categoryProductsArray : [[String : Any]]) -> [[String : Any]] {
        var filterChildArray : [[String : Any]] = []
        for i in childCategoryIdArray {
            let child = categoryProductsArray.filter{$0["id"] as? Int == i}
            if !child.isEmpty {
                filterChildArray.append(child.last!)
            }
        }
        return filterChildArray
    }
}


//MARK:-Connectivity Class for Internet check
class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
