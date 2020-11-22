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
    var compareJoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:] {
        didSet {
            updatePathLayer()
        }
    }

    private let jointRadius: CGFloat = 3.0
    private let jointLayer = CAShapeLayer()
    private var jointPath = UIBezierPath()
    
    private let jointCompareLayer = CAShapeLayer()
    private var jointComparePath = UIBezierPath()

    private let jointSegmentWidth: CGFloat = 4.5
    private let jointSegmentLayer = CAShapeLayer()
    private var jointSegmentPath = UIBezierPath()
    
    private let jointSegmentCompareLayer = CAShapeLayer()
    private var jointSegmentComparePath = UIBezierPath()
    
    private let errorLayer = CAShapeLayer()
    private var errorPath = UIBezierPath()
    
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
        
        jointSegmentCompareLayer.lineCap = .round
        jointSegmentCompareLayer.lineWidth = jointSegmentWidth
        jointSegmentCompareLayer.fillColor = UIColor.clear.cgColor
        jointSegmentCompareLayer.strokeColor = UIColor.systemOrange.cgColor
        layer.addSublayer(jointSegmentCompareLayer)
        
        jointCompareLayer.strokeColor = jointColor
        jointCompareLayer.fillColor = jointColor
        layer.addSublayer(jointCompareLayer)
        
        let strokeColor = UIColor(hex: "#e32c1b66")
        errorLayer.strokeColor = UIColor.clear.cgColor
        errorLayer.fillColor = strokeColor?.cgColor
        layer.addSublayer(errorLayer)
    }

    private func updatePathLayer() {
        let flipVertical = CGAffineTransform.verticalFlip
        let scaleToBounds = CGAffineTransform(scaleX: bounds.width, y: bounds.height)
        jointPath.removeAllPoints()
        jointSegmentPath.removeAllPoints()
        
        jointComparePath.removeAllPoints()
        jointSegmentComparePath.removeAllPoints()
        
        errorPath.removeAllPoints()
        
        // translate all compare points to the active entity points pinned on the root joint
        let liveRoot = joints[.root]?.applying(flipVertical)
        let compareRoot = compareJoints[.root]?.applying(flipVertical)
                
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
        
        if liveRoot != nil && compareRoot != nil {
        
            let diff = CGPoint(x: liveRoot!.x - compareRoot!.x, y: liveRoot!.y - compareRoot!.y)
            let translate = CGAffineTransform(translationX: diff.x, y: diff.y)

            for index in 0 ..< jointsOfInterest.count {
                if let nextJoint = compareJoints[jointsOfInterest[index]] {
                    let nextJointScaled = nextJoint.applying(flipVertical).applying(translate).applying(scaleToBounds)
                    let nextJointPath = UIBezierPath(arcCenter: nextJointScaled, radius: jointRadius,
                                                     startAngle: CGFloat(0), endAngle: CGFloat.pi * 2, clockwise: true)
                    jointComparePath.append(nextJointPath)
                    if jointSegmentComparePath.isEmpty {
                        jointSegmentComparePath.move(to: nextJointScaled)
                    } else {
                        jointSegmentComparePath.addLine(to: nextJointScaled)
                    }
                }
            }
        }

        
        jointCompareLayer.path = jointComparePath.cgPath
        jointSegmentCompareLayer.path = jointSegmentComparePath.cgPath
        
        jointLayer.path = jointPath.cgPath
        jointSegmentLayer.path = jointSegmentPath.cgPath
        
        errorLayer.path = errorPath.cgPath
        
        gradient.frame = layer.bounds
        gradient.mask = jointSegmentLayer
    }
}
