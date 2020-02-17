//
//  ECommerceCategoryModel+CoreDataProperties.swift
//  

import Foundation
import CoreData
import UIKit


extension ECommerceCategoryModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ECommerceCategoryModel> {
        return NSFetchRequest<ECommerceCategoryModel>(entityName: "ECommerceCategoryModel")
    }

    @NSManaged public var categoryData: Data?
    
    class func getEcommerceCategoryData() -> [ECommerceCategoryModel]?
    {
        do {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let categoryData = try?appDelegate.persistentContainer.viewContext.fetch(ECommerceCategoryModel.fetchRequest()) as? [ECommerceCategoryModel]
                return categoryData
            }
            return []
        }
    }
    
    class func insetUpdateCategoryData(categoryData: Data) -> ECommerceCategoryModel? {
        let categoryModelArray = self.getEcommerceCategoryData()
        var categoryModelObject : ECommerceCategoryModel?
        if categoryModelArray?.isEmpty ?? false {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                categoryModelObject = ECommerceCategoryModel(context: appDelegate.persistentContainer.viewContext)
            }
        } else {
            categoryModelObject = categoryModelArray?.last
        }
        categoryModelObject?.categoryData = categoryData
        return categoryModelObject
    }
}
