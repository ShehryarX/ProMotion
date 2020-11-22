//
//  DetailPageViewController.swift
//  Promotion
//
//  Created by Temp on 2020-11-21.
//

import UIKit

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
    @IBOutlet weak var submitButton: UIButton!
    
    var gradient: [UIColor] = []
    var selectedSport: String = ""
    var image: String = ""
    
    override func viewDidLoad() {
        let green = [#colorLiteral(red: 0.3796315193, green: 0.7958304286, blue: 0.2592983842, alpha: 1),#colorLiteral(red: 0.2060100436, green: 0.6006633639, blue: 0.09944178909, alpha: 1)]
        let bluePurple = [#colorLiteral(red: 0.4613699913, green: 0.3118675947, blue: 0.8906354308, alpha: 1),#colorLiteral(red: 0.3018293083, green: 0.1458326578, blue: 0.7334778905, alpha: 1)]
        
        super.viewDidLoad()
        self.practiceButton.layer.cornerRadius = 5
        self.practiceButton.layer.masksToBounds = true
        self.practiceButton.applyGradient(colours: [green.first!, green.last!], locations: [0.0, 1.0])
        
        self.submitButton.layer.cornerRadius = 5
        self.submitButton.layer.masksToBounds = true
        self.submitButton.applyGradient(colours: [bluePurple.first!, bluePurple.last!], locations: [0.0, 1.0])
    }
    
}
