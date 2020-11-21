//
//  CollectionViewConroller.swift
//  Promotion
//
//  Created by Temp on 2020-11-21.
//

import UIKit

class PracticeSport {
    var name: String
    var supportedActions: [String]
    var image: UIImage
    var color: UIColor
    
    init(name: String, supportedActions: [String], image: UIImage, color: UIColor) {
        self.name = name
        self.supportedActions = supportedActions
        self.image = image
        self.color = color
    }
}

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    let practiceSports: [PracticeSport] = [
        PracticeSport(
            name: "Soccer",
            supportedActions: ["Kick"],
            image: UIImage(named: "soccer")!,
            color: UIColor(
                red: 102/256,
                green: 255/256,
                blue: 255/256,
                alpha: 0.66
            )
        ),
        PracticeSport(
            name: "Basketball",
            supportedActions: ["Jump Shot", "Free Throw"],
            image: UIImage(named: "basketball")!,
            color: UIColor(
                red: 102/256,
                green: 255/256,
                blue: 255/256,
                alpha: 0.66
            )
        )
    ]

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return practiceSports.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        cell.cellLabel.text = practiceSports[indexPath.item].name
        cell.cellSubLabel.text = practiceSports[indexPath.item].supportedActions.joined(separator: ", ")
//        cell.cellImage.image = practiceSports[indexPath.item].image
        cell.contentView.backgroundColor = UIColor(
            red: 102/256,
            green: 255/256,
            blue: 255/256,
            alpha: 0.66
        )

        cell.contentView.layer.masksToBounds = false
        cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.contentView.layer.shadowColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        cell.contentView.layer.shadowOpacity = 0.23
        cell.contentView.layer.shadowRadius = 4

        return cell
    }

}

