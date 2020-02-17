//
//  PopularViewController.swift
//  eCommerce

import UIKit
import Alamofire
import MBProgressHUD

enum RatingType : Int {
    case MostViewedProducts = 0
    case MostOrderedProducts = 1
    case MostSharedProducts = 2
    case CategoryWiseProducts = 3
    case ChildCategoryWiseProducts = 4
    case ShowProducts = 5
}

class PopularViewController: UIViewController {
    
    @IBOutlet weak var popularTableView : UITableView?
    var categoryListArray : [String : Any] = [:]
    let sideMenuPadding = 56
    var dataLoadType : RatingType? = RatingType(rawValue: RatingType.MostViewedProducts.rawValue)
    var navigationHeaderTitle : String = "Most Viewed Products"
    var filterProductsArray : [[String : Any]] = []
    var productVariantsView : ProductVariantsView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.popularTableView?.register(UINib(nibName: "PopularProductsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PopularProductsTableViewCell")
        
        self.setNavigationBarContent()
        
        // API calling and  Cache  data
        self.getCatgoryDataFromLocalStorage()
        
        self.setSideMenuViewController()
    }
    
    func setNavigationBarContent() {
        self.navigationItem.title = navigationHeaderTitle
        
        let menuButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
        menuButton.setBackgroundImage(UIImage(named: "Hamburger_icon"), for: .normal)
        menuButton.addTarget(self, action: #selector(menuButtonClicked(sender:)), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: menuButton)
        
        self.navigationItem.leftBarButtonItem = item1
    }
    
    @objc func menuButtonClicked(sender : UIButton) {
        self.loadSideMenu()
    }
}

//MARK:-Set Side Menu Content
extension PopularViewController {
    func setSideMenuViewController() {
        if SideMenuManager.default.menuLeftNavigationController == nil
        {
            let storyboard : UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
            if let menuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as?
                MenuViewController
            {
                let navigationController = UISideMenuNavigationController.init(rootViewController: menuViewController)
                menuViewController.delegate = self
                SideMenuManager.default.menuLeftNavigationController = navigationController
                SideMenuManager.default.menuWidth = self.view.frame.size.width - CGFloat(sideMenuPadding)
                SideMenuManager.default.menuFadeStatusBar = false
                SideMenuManager.default.menuShadowOpacity = 0.0
                
            }
        }
    }
    
    //Mark: Load side menu controller
    func loadSideMenu() {
        self.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
}

//MARK:- API Calling AND Cache API respopne
extension PopularViewController {
    func getCatgoryDataFromLocalStorage() {
        if let categoryData = ECommerceCategoryModel.getEcommerceCategoryData(), !categoryData.isEmpty {
            
            if let categoryData = try? JSONSerialization.jsonObject(with: categoryData.last?.categoryData ?? Data(), options: .fragmentsAllowed) as? [String : Any], !categoryData.isEmpty {
                self.categoryListArray = categoryData
                
                self.sortFilterArrayBasedOnCount()
            }
        } else {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            self.getCategoryDataFromAPIAndCache()
        }
        
    }
    
    func getCategoryDataFromAPIAndCache() {
        eCommerceServiceModel.getCategoriesData(busiParams: [ : ]) { (status, info, result) in
            if status == .success {
                if let categoryArray = self.arrayToData(arrayValue: result as! [String:Any]), !categoryArray.isEmpty {
                    self.saveCategoryInLocalStorage(categoryData : categoryArray)
                }
            }
            
            self.hideLoading()
        }
    }

    func saveCategoryInLocalStorage(categoryData : Data) {
        let categoryList = ECommerceCategoryModel.insetUpdateCategoryData(categoryData: categoryData)
        print(categoryList as Any)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.saveContext()
        }
        if let categoryDataList = ECommerceCategoryModel.getEcommerceCategoryData(), !categoryData.isEmpty {
            
            if let categoryProductData = try? JSONSerialization.jsonObject(with: categoryDataList.last?.categoryData ?? Data(), options: .fragmentsAllowed) as? [String : Any], !categoryProductData.isEmpty {
                self.categoryListArray = categoryProductData
                
                self.sortFilterArrayBasedOnCount()
            }
        }
    }
    
    func arrayToData(arrayValue: [String:Any]) -> Data? {
      return try? JSONSerialization.data(withJSONObject: arrayValue, options: [])
    }
    
    func dataToArray(data: Data) -> [Any]? {
      return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String]
    }
    
    //MARK:- Hide MBProgress Loader
    func hideLoading() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func sortFilterArrayBasedOnCount() {
        self.filterProductsArray = []
        self.filterProductsArray = eCommerceServiceModel.getCategoriesAndRatingsArray(productRatingType: self.dataLoadType!, categoryData: self.categoryListArray)
        
        if self.dataLoadType! == RatingType.MostViewedProducts {
            self.filterProductsArray.sort { (s0, s1) -> Bool in
                return (s0["view_count"] as? Int ?? 0) > (s1["view_count"] as? Int ?? 0)
            }
        } else if self.dataLoadType! == RatingType.MostOrderedProducts {
            self.filterProductsArray.sort { (s0, s1) -> Bool in
                return (s0["order_count"] as? Int ?? 0) > (s1["order_count"] as? Int ?? 0)
            }
        } else if self.dataLoadType! == RatingType.MostSharedProducts {
            self.filterProductsArray.sort { (s0, s1) -> Bool in
                return (s0["shares"] as? Int ?? 0) > (s1["shares"] as? Int ?? 0)
            }
        }
        
        self.popularTableView?.reloadData()
    }
}

extension PopularViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionMargin = (ceil(CGFloat(self.filterProductsArray.count) / 2) * 10) + 20
        let dynamicHeight = (ceil(CGFloat(self.filterProductsArray.count) / 2) * 190.0) + sectionMargin
        return dynamicHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let productTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PopularProductsTableViewCell", for: indexPath) as! PopularProductsTableViewCell
        productTableViewCell.productArray = self.filterProductsArray
        productTableViewCell.dataRatingType = self.dataLoadType
        productTableViewCell.delegate = self
        productTableViewCell.productCollectionView?.reloadData()
        return productTableViewCell
    }
}

//MARK:-Filter Products based on Ratings from Category List Products
extension PopularViewController : MenuViewControllerDelegate {
    func didSelectCallForSideMenu(selectedData: [String : Any]) {
        self.navigationItem.title = selectedData["title"] as? String
        let ratingType = Int(selectedData["type"] as? String ?? "0")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        
        if ratingType == RatingType.MostViewedProducts.rawValue {
            let mostPopularProductViewController = storyboard.instantiateViewController(withIdentifier: "PopularViewController") as! PopularViewController
            mostPopularProductViewController.dataLoadType = RatingType(rawValue: RatingType.MostViewedProducts.rawValue)
            mostPopularProductViewController.navigationHeaderTitle = selectedData["title"] as? String ?? ""; self.navigationController?.pushViewController(mostPopularProductViewController, animated: false)
        } else if ratingType == RatingType.MostOrderedProducts.rawValue {
            let mostOrderProductViewController = storyboard.instantiateViewController(withIdentifier: "PopularViewController") as! PopularViewController
            mostOrderProductViewController.dataLoadType = RatingType(rawValue: RatingType.MostOrderedProducts.rawValue)
           mostOrderProductViewController.navigationHeaderTitle = selectedData["title"] as? String ?? ""
            self.navigationController?.pushViewController(mostOrderProductViewController, animated: false)
        } else if ratingType == RatingType.MostSharedProducts.rawValue {
            let mostSharedProductViewController = storyboard.instantiateViewController(withIdentifier: "PopularViewController") as! PopularViewController
            mostSharedProductViewController.dataLoadType = RatingType(rawValue: RatingType.MostSharedProducts.rawValue)
           mostSharedProductViewController.navigationHeaderTitle = selectedData["title"] as? String ?? ""
            self.navigationController?.pushViewController(mostSharedProductViewController, animated: false)
        } else if ratingType == RatingType.CategoryWiseProducts.rawValue {
            let categoryWiseProductViewController = storyboard.instantiateViewController(withIdentifier: "CategoryViewController") as! CategoryViewController
            categoryWiseProductViewController.dataLoadType = RatingType(rawValue: RatingType.CategoryWiseProducts.rawValue)
            categoryWiseProductViewController.navigationHeaderTitle = selectedData["title"] as? String ?? ""
            self.navigationController?.pushViewController(categoryWiseProductViewController, animated: false)
        }
    }
}

//MARK:-PopularTableViewCell Delegate to Open Product Varient View
extension PopularViewController : PopularProductsTableViewCellDelegate {
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
extension PopularViewController : ProductVariantsViewDelegate {
    func closeProductVariantsView() {
        self.productVariantsView?.removeFromSuperview()
        self.productVariantsView = nil
    }
}
