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
        var updatedFilterCategoriesProductArray : [String : Any] = [:]
        for i in 0..<categoriesArray.count {
            if let categoryProductsArray = categoriesArray[i]["products"] as? [[String : Any]], !categoriesArray.isEmpty {
                for j in 0..<categoryProductsArray.count {
                    filterCategoriesProductArray.append(categoryProductsArray[j])
                }
            }
        }
        
        for x in 0..<ratingProductsArray.count {
            for y in 0..<filterCategoriesProductArray.count {
                let ratingsProductId = ratingProductsArray[x]["id"] as? Int
                let categoryProductId = filterCategoriesProductArray[y]["id"] as? Int
                if ratingsProductId == categoryProductId {
                    updatedFilterCategoriesProductArray = filterCategoriesProductArray[y]
                    
                    var ratingViewCountValue = 0
                    switch productRatingType {
                    case .MostViewedProducts:
                        ratingViewCountValue = ratingProductsArray[x]["view_count"] as? Int ?? 0
                        updatedFilterCategoriesProductArray["view_count"] = ratingViewCountValue
                        break
                    case .MostOrderedProducts:
                        ratingViewCountValue = ratingProductsArray[x]["order_count"] as? Int ?? 0
                        updatedFilterCategoriesProductArray["order_count"] = ratingViewCountValue
                        break
                    case .MostSharedProducts:
                        ratingViewCountValue = ratingProductsArray[x]["shares"] as? Int ?? 0
                        updatedFilterCategoriesProductArray["shares"] = ratingViewCountValue
                        break
                    default:
                        break
                    }
                    finalFilterProductsArray.append(updatedFilterCategoriesProductArray)
                    break
                }
            }
        }
        return finalFilterProductsArray
    }
    
    class func getChildCategoryProductsArray(childCategoryIdArray : [Int], categoryProductsArray : [[String : Any]]) -> [[String : Any]] {
        var filterChildArray : [[String : Any]] = []
        for i in childCategoryIdArray {
            for j in 0..<categoryProductsArray.count {
                let childId = i
                let categoryId = categoryProductsArray[j]["id"] as? Int
                if childId == categoryId {
                    filterChildArray.append(categoryProductsArray[j])
                    break
                }
            }
        }
        return filterChildArray
    }
}
