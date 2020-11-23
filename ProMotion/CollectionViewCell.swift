//
//  CollectionViewCell.swift
//  Promotion
//
//  Created by Temp on 2020-11-21.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var cellImage: UILabel!
    @IBOutlet weak var cellSubLabel: UILabel!
    @IBOutlet weak var cellLabel: UILabel!
    var gradient: [UIColor] = []
    var image: String = ""
}
