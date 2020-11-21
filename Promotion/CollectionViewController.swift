//
//  CollectionViewConroller.swift
//  Promotion
//
//  Created by Temp on 2020-11-21.
//

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    let practiceSportsNames: [String] = ["Soccer", "Basketball"]
    
    let practiceSportsImages: [UIImage] = [
        UIImage(named: "soccer")!,
        UIImage(named: "basketball")!
    ]

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return practiceSportsNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        cell.cellLabel.text = practiceSportsNames[indexPath.item]
        cell.cellImage.image = practiceSportsImages[indexPath.item]
        return cell
    }

}

