/*
See LICENSE folder for this sample’s licensing information.

Abstract:
View that displays a joint segment.
*/

import UIKit
import Vision

class JointSegmentView: UIView, AnimatedTransitioning {
    var joints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:] {
        didSet {
            updatePathLayer()
        }
    }

    private let jointRadius: CGFloat = 3.0
    private let jointLayer = CAShapeLayer()
    private var jointPath = UIBezierPath()

    private let jointSegmentWidth: CGFloat = 4.5
    private let jointSegmentLayer = CAShapeLayer()
    private var jointSegmentPath = UIBezierPath()
    
    private let repitions = 6
    private let gradientColors: [UIColor] = [UIColor(hex: "#198fff")!, UIColor(hex: "#cd65db")!, UIColor(hex: "#f75761")!, UIColor(hex: "#ffd316")!]
// 833ab4
    private let gradient = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }

    func resetView() {
        jointLayer.path = nil
        jointSegmentLayer.path = nil
    }

    private func setupLayer() {
        jointSegmentLayer.lineCap = .round
        jointSegmentLayer.lineWidth = jointSegmentWidth
        jointSegmentLayer.fillColor = UIColor.clear.cgColor
        jointSegmentLayer.strokeColor = UIColor.white.cgColor
        
        var actualColors = [CGColor](repeating: UIColor.black.cgColor, count: gradientColors.count * repitions)
        
        for index in 0 ..< gradientColors.count * repitions {
            actualColors[index] = gradientColors[index % gradientColors.count].cgColor
        }
        
        gradient.colors = actualColors
      
        layer.addSublayer(gradient)
        
        let jointColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        jointLayer.strokeColor = jointColor
        jointLayer.fillColor = jointColor
        layer.addSublayer(jointLayer)
    }

    private func updatePathLayer() {
        let flipVertical = CGAffineTransform.verticalFlip
        let scaleToBounds = CGAffineTransform(scaleX: bounds.width, y: bounds.height)
        jointPath.removeAllPoints()
        jointSegmentPath.removeAllPoints()
        // Add all joints and segments
        for index in 0 ..< jointsOfInterest.count {
            if let nextJoint = joints[jointsOfInterest[index]] {
                let nextJointScaled = nextJoint.applying(flipVertical).applying(scaleToBounds)
                let nextJointPath = UIBezierPath(arcCenter: nextJointScaled, radius: jointRadius,
                                                 startAngle: CGFloat(0), endAngle: CGFloat.pi * 2, clockwise: true)
                jointPath.append(nextJointPath)
                if jointSegmentPath.isEmpty {
                    jointSegmentPath.move(to: nextJointScaled)
                } else {
                    jointSegmentPath.addLine(to: nextJointScaled)
                }
            }
        }
        jointLayer.path = jointPath.cgPath
        jointSegmentLayer.path = jointSegmentPath.cgPath
        
        gradient.frame = layer.bounds
        gradient.mask = jointSegmentLayer
    }
}
