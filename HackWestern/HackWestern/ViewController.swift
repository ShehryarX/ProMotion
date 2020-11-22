//
//  ViewController.swift
//  HackWestern
//
//  Created by Rafit Jamil on 2020-11-20.
//

import UIKit
import Vision
import Charts
import TinyConstraints

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

class ViewController: UIViewController {
        
    private var cameraViewController: CameraViewController!
    private var detectionViewController: DetectionViewController!
    private var overlayParentView: UIView!

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var chartContainerView: UIView!
    
    @IBOutlet weak var activityIndicatorContainer: UIStackView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var seekBar: UISlider!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var activityText: UILabel!
    
    private var isRecording: Bool {
        get {
            StateBridge.shared.isRecording
        }
        set {
            StateBridge.shared.isRecording = newValue
        }
    }
    
    // charts
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.legend.enabled = false
        chartView.rightAxis.enabled = false
        chartView.xAxis.axisMinimum = 0.0
        chartView.xAxis.axisRange = 10.0
        
        chartView.largeContentTitle = "Performance"
        
        return chartView;
    }()
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    let yValues: [ChartDataEntry] = [
        ChartDataEntry(x: 0.0, y: 10.0),
        ChartDataEntry(x: 1.0, y: 15.0),
        ChartDataEntry(x: 2.0, y: 32.0),
        ChartDataEntry(x: 3.0, y: 41.0),
        ChartDataEntry(x: 4.0, y: 55.0),
        ChartDataEntry(x: 5.0, y: 51.0),
        ChartDataEntry(x: 6.0, y: 76.0),
        ChartDataEntry(x: 7.0, y: 88.0),
        ChartDataEntry(x: 8.0, y: 89.0),
        ChartDataEntry(x: 9.0, y: 93.0),
        
    ]
    
    @objc func updateGraph(sender: UIButton!) {
        let newY = Int.random(in: 1..<100)
        
        
    }
    
    
    func setData() {
        let set1 = LineChartDataSet(entries: yValues)
        set1.mode = .cubicBezier
        set1.circleRadius = 4
        
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
    }
    
    func loadIdeals() {
        let idealVballPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("vball-ideal.bin")

        do {
            if let data = FileManager.default.contents(atPath: idealVballPath.path) {
                if let idealVball = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [VNHumanBodyPoseObservation] {
                    StateBridge.shared.observationStore.idealVball = idealVball
                }
            }
        } catch {
            print(error)
        }
    }

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
        
        
        // Setup chart
        chartContainerView.addSubview(lineChartView)

        lineChartView.width(200)
        lineChartView.height(150)
        
        setData()
        detectionViewController = DetectionViewController()
        
        presentController(detectionViewController)

        bottomView.layer.cornerRadius = 12.0
        view.bringSubviewToFront(bottomView)
        
        reportView.layer.cornerRadius = 12.0
        view.bringSubviewToFront(reportView)
        
        activityIndicatorContainer.layer.cornerRadius = 12.0
        view.bringSubviewToFront(activityIndicatorContainer)
        
        seekBar.isEnabled = true
        playButton.isEnabled = true
        
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = true
        
        DispatchQueue.global().async {
            self.loadIdeals()
        }
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
    
    @IBAction func recordTriggered(_ sender: Any) {
        isRecording = !isRecording

        if isRecording {
            recordButton.tintColor = UIColor.systemRed
            recordButton.setImage(UIImage(systemName: "stop.circle.fill"), for: .normal)

            cameraViewController.startRecording()
        } else {
            recordButton.tintColor = UIColor.systemBlue
            recordButton.setImage(UIImage(systemName: "record.circle"), for: .normal)


            cameraViewController.stopRecording()
        }
    }
    
    func executeModel() {
        DispatchQueue.global(qos: .userInitiated).async {
                        
//            do {
//            if FileManager.default.fileExists(atPath: idealVballPath.path) {
//                try FileManager.default.removeItem(at: idealVballPath)
//            }
//            } catch {
//                print(error)
//            }
//
//            do {
//                let arr = StateBridge.shared.observationStore.poseObservations
//                    let data = try NSKeyedArchiver.archivedData(withRootObject: arr, requiringSecureCoding: false)
//                    try data.write(to: idealVballPath)
//                    print("wrote!")
//            } catch {
//                print(error)
//            }
            
            let result = StateBridge.shared.observationStore.classifyAction()
            DispatchQueue.main.async {
                self.activityText.text = result?.label.uppercased()
                self.stopLoadingUI()
            }
        }
    }
    
    func stopLoadingUI () {
        loadingIndicator.isHidden = true
        activityText.isHidden = false
        seekBar.isEnabled = true
    }
    
    func updateSeekBar(_ time: CMTime) {
        seekBar.value = Float(time.seconds)
        if abs(seekBar.maximumValue - seekBar.value) <= 0.01 {
            // re-enable seek
            executeModel()
        }
    }
    
    func configureSeekBar(_ duration: CMTime) {
        seekBar.minimumValue = 0.0
        seekBar.maximumValue = Float(duration.seconds)
    }
    
    @IBAction func onSeekStart(_ sender: Any) {
        cameraViewController.markPlayState()
        cameraViewController.pause()
    }
    
    @IBAction func onSeek(_ sender: Any) {
        cameraViewController.seek(seekBar.value)
    }
    
    @IBAction func onSeekEnd(_ sender: Any) {
        cameraViewController.playIfWasPaused()
    }
 
    func onPlayStateChange(_ isPlaying: Bool) {
        if(!isPlaying) {
            
        }
    }
    
    func onRecordFinished() {
        // Clear exisiting poses, and gather new ones
        StateBridge.shared.observationStore.resetObservations();
        print("on record finished")
    // disable seek till at the end to gather our observations
        seekBar.isEnabled = false
        activityText.isHidden = true
        loadingIndicator.isHidden = false
        
    }
    
}
