//
//  CategoryViewController.swift
//  eCommerce

import UIKit

class CategoryViewController: UIViewController {
    
    @IBOutlet weak var categoryTableView : UITableView?
    var dataLoadType : RatingType? = RatingType(rawValue: RatingType.ShowProducts.rawValue)
    var navigationHeaderTitle : String = "Product Category"
    var categoryListArray : [String : Any] = [:]
    var categoryProductsArray : [[String : Any]] = []
    var productVariantsView : ProductVariantsView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBarContent()
        
        if self.dataLoadType == RatingType.CategoryWiseProducts || self.dataLoadType == RatingType.ChildCategoryWiseProducts {
            self.categoryTableView?.register(UINib(nibName: "CategoryViewTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CategoryViewTableViewCell")
            self.getCatgoryDataFromLocalStorage()
        } else if self.dataLoadType == RatingType.ShowProducts {
            self.categoryTableView?.register(UINib(nibName: "PopularProductsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PopularProductsTableViewCell")
        }
    }
    
    func setNavigationBarContent() {
        self.navigationItem.title = navigationHeaderTitle
        if dataLoadType == RatingType.CategoryWiseProducts {
            let menuButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
            menuButton.setBackgroundImage(UIImage(named: "Hamburger_icon"), for: .normal)
            menuButton.addTarget(self, action: #selector(menuButtonClicked(sender:)), for: .touchUpInside)
            let item1 = UIBarButtonItem(customView: menuButton)
            
            self.navigationItem.leftBarButtonItem = item1
        }
    }
    
    @objc func menuButtonClicked(sender : UIButton) {
        self.loadSideMenu()
    }
    
    //Mark: Load side menu controller
    func loadSideMenu() {
        self.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    func getCatgoryDataFromLocalStorage() {
        if let categoryData = ECommerceCategoryModel.getEcommerceCategoryData(), !categoryData.isEmpty {
            
            if let categoryData = try? JSONSerialization.jsonObject(with: categoryData.last?.categoryData ?? Data(), options: .fragmentsAllowed) as? [String : Any], !categoryData.isEmpty {
                self.categoryListArray = categoryData
                
                self.loadProductsOrSubCategoryData()
            }
        }
    }
    
    func loadProductsOrSubCategoryData() {
        if self.dataLoadType == RatingType.CategoryWiseProducts {
            self.categoryProductsArray = eCommerceServiceModel.getCategoryProductsArray(categoryData: self.categoryListArray)
            self.categoryTableView?.reloadData()
        } else if self.dataLoadType == RatingType.ChildCategoryWiseProducts {
            
        } else if self.dataLoadType == RatingType.ShowProducts {
            
        }
    }
}

//MARK:-UITableView Delegate and DataSource Method
extension CategoryViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var dynamicHeight = 0
        if self.dataLoadType == RatingType.CategoryWiseProducts || self.dataLoadType == RatingType.ChildCategoryWiseProducts {
            let sectionMargin = (ceil(CGFloat(self.categoryProductsArray.count) / 2) * 10) + 20
            dynamicHeight = Int((ceil(CGFloat(self.categoryProductsArray.count) / 2) * 150.0) + sectionMargin)
        } else if self.dataLoadType == RatingType.ShowProducts {
            let sectionMargin = (ceil(CGFloat(self.categoryProductsArray.count) / 2) * 10) + 20
            dynamicHeight = Int((ceil(CGFloat(self.categoryProductsArray.count) / 2) * 190.0) + sectionMargin)
        }
                  
        return CGFloat(dynamicHeight)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.dataLoadType == RatingType.CategoryWiseProducts || self.dataLoadType == RatingType.ChildCategoryWiseProducts {
            let categoryTableCell = tableView.dequeueReusableCell(withIdentifier: "CategoryViewTableViewCell", for: indexPath) as! CategoryViewTableViewCell
            categoryTableCell.categoryArray = self.categoryProductsArray
            categoryTableCell.dataRatingType = self.dataLoadType
            categoryTableCell.delegate = self
            categoryTableCell.categoryCollectionView?.reloadData()
            return categoryTableCell
        } else if self.dataLoadType == RatingType.ShowProducts {
            let productTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PopularProductsTableViewCell", for: indexPath) as! PopularProductsTableViewCell
            productTableViewCell.productArray = self.categoryProductsArray
            productTableViewCell.dataRatingType = self.dataLoadType
            productTableViewCell.delegate = self
            productTableViewCell.productCollectionView?.reloadData()
            return productTableViewCell
        }
        return UITableViewCell()
    }
}

extension CategoryViewController : CategoryViewTableViewCellDelegate {
    func collectionDidSelectItem(selectedCategory: [String : Any], dataRatingType: RatingType) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        if dataRatingType == RatingType.CategoryWiseProducts {
            if let childCategoryArray = selectedCategory["products"] as? [[String : Any]], !childCategoryArray.isEmpty {
                let categoryWiseProductViewController = storyboard.instantiateViewController(withIdentifier: "CategoryViewController") as! CategoryViewController
                categoryWiseProductViewController.dataLoadType = RatingType(rawValue: RatingType.ShowProducts.rawValue)
                categoryWiseProductViewController.navigationHeaderTitle = ""
                categoryWiseProductViewController.categoryProductsArray = selectedCategory["products"] as? [[String : Any]] ?? []
                self.navigationController?.pushViewController(categoryWiseProductViewController, animated: true)
            }
            
            if let childCategoryArray = selectedCategory["child_categories"] as? [Int], !childCategoryArray.isEmpty {
                let filterChildCategoryArray = eCommerceServiceModel.getChildCategoryProductsArray(childCategoryIdArray: childCategoryArray, categoryProductsArray: self.categoryProductsArray)
                if !filterChildCategoryArray.isEmpty {
                    let categoryWiseProductViewController = storyboard.instantiateViewController(withIdentifier: "CategoryViewController") as! CategoryViewController
                    categoryWiseProductViewController.dataLoadType = RatingType(rawValue: RatingType.ChildCategoryWiseProducts.rawValue)
                    categoryWiseProductViewController.navigationHeaderTitle = ""
                    categoryWiseProductViewController.categoryProductsArray = filterChildCategoryArray
                    self.navigationController?.pushViewController(categoryWiseProductViewController, animated: true)
                }
            }
        } else if dataRatingType == RatingType.ChildCategoryWiseProducts {
            if let childCategoryArray = selectedCategory["products"] as? [[String : Any]], !childCategoryArray.isEmpty {
                let categoryWiseProductViewController = storyboard.instantiateViewController(withIdentifier: "CategoryViewController") as! CategoryViewController
                categoryWiseProductViewController.dataLoadType = RatingType(rawValue: RatingType.ShowProducts.rawValue)
                categoryWiseProductViewController.navigationHeaderTitle = ""
                categoryWiseProductViewController.categoryProductsArray = selectedCategory["products"] as? [[String : Any]] ?? []
                self.navigationController?.pushViewController(categoryWiseProductViewController, animated: true)
            }
            
            if let childCategoryArray = selectedCategory["child_categories"] as? [Int], !childCategoryArray.isEmpty {
                let categoryArray = eCommerceServiceModel.getCategoryProductsArray(categoryData: self.categoryListArray)
                let filterChildCategoryArray = eCommerceServiceModel.getChildCategoryProductsArray(childCategoryIdArray: childCategoryArray, categoryProductsArray: categoryArray)
                
                if !filterChildCategoryArray.isEmpty {
                    let categoryWiseProductViewController = storyboard.instantiateViewController(withIdentifier: "CategoryViewController") as! CategoryViewController
                    categoryWiseProductViewController.dataLoadType = RatingType(rawValue: RatingType.ChildCategoryWiseProducts.rawValue)
                    categoryWiseProductViewController.navigationHeaderTitle = ""
                    categoryWiseProductViewController.categoryProductsArray = filterChildCategoryArray
                    self.navigationController?.pushViewController(categoryWiseProductViewController, animated: true)
                }
            }
        } else if dataRatingType == RatingType.ShowProducts {
            
        }
    }
}

//MARK:-PopularTableViewCell Delegate to Open Product Varient View
extension CategoryViewController : PopularProductsTableViewCellDelegate {
    func showMoreOptionsPopUpView(selectedDictionary: [String : Any]) {
        if (self.productVariantsView != nil) {
            self.productVariantsView?.removeFromSuperview()
            self.productVariantsView = nil
        }
        
        self.productVariantsView = Bundle.main.loadNibNamed("ProductVariantsView", owner: self, options: nil)![0] as? ProductVariantsView
        
        self.productVariantsView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.productVariantsView?.delegate = self
        self.productVariantsView?.loadProductVariants(productDictionary: selectedDictionary)
        
        self.view.addSubview(self.productVariantsView!)
        self.view.bringSubviewToFront(self.productVariantsView!)
    }
}

//MARK:-Product Variants Popup View Delegate
extension CategoryViewController : ProductVariantsViewDelegate {
    func closeProductVariantsView() {
        self.productVariantsView?.removeFromSuperview()
        self.productVariantsView = nil
    }
}
