//
//  CategoryViewCollectionViewCell.swift
//  eCommerce

import UIKit

class CategoryViewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryBackgroundView : UIView?
    @IBOutlet weak var categoryTitleLabel : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setLayoutOfView()
    }
    
    func setLayoutOfView() {
        self.categoryBackgroundView?.backgroundColor = UIColor.white
        self.categoryBackgroundView?.layer.cornerRadius = 4.0
        self.categoryBackgroundView?.layer.borderColor = UIColor.lightGray.cgColor
        self.categoryBackgroundView?.layer.borderWidth = 1.0
        self.categoryBackgroundView?.layer.masksToBounds = true
    }
    
    func setCategoryTitle(categoryDictionary : [String : Any]) {
        self.categoryTitleLabel?.text = categoryDictionary["name"] as? String
    }
}
