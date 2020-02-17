//
//  ProductVariantsView.swift
//  eCommerce

import UIKit

protocol ProductVariantsViewDelegate : AnyObject {
    func closeProductVariantsView()
}

class ProductVariantsView: UIView {
    @IBOutlet weak var productVariantsBackgroundView : UIView?
    @IBOutlet weak var closeButton : UIButton?
    @IBOutlet weak var productVariantsCollectionView : UICollectionView?
    var selectedProductDictionary : [String : Any] = [:]
    weak var delegate : ProductVariantsViewDelegate?
    
    func loadProductVariants(productDictionary : [String : Any]) {
        self.productVariantsCollectionView?.register(UINib(nibName: "PopularProductsCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "PopularProductsCollectionViewCell")
        self.selectedProductDictionary = productDictionary
        self.productVariantsCollectionView?.reloadData()
        
    }
    
    @IBAction func closeButtonClicked(sender : UIButton) {
        self.delegate?.closeProductVariantsView()
    }
}

extension ProductVariantsView : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (((self.productVariantsCollectionView?.frame.size.width ?? 0.0) / 2) - 20), height: 190.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        return edgeInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let productVariantsArray = self.selectedProductDictionary["variants"] as? [[String : Any]], !productVariantsArray.isEmpty {
            return productVariantsArray.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let productCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularProductsCollectionViewCell", for: indexPath) as! PopularProductsCollectionViewCell
        productCollectionCell.layoutIfNeeded()
        if let productVariantsArray = self.selectedProductDictionary["variants"] as? [[String : Any]], !productVariantsArray.isEmpty {
            productCollectionCell.setProductValue(productDictionary: self.selectedProductDictionary, shouldShowMoreOption: true, indexPath : indexPath)
        }
        return productCollectionCell
    }
}
