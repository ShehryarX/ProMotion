//
//  DetailPageViewController.swift
//  Promotion
//
//  Created by Temp on 2020-11-21.
//

import UIKit
import AVKit

extension UIView {
    @discardableResult
    func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil)
    }

    @discardableResult
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
}

class DetailPageViewController: UIViewController {
    
    @IBOutlet weak var practiceButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var gradient: [UIColor] = []
    var titl: String = ""
    var image: String = ""
    var desc: String = ""
    
    override func viewDidLoad() {
        self.titleLabel.text = title! + " " + image
        self.subtitleLabel.text = desc

        
        let green = [#colorLiteral(red: 0.3796315193, green: 0.7958304286, blue: 0.2592983842, alpha: 1),#colorLiteral(red: 0.2060100436, green: 0.6006633639, blue: 0.09944178909, alpha: 1)]
        let bluePurple = [#colorLiteral(red: 0.4613699913, green: 0.3118675947, blue: 0.8906354308, alpha: 1),#colorLiteral(red: 0.3018293083, green: 0.1458326578, blue: 0.7334778905, alpha: 1)]
        
        super.viewDidLoad()
        self.practiceButton.layer.cornerRadius = 5
        self.practiceButton.layer.masksToBounds = true
        self.practiceButton.applyGradient(colours: [green.first!, green.last!], locations: [0.0, 1.0])
        
        self.submitButton.layer.cornerRadius = 5
        self.submitButton.layer.masksToBounds = true
        self.submitButton.applyGradient(colours: [bluePurple.first!, bluePurple.last!], locations: [0.0, 1.0])
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is VideoViewController {
            let title = (sender! as! CheckCollectionViewCell).label!.text!
            let vc = segue.destination as? VideoViewController
            vc?.name = title
        }
    }

}

var names = ["Rafit", "Shehryar", "Adi", "Shahbaz"]
var imageNames = ["rj", "sa", "ac", "sm"]

extension DetailPageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cellMake")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "check", for: indexPath) as! CheckCollectionViewCell
        cell.image.image = UIImage(named: imageNames[indexPath.item])
        cell.label.text = names[indexPath.item]
//        cell.layer.cornerRadius = 50
//        cell.clipsToBounds = true
        return cell
    }
    
    
}
