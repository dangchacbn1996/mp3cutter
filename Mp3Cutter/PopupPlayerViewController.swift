//
//  PopupPlayerViewController.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/22/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class PopupPlayerViewController: UIViewController {
    
    private let viewContainer = UIView()
    private let slide = UISlider()
    private let lbName = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), color: .black)
    private let lbTime = UILabel(text: "", font: UIFont.systemFont(ofSize: 12), color: UIColor.black)
    private let lbTotalTime = UILabel(text: "/", font: UIFont.systemFont(ofSize: 12), color: .black)
    private let btnPlay = UIButton()
    private var player = AVPlayer()
    private var statePlay = PlayState.play {
        didSet {
            switch self.statePlay {
            case .pause:
                btnPlay.setImage(UIImage(named: "ic_play")?.withRenderingMode(.alwaysTemplate), for: .normal)
                player.pause()
                break
            case .play:
                btnPlay.setImage(UIImage(named: "ic_pause")?.withRenderingMode(.alwaysTemplate), for: .normal)
                player.play()
                break
            case .stop:
//                if player.currentItem != nil {
//                    player.seek(to: convertPointToTime(startPoint) )
//                } else {
                    player.seek(to: CMTime(seconds: 0, preferredTimescale: 0))
//                }
                player.pause()
                btnPlay.setImage(UIImage(named: "ic_stop")?.withRenderingMode(.alwaysTemplate), for: .normal)
                break
            default:
                break
            }
        }
    }
    var url : URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player = AVPlayer(url: url)
        lbName.text = url.lastPathComponent
        Loading.sharedInstance.show(in: self.view, deadline: 20.0)
        slide.value = 0
        self.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.02, preferredTimescale: 1000), queue: DispatchQueue.main, using: { (time) in
            if let item = self.player.currentItem {
                self.slide.value = Float(self.player.currentTime().seconds / item.duration.seconds)
                let secs = Int(self.player.currentTime().seconds)
                self.lbTime.text = NSString(format: "%02d:%02d", secs/60, secs%60) as String
            }
        })
        let asset = AVAsset(url: url)
        lbTotalTime.text = NSString(format: "/ %02d:%02d", Int(asset.duration.seconds/60), Int(asset.duration.seconds.truncatingRemainder(dividingBy: 60))) as String
        player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayer && keyPath == "status" {
            Loading.sharedInstance.dismiss()
            statePlay = .play
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
        player.replaceCurrentItem(with: nil)
    }
    
    @objc func playPauseAudio() {
        switch statePlay {
        case .play:
            statePlay = .pause
            break
        case .pause:
            statePlay = .play
            break
        case .stop:
            statePlay = .play
            break
        default:
            break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first?.location(in: self.view)
        if (!viewContainer.frame.contains(touch!)) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func seek() {
        if let total = player.currentItem?.duration.seconds {
            let current = slide.value * Float(total)
            player.seek(to: CMTime(value: CMTimeValue(current * 1000), timescale: 1000))
        }
        statePlay = .play
    }
    
}

extension PopupPlayerViewController {
    private func setupUI(){
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.view.addSubview(viewContainer)
        viewContainer.snp.makeConstraints({
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.8)
//            $0.height.equalTo(viewContainer.snp.width).multipliedBy(0.6)
        })
        viewContainer.backgroundColor = .white
        viewContainer.layer.cornerRadius = 4
        
        viewContainer.addSubview(lbName)
        lbName.snp.makeConstraints({
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.8)
        })
        lbName.textAlignment = .center
        
        viewContainer.addSubview(slide)
        slide.snp.makeConstraints({
            $0.top.equalTo(lbName.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.7)
        })
        slide.addTarget(self, action: #selector(self.seek), for: .valueChanged)
        viewContainer.addSubview(lbTime)
        lbTime.snp.makeConstraints({
            $0.leading.equalTo(slide)
            $0.top.equalTo(slide.snp.bottom).offset(8)
        })
        viewContainer.addSubview(lbTotalTime)
        lbTotalTime.snp.makeConstraints({
            $0.centerY.equalTo(lbTime)
            $0.leading.equalTo(lbTime.snp.trailing).offset(2)
        })
        
        viewContainer.addSubview(btnPlay)
        btnPlay.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.top.equalTo(lbTime.snp.bottom).offset(32)
            $0.size.equalTo(36)
            $0.bottom.equalToSuperview().offset(-24)
        })
        btnPlay.setImage(UIImage(named: "ic_play")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnPlay.imageView?.tintColor = UIColor.gray.withAlphaComponent(0.8)
        btnPlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.playPauseAudio)))
        
    }
}
