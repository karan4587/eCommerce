//
//  PopularProductsTableViewCell.swift
//  eCommerce

import UIKit

@objc protocol PopularProductsTableViewCellDelegate : AnyObject {
    @objc optional func showMoreOptionsPopUpView(selectedDictionary : [String : Any])
}

class PopularProductsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var productCollectionView : UICollectionView?
    var productArray : [[String : Any]] = []
    var dataRatingType : RatingType?
    var delegate : PopularProductsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.productCollectionView?.register(UINib(nibName: "PopularProductsCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "PopularProductsCollectionViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

//MARK:- UICollectionView Delegate and DataSource Method
extension PopularProductsTableViewCell : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return CGSize(width: collectionView.frame.width, height: 10.0)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (((self.productCollectionView?.frame.size.width ?? 0.0) / 2) - 20), height: 190.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        return edgeInset
      
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.productArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let productCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularProductsCollectionViewCell", for: indexPath) as! PopularProductsCollectionViewCell
        productCollectionCell.setProductValue(productDictionary: self.productArray[indexPath.item], shouldShowMoreOption: false)
        productCollectionCell.delegate = self
        return productCollectionCell
    }
}

//MARK:-PopularProductsCollectionViewCellDelegate Method
extension PopularProductsTableViewCell : PopularProductsCollectionViewCellDelegate {
    func showMoreProductOptionsView(selectedProductDictionary: [String : Any]) {
        self.delegate?.showMoreOptionsPopUpView?(selectedDictionary: selectedProductDictionary)
    }
}
