//
//  ActionVideoViewController.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/23/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import UIKit
import AVKit

class ActionVideoViewController: UIViewController {
    private var player = AVPlayer()
//    private var layerPlayer : AVPlayerLayer!
    
    let video = VideoContainerView()
    let avPlayerController = AVPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(video.bounds)
        self.avPlayerController.frame = video.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player = AVPlayer(playerItem: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.play()
//        playerControler.player = player
//        playerControler.showsPlaybackControls = true
//        //        playerControler.view.frame = CGRect(x: 44, y: 128, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
//
//        // Turn on video controlls
//        playerControler.showsPlaybackControls = true
//
//        // play video
//        playerControler.player?.play()
    }
}

extension ActionVideoViewController {
    private func setupUI(){
        self.view.backgroundColor = .white
        if let demoUrl = Bundle(for: type(of: self)).url(forResource: "demovideo", withExtension: "mp4") {
            player = AVPlayer(url: demoUrl)
        }
        
        self.view.addSubview(video)
        video.snp.makeConstraints({
            $0.center.width.equalToSuperview()
            $0.height.equalTo(self.view.bounds.width * 9 / 16)
        })
        
        avPlayerController.player = player
        avPlayerController.backgroundColor = UIColor.black.cgColor
        video.layer.addSublayer(avPlayerController)
    }
}
