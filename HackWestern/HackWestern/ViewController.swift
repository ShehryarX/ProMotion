//
//  ViewController.swift
//  HackWestern
//
//  Created by Rafit Jamil on 2020-11-20.
//

import UIKit
import Vision

class ViewController: UIViewController {
        
    private var cameraViewController: CameraViewController!
    private var detectionViewController: DetectionViewController!
    private var overlayParentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup camera view
        cameraViewController = CameraViewController()
        cameraViewController.view.frame = view.bounds
        
        addChild(cameraViewController)
        cameraViewController.beginAppearanceTransition(true, animated: true)
        view.addSubview(cameraViewController.view)
        cameraViewController.endAppearanceTransition()
        cameraViewController.didMove(toParent: self)
        
        overlayParentView = UIView(frame: view.bounds)
        overlayParentView.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        overlayParentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayParentView)
        NSLayoutConstraint.activate([
            overlayParentView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            overlayParentView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            overlayParentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            overlayParentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        detectionViewController = DetectionViewController()
        
        presentController(detectionViewController)
    }

    func presentController(_ controllerToPresent: UIViewController) {
        
        // TODO: remove old overlay if present
        
        // Present the new controller
         let newOverlay = controllerToPresent
            newOverlay.view.frame = overlayParentView.bounds
            addChild(newOverlay)
            newOverlay.beginAppearanceTransition(true, animated: true)
            overlayParentView.addSubview(newOverlay.view)
            newOverlay.endAppearanceTransition()
            newOverlay.didMove(toParent: self)
        

        
        if let cameraVC = cameraViewController {
            let viewRect = cameraVC.view.frame
            let videoRect = cameraVC.viewRectForVisionRect(CGRect(x: 0, y: 0, width: 1, height: 1))
            let insets = controllerToPresent.view.safeAreaInsets
            let additionalInsets = UIEdgeInsets(
                    top: videoRect.minY - viewRect.minY - insets.top,
                    left: videoRect.minX - viewRect.minX - insets.left,
                    bottom: viewRect.maxY - videoRect.maxY - insets.bottom,
                    right: viewRect.maxX - videoRect.maxX - insets.right)
            controllerToPresent.additionalSafeAreaInsets = additionalInsets
        }
        
        if let outputDelegate = controllerToPresent as? CameraViewControllerOutputDelegate {
            self.cameraViewController.outputDelegate = outputDelegate
        }
    }
}
