//
//  PopularProductsCollectionViewCell.swift
//  eCommerce

import UIKit

protocol PopularProductsCollectionViewCellDelegate : AnyObject {
    func showMoreProductOptionsView(selectedProductDictionary : [String : Any])
}

class PopularProductsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productBackgroundView : UIView?
    @IBOutlet weak var productImageView : UIImageView?
    @IBOutlet weak var productTitleLabel : UILabel?
    @IBOutlet weak var productSizeLabel : UILabel?
    @IBOutlet weak var productColorLabel : UILabel?
    @IBOutlet weak var productPriceLabel : UILabel?
    @IBOutlet weak var moreOptionsButton : UIButton?
    
    var selectedProductDictionary : [String : Any] = [:]
    
    weak var delegate : PopularProductsCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setLayoutOfView()
    }
    
    func setLayoutOfView() {
        self.productBackgroundView?.backgroundColor = UIColor.white
        self.productBackgroundView?.layer.cornerRadius = 4.0
        self.productBackgroundView?.layer.borderColor = UIColor.lightGray.cgColor
        self.productBackgroundView?.layer.borderWidth = 1.0
        self.productBackgroundView?.layer.masksToBounds = true
    }
    
    func setProductValue(productDictionary : [String : Any], shouldShowMoreOption : Bool, indexPath : IndexPath = [0,0]) {
        self.selectedProductDictionary = productDictionary
        
        self.productTitleLabel?.text = productDictionary["name"] as? String
        
        if let productVariantsArray = productDictionary["variants"] as? [[String : Any]], !productVariantsArray.isEmpty {
            self.productSizeLabel?.text = "Size : \(String(productVariantsArray[indexPath.item]["size"] as? Int ?? 0))"
            self.productColorLabel?.text = "Color : \(productVariantsArray[indexPath.item]["color"] as? String ?? "NA")"
            self.productPriceLabel?.text = "Price : \(String(productVariantsArray[indexPath.item]["price"] as? Int ?? 0))"
            
            if productVariantsArray.count > 1 {
                self.moreOptionsButton?.isHidden = false
            } else {
                self.moreOptionsButton?.isHidden = true
            }
            
        } else {
            self.moreOptionsButton?.isHidden = true
        }
        
        if shouldShowMoreOption {
            self.moreOptionsButton?.isHidden = true
        }
    }
    
    @IBAction func moreOptionsButtonClicked(sender : UIButton) {
        if !self.selectedProductDictionary.isEmpty {
            self.delegate?.showMoreProductOptionsView(selectedProductDictionary : self.selectedProductDictionary)
        }
    }
}
