//
//  CategoryViewTableViewCell.swift
//  eCommerce

import UIKit

protocol CategoryViewTableViewCellDelegate : class {
    func collectionDidSelectItem(selectedCategory : [String : Any], dataRatingType : RatingType)
}

class CategoryViewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryCollectionView : UICollectionView?
    var categoryArray : [[String : Any]] = []
    var dataRatingType : RatingType?
    weak var delegate : CategoryViewTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.categoryCollectionView?.register(UINib(nibName: "CategoryViewCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CategoryViewCollectionViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

//MARK:-UICollection View Delegate and DataSource Method
extension CategoryViewTableViewCell : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
            return CGSize(width: collectionView.frame.width, height: 10.0)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (((self.categoryCollectionView?.frame.size.width ?? 0.0) / 2) - 20), height: 150.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        return edgeInset
      
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let categoryCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryViewCollectionViewCell", for: indexPath) as! CategoryViewCollectionViewCell
        categoryCollectionCell.setCategoryTitle(categoryDictionary: self.categoryArray[indexPath.item])
        return categoryCollectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.collectionDidSelectItem(selectedCategory: self.categoryArray[indexPath.item], dataRatingType: self.dataRatingType!)
    }
}
