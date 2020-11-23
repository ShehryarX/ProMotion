import UIKit

import AVKit

var playerLayer: AVPlayer?

class VideoViewController: UIViewController {
    
    var name: String = ""

    override func viewDidLoad() {
        var url = ""
        let BASE_URL = "http://shehryar.me/vids/"
        if (name == "Adi") {
            url = BASE_URL + "Adi.mp4"
        } else if (name == "Shahbaz") {
            url = BASE_URL + "Shahbaz.mp4"
        } else if (name == "Rafit") {
            url = BASE_URL + "Rafit.mp4"
        } else {
            url = BASE_URL + "Shehryar.mp4"
        }
        let videoURL = URL(string: url)
        let player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        player.play()
    }
}
