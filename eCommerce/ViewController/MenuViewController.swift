//
//  MenuViewController.swift
//  eCommerce

import UIKit

public protocol MenuViewControllerDelegate:class {
    func didSelectCallForSideMenu(selectedData:[String:Any])
}

class MenuViewController: UIViewController {
    
    var dataSourceArray = [[String: Any]]()
    @IBOutlet weak var headerView : UIView?
    @IBOutlet weak var welcomeTitleLabel : UILabel?
    @IBOutlet weak var menuTableView:UITableView?
    
    weak var delegate :MenuViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        
        self.loadMenuContent()
    }
    
    func loadMenuContent() {

        if let path = Bundle.main.path(forResource: "MenuViewContent", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let menuList = jsonResult["MenuList"] as? [[String:Any]] {
                    // do stuff
                    self.dataSourceArray = menuList
                }
            } catch {
                // handle error
            }
        }
    }
}

extension MenuViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(55)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSourceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataInfo = dataSourceArray[indexPath.row]
        
        let bannerCell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell") as! MenuTableViewCell
        bannerCell.selectionStyle = .none
        bannerCell.titleLabel?.text = dataInfo["title"] as? String
        bannerCell.titleLabel?.textColor = UIColor.gray
        bannerCell.leftIcon?.image = UIImage.init(named: dataInfo["icon"] as? String ?? "")
        return bannerCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dataInfo = dataSourceArray[indexPath.row]
        
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                self.delegate?.didSelectCallForSideMenu(selectedData: dataInfo)
            }
        }
    }
}

class MenuTableViewCell : UITableViewCell {
    @IBOutlet weak var leftIcon : UIImageView?
    @IBOutlet weak var titleLabel : UILabel?
}
