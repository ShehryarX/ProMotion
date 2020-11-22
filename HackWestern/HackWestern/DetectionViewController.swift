//
//  DetectionViewController.swift
//  HackWestern
//
//  Created by Rafit Jamil on 2020-11-21.
//

import Foundation
import UIKit
import Vision

class DetectionViewController: UIViewController {
    
    private let detectPlayerRequest = VNDetectHumanBodyPoseRequest()
    private let playerBoundingBox = BoundingBoxView()
    private let jointSegmentView = JointSegmentView()

    // Config constants
    private let bodyPoseDetectionMinConfidence: VNConfidence = 0.6
    private let bodyPoseRecognizedPointMinConfidence: VNConfidence = 0.1

    override func viewDidLoad() {
        setUIElements()
    }
    
    func setUIElements() {
        playerBoundingBox.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        playerBoundingBox.backgroundOpacity = 0
        playerBoundingBox.isHidden = true

        view.addSubview(playerBoundingBox)
        view.addSubview(jointSegmentView)

    }
    
    
    func updateBoundingBox(_ boundingBox: BoundingBoxView, withRect rect: CGRect?) {
        // Update the frame for player bounding box
        boundingBox.frame = rect ?? .zero
        boundingBox.perform(transition: (rect == nil ? .fadeOut : .fadeIn), duration: 0.1)
    }

    func humanBoundingBox(for observation: VNHumanBodyPoseObservation) -> CGRect {
        var box = CGRect.zero
        var normalizedBoundingBox = CGRect.null
        // Process body points only if the confidence is high.
        guard observation.confidence > bodyPoseDetectionMinConfidence, let points = try? observation.recognizedPoints(forGroupKey: .all) else {
            return box
        }
        // Only use point if human pose joint was detected reliably.
        for (_, point) in points where point.confidence > bodyPoseRecognizedPointMinConfidence {
            normalizedBoundingBox = normalizedBoundingBox.union(CGRect(origin: point.location, size: .zero))
        }
        if !normalizedBoundingBox.isNull {
            box = normalizedBoundingBox
        }
        // Fetch body joints from the observation and overlay them on the player.
        let joints = getBodyJointsFor(observation: observation)
        DispatchQueue.main.async {
            self.jointSegmentView.joints = joints
        }
        
        // Push to pose observations queue
        StateBridge.shared.classifier.storeObservation(observation)

        return box
    }

    func update() {
        // run classifier, post results
//        let bridge = StateBridge.shared
//        
//        let root = parent as! ViewController
        // TODO: determine classification routine
//        if let output = bridge.classifier.classifyAction() {
//            root.update(with: output)
//        }
    }
}


extension DetectionViewController: CameraViewControllerOutputDelegate {
    func cameraViewController(_ controller: CameraViewController, didReceiveBuffer buffer: CMSampleBuffer, orientation: CGImagePropertyOrientation) {
        let visionHandler = VNImageRequestHandler(cmSampleBuffer: buffer, orientation: orientation, options: [:])
            DispatchQueue.main.async {
                // Get the frame of rendered view
                let normalizedFrame = CGRect(x: 0, y: 0, width: 1, height: 1)
                self.jointSegmentView.frame = controller.viewRectForVisionRect(normalizedFrame)
            }

        do {
            try visionHandler.perform([detectPlayerRequest])
            if let result = detectPlayerRequest.results?.first {
                let box = humanBoundingBox(for: result)
                let boxView = playerBoundingBox
                DispatchQueue.main.async {
                    let inset: CGFloat = -20.0
                    let viewRect = controller.viewRectForVisionRect(box).insetBy(dx: inset, dy: inset)
                    self.updateBoundingBox(boxView, withRect: viewRect)
                }
//                DispatchQueue.main.async {
//                    self.update()
//                }
            }
        } catch {
            AppError.display(error, inViewController: self)
        }
    }
}
