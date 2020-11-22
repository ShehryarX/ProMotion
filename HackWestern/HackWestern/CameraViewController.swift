/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The camera view controller manages the video capture pipeline.
*/

import UIKit
import AVFoundation

protocol CameraViewControllerOutputDelegate: class {
    func cameraViewController(_ controller: CameraViewController, didReceiveBuffer buffer: CMSampleBuffer, orientation: CGImagePropertyOrientation)
}

class CameraViewController: UIViewController {
    
    weak var outputDelegate: CameraViewControllerOutputDelegate?
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInitiated,
                                                     attributes: [], autoreleaseFrequency: .workItem)

    // Live camera feed management
    private var cameraFeedView: CameraFeedView!
    private var cameraFeedSession: AVCaptureSession?

    // Video file playback management
    private var videoRenderView: VideoRenderView!
    private var playerItemOutput: AVPlayerItemVideoOutput?
    private var displayLink: CADisplayLink?
    private let videoFileReadingQueue = DispatchQueue(label: "VideoFileReading", qos: .userInteractive)
    private var videoFileBufferOrientation = CGImagePropertyOrientation.up
    private var videoFileFrameDuration = CMTime.invalid
    
    
    var videoPlayer: AVPlayer? = nil

    var _filename: String!
    
    private var isRecording: Bool {
        get {
            StateBridge.shared.isRecording
        }
        set {
            StateBridge.shared.isRecording = newValue
        }
    }
    
    func loadRecordedVideo() {
        _filename = "recorded"
        let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(_filename!).mov")

//        startReadingAsset(AVAsset(url: URL(fileURLWithPath: Bundle.main.path(forResource: "ideal-vball", ofType: "mov")!)))

        startReadingAsset(AVAsset(url: videoPath))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try setupAVSession()
//            startReadingAsset(AVAsset(url: URL(fileURLWithPath: Bundle.main.path(forResource: "ideal-vball", ofType: "mov")!)))
        } catch {
            AppError.display(error, inViewController: self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Stop capture session if it's running
        cameraFeedSession?.stopRunning()
        // Invalidate display link so it's removed from run loop
        displayLink?.invalidate()
    }
        
    func setupAVSession() throws {
        shouldNotifyObserver = true
        removeListeners()
        videoPlayer = nil
        
        // Create device discovery session for a wide angle camera
        let wideAngle = AVCaptureDevice.DeviceType.builtInWideAngleCamera
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [wideAngle], mediaType: .video, position: .unspecified)
        
        // Select a video device, make an input
        guard let videoDevice = discoverySession.devices.first else {
            throw AppError.captureSessionSetup(reason: "Could not find a wide angle camera device.")
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw AppError.captureSessionSetup(reason: "Could not create video device input.")
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        // We prefer a 1080p video capture but if camera cannot provide it then fall back to highest possible quality
        if videoDevice.supportsSessionPreset(.hd1920x1080) {
            session.sessionPreset = .hd1920x1080
        } else {
            session.sessionPreset = .high
        }
        
        // Add a video input
        guard session.canAddInput(deviceInput) else {
            throw AppError.captureSessionSetup(reason: "Could not add video device input to the session")
        }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            // Add a video data output
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [
                String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            ]
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw AppError.captureSessionSetup(reason: "Could not add video data output to the session")
        }
                
        let captureConnection = dataOutput.connection(with: .video)
        captureConnection?.preferredVideoStabilizationMode = .standard
        // Always process the frames
        captureConnection?.isEnabled = true
        session.commitConfiguration()
        cameraFeedSession = session
        
        // Get the interface orientaion from window scene to set proper video orientation on capture connection.
        let videoOrientation: AVCaptureVideoOrientation = .portrait
//        switch view.window?.windowScene?.interfaceOrientation {
//        case .landscapeRight:
//            videoOrientation = .landscapeRight
//        default:
//            videoOrientation = .portrait
//        }
  
        // Create and setup video feed view
        cameraFeedView = CameraFeedView(frame: view.bounds, session: session, videoOrientation: videoOrientation)
        setupVideoOutputView(cameraFeedView)
        cameraFeedSession?.startRunning()
    }
    
    // This helper function is used to convert rects returned by Vision to the video content rect coordinates.
    //
    // The video content rect (camera preview or pre-recorded video)
    // is scaled to fit into the view controller's view frame preserving the video's aspect ratio
    // and centered vertically and horizontally inside the view.
    //
    // Vision coordinates have origin at the bottom left corner and are normalized from 0 to 1 for both dimensions.
    //
    func viewRectForVisionRect(_ visionRect: CGRect) -> CGRect {
        let flippedRect = visionRect.applying(CGAffineTransform.verticalFlip).applying(
            CGAffineTransform.init(translationX: 0.5, y: 0.5)
                .rotated(by: -90.0 * (.pi / 180.0))
                .translatedBy(x: -0.5, y: -0.5)
        )
        let viewRect: CGRect
        if cameraFeedSession != nil {
            viewRect = cameraFeedView.viewRectConverted(fromNormalizedContentsRect: flippedRect)
        } else {
            viewRect = videoRenderView.viewRectConverted(fromNormalizedContentsRect: flippedRect)
        }
        return viewRect
    }

    // This helper function is used to convert points returned by Vision to the video content rect coordinates.
    //
    // The video content rect (camera preview or pre-recorded video)
    // is scaled to fit into the view controller's view frame preserving the video's aspect ratio
    // and centered vertically and horizontally inside the view.
    //
    // Vision coordinates have origin at the bottom left corner and are normalized from 0 to 1 for both dimensions.
    //
    func viewPointForVisionPoint(_ visionPoint: CGPoint) -> CGPoint {
        let flippedPoint = visionPoint.applying(CGAffineTransform.verticalFlip)
        let viewPoint: CGPoint
        if cameraFeedSession != nil {
            viewPoint = cameraFeedView.viewPointConverted(fromNormalizedContentsPoint: flippedPoint)
        } else {
            viewPoint = videoRenderView.viewPointConverted(fromNormalizedContentsPoint: flippedPoint)
        }
        return viewPoint
    }

    func setupVideoOutputView(_ videoOutputView: UIView) {
        videoOutputView.translatesAutoresizingMaskIntoConstraints = false
        videoOutputView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        view.addSubview(videoOutputView)
        NSLayoutConstraint.activate([
            videoOutputView.leftAnchor.constraint(equalTo: view.leftAnchor),
            videoOutputView.rightAnchor.constraint(equalTo: view.rightAnchor),
            videoOutputView.topAnchor.constraint(equalTo: view.topAnchor),
            videoOutputView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private var playerItem: AVPlayerItem? = nil
    
    func addListeners() {
        videoPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.03, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main) {
            [weak self] time in
            let root = self?.parent as? ViewController
            root?.updateSeekBar(time)
            
            if let item = self?.playerItem {
                
                let dur = item.duration.seconds
                
                if dur > 0.0 {
                    root?.configureSeekBar(item.duration)
                }
            }
            
        }
    }
    
    func removeListeners() {
    }
    
    var isPlaying = false
    var wasPlaying = false
    
    func markPlayState() {
        wasPlaying = isPlaying
    }
    
    func play() {
        videoPlayer?.play()
        isPlaying = true
        
        (parent as? ViewController)?.onPlayStateChange(isPlaying)
    }
    
    func pause() {
        videoPlayer?.pause()
        isPlaying = false
        
        (parent as? ViewController)?.onPlayStateChange(isPlaying)
    }
    
    func seek(_ seconds: Float) {
        videoPlayer?.seek(to: CMTime(seconds: Double(seconds), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
    }
    
    func playIfWasPaused() {
        if wasPlaying {
            play()
        }
    }
        
    func startReadingAsset(_ asset: AVAsset) {
        shouldNotifyObserver = false
        videoRenderView = VideoRenderView(frame: view.bounds)
        setupVideoOutputView(videoRenderView)
        
        // Setup display link
        let displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(_:)))
        displayLink.preferredFramesPerSecond = 0 // Use display's rate
        displayLink.isPaused = true
        displayLink.add(to: RunLoop.current, forMode: .default)
        
        guard let track = asset.tracks(withMediaType: .video).first else {
            AppError.display(AppError.videoReadingError(reason: "No video tracks found in AVAsset."), inViewController: self)
            return
        }
        
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        let settings = [
            String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]
        let output = AVPlayerItemVideoOutput(pixelBufferAttributes: settings)
        item.add(output)
        
        playerItem = item
        player.actionAtItemEnd = .pause
        player.play()
        isPlaying = true
        wasPlaying = true
        
        videoPlayer = player

        addListeners()        

        self.displayLink = displayLink
        self.playerItemOutput = output
        self.videoRenderView.player = player

        let affineTransform = track.preferredTransform.inverted()
        let angleInDegrees = atan2(affineTransform.b, affineTransform.a) * CGFloat(180) / CGFloat.pi
        var orientation: UInt32 = 1
        switch angleInDegrees {
        case 0:
            orientation = 1 // Recording button is on the right
        case 180, -180:
            orientation = 3 // abs(180) degree rotation recording button is on the right
        case 90:
            orientation = 8 // 90 degree CW rotation recording button is on the top
        case -90:
            orientation = 6 // 90 degree CCW rotation recording button is on the bottom
        default:
            orientation = 1
        }
        videoFileBufferOrientation = CGImagePropertyOrientation(rawValue: orientation)!
        videoFileFrameDuration = track.minFrameDuration
        displayLink.isPaused = false
    }
    
    @objc
    private func handleDisplayLink(_ displayLink: CADisplayLink) {
        guard let output = playerItemOutput else {
            return
        }
        
        videoFileReadingQueue.async {
            let nextTimeStamp = displayLink.timestamp + displayLink.duration
            let itemTime = output.itemTime(forHostTime: nextTimeStamp)
            guard output.hasNewPixelBuffer(forItemTime: itemTime) else {
                return
            }
            guard let pixelBuffer = output.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil) else {
                return
            }
            // Create sample buffer from pixel buffer
            var sampleBuffer: CMSampleBuffer?
            var formatDescription: CMVideoFormatDescription?
            CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: pixelBuffer, formatDescriptionOut: &formatDescription)
            let duration = self.videoFileFrameDuration
            var timingInfo = CMSampleTimingInfo(duration: duration, presentationTimeStamp: itemTime, decodeTimeStamp: itemTime)
            CMSampleBufferCreateForImageBuffer(allocator: nil,
                                               imageBuffer: pixelBuffer,
                                               dataReady: true,
                                               makeDataReadyCallback: nil,
                                               refcon: nil,
                                               formatDescription: formatDescription!,
                                               sampleTiming: &timingInfo,
                                               sampleBufferOut: &sampleBuffer)
            if let sampleBuffer = sampleBuffer {
                self.outputDelegate?.cameraViewController(self, didReceiveBuffer: sampleBuffer, orientation: self.videoFileBufferOrientation)
                DispatchQueue.main.async {
                    // Have setup stage
                }
            }
        }
    }
        
    func startRecording() {
        do {
            _captureState = .start
            try? setupAVSession()
        } catch {
            print(error)
        }
    }
    
    func stopRecording() {
        _captureState = .end
        removeListeners()
    }
    
    private enum _CaptureState {
        case idle, start, capturing, end
    }
    private var _captureState = _CaptureState.idle
    
    private var _assetWriter: AVAssetWriter!
    private var _assetWriterInput: AVAssetWriterInput!
    private var _adapter: AVAssetWriterInputPixelBufferAdaptor!
    private var _time: Double = 0.0
    
    private var shouldNotifyObserver = true
}


extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if shouldNotifyObserver {
            outputDelegate?.cameraViewController(self, didReceiveBuffer: sampleBuffer, orientation: .right)
        }
        
        // Also write out
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
                switch _captureState {
                case .start:
                    // Set up recorder
                    _filename = "recorded"
                    let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(_filename!).mov")
                    
                    do {
                        if FileManager.default.fileExists(atPath: videoPath.path) {
                            try FileManager.default.removeItem(at: videoPath)
                            print("file removed")
                        }
                        } catch {
                            print(error)
                        }
                    
                    let writer = try! AVAssetWriter(outputURL: videoPath, fileType: .mov)
                                        
                    let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
                        AVVideoCodecKey: AVVideoCodecType.h264,
                        AVVideoWidthKey: 1920,
                        AVVideoHeightKey: 1080,
                        AVVideoCompressionPropertiesKey: [
                            AVVideoAverageBitRateKey: 8000000
                        ]
                    ])
                    // [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 1920, AVVideoHeightKey: 1080])
                    
                    input.mediaTimeScale = CMTimeScale(bitPattern: 600)
                    input.expectsMediaDataInRealTime = true
                    input.transform = CGAffineTransform(rotationAngle: .pi/2)
                    
                    let adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
                    if writer.canAdd(input) {
                        writer.add(input)
                    }
                    
                    writer.startWriting()
                    writer.startSession(atSourceTime: .zero)
                    
                    _assetWriter = writer
                    _assetWriterInput = input
                    _adapter = adapter
                    _captureState = .capturing
                    _time = timestamp
                    
                case .capturing:
                    if _assetWriterInput?.isReadyForMoreMediaData == true {
                        let time = CMTime(seconds: timestamp - _time, preferredTimescale: CMTimeScale(600))
                        _adapter?.append(CMSampleBufferGetImageBuffer(sampleBuffer)!, withPresentationTime: time)
                    }
                    break
                case .end:
                    guard _assetWriterInput?.isReadyForMoreMediaData == true, _assetWriter!.status != .failed else { break }
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(_filename!).mov")
                    _assetWriterInput?.markAsFinished()
                    _assetWriter?.finishWriting { [weak self] in
                        self?._captureState = .idle
                        self?._assetWriter = nil
                        self?._assetWriterInput = nil
                        DispatchQueue.main.async {
                            self?.loadRecordedVideo()
                            (self?.parent as? ViewController)?.onRecordFinished()
                        }
                    }
                default:
                    break
                }
    }
}
