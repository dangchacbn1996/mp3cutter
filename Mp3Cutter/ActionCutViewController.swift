//
//  ActionCutViewController.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/14/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation
import FDWaveformView
import AudioUnit

enum PlayState : Int {
    case stop = 0
    case play = 1
    case pause = 2
}

class ActionCutViewController: UIViewController {
    private let scrollWave = UIScrollView()
    private let lbName = UILabel(text: "Song name", font: UIFont.systemFont(ofSize: 14, weight: .semibold), color: UIColor.black.withAlphaComponent(0.8))
    private let lbStart = UILabel(text: "00:00:0", font: UIFont.systemFont(ofSize: 14, weight: .semibold), color: UIColor.black.withAlphaComponent(0.8))
    private let lbEnd = UILabel(text: "00:21:00", font: UIFont.systemFont(ofSize: 14, weight: .semibold), color: UIColor.black.withAlphaComponent(0.8))
    private let layerSelected = UIView()
    private let waveform = FDWaveformView()
    private let actType = ActionType.actCut
    private let btnPlay = UIButton()
    private let tagStart = UIView()
    private let tagEnd = UIView()
    private let layerStart = UIView()
    private let layerEnd = UIView()
    private let vScrollable = UIScrollView()
    private var startPoint : Int = 0
    private var endPoint = 0
    private var ratioWidth = 3
    private var playerState: PlayState = .stop {
        didSet {
            switch self.playerState {
            case .pause:
                btnPlay.setImage(UIImage(named: "ic_play")?.withRenderingMode(.alwaysTemplate), for: .normal)
                player.pause()
                break
            case .play:
                btnPlay.setImage(UIImage(named: "ic_pause")?.withRenderingMode(.alwaysTemplate), for: .normal)
                player.play()
                break
            case .stop:
                btnPlay.setImage(UIImage(named: "ic_pause")?.withRenderingMode(.alwaysTemplate), for: .normal)
                break
            default:
                break
            }
        }
    }
    
    private var player = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let thisBundle = Bundle(for: type(of: self))
//        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("out.m4a")
        let url = thisBundle.url(forResource: "File 14", withExtension: "mp3")
//        print(url?.absoluteString)
//        self.waveform.audioURL = url
//        self.waveform.delegate = self
//        self.waveform.progressColor = ActionType.actCut.color
//        self.waveform.loadingInProgress = true
//        self.waveform.wavesColor = UIColor.gray.withAlphaComponent(0.4)
//        self.waveform.doesAllowScrubbing = false
//        self.waveform.doesAllowStretch = false
//        self.waveform.doesAllowScroll = false
//        if url != nil {
//            player = AVPlayer(url: url!)
//            self.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { (time) in
//                self.updateWaveForm()
//            })
//        }
//        playerState = .play
//        //        player.isMuted = true
//                player.play()
        
        let fileManager = FileManager.default
        do {
//            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
//            let url = documentDirectory.appendingPathComponent("out.m4a")
            self.waveform.audioURL = url
            self.waveform.delegate = self
            self.waveform.progressColor = ActionType.actCut.color
            self.waveform.loadingInProgress = true
            self.waveform.wavesColor = UIColor.gray.withAlphaComponent(0.4)
            self.waveform.doesAllowScrubbing = false
            self.waveform.doesAllowStretch = false
            self.waveform.doesAllowScroll = false
            //            do {
//            try player = AVPlayer(url: url!)
            if url != nil {
                player = AVPlayer(url: url!)
                self.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.02, preferredTimescale: 1000), queue: DispatchQueue.main, using: { (time) in
                    self.updateWaveForm()
                })
            }
//            playerState = .play
//            //        player.isMuted = true
//            player.play()
        } catch {
            print(error)
        }
    }
    
    func updateWaveForm(){
        if self.player.currentItem?.status == .readyToPlay {
            let currentTime = CMTimeGetSeconds(self.player.currentTime())
            let totalTime = CMTimeGetSeconds(self.player.currentItem?.duration ?? CMTime(seconds: 1, preferredTimescale: 1))
            let highlight = Int((currentTime * Double(self.waveform.totalSamples)) / totalTime)
            if highlight < startPoint {
                self.waveform.highlightedSamples = (self.startPoint..<self.startPoint + 1)
            } else {
                self.waveform.highlightedSamples = (self.startPoint..<highlight)
            }
            if highlight > endPoint {
                self.player.pause()
            }
            let secs = Int(currentTime)
            self.lbStart.text = NSString(format: "%02d:%02d", secs/60, secs%60) as String
            
        }
    }
    
    @objc func playPauseAudio(){
        switch playerState {
        case .play:
            playerState = .pause
            break
        case .pause:
            playerState = .play
            break
        case .stop:
            break
        default:
            break
        }
    }
    
    @objc func actPanStart(_ gesture: UIPanGestureRecognizer) {
//        let pos = gesture.translation(in: vScrollable)
        guard let draggedObject = gesture.view else { return }

        if gesture.state == .began || gesture.state == .changed {

            //2. Set The Translation & Move The View
            let translation = gesture.translation(in: vScrollable)
            print("XDrag: \(draggedObject.center.x)")
            print("XTran: \(translation.x)")
            print("-----------------------")
            draggedObject.center = CGPoint(x: draggedObject.center.x + translation.x, y: draggedObject.center.y)
            gesture.setTranslation(CGPoint.zero, in: self.view)
        } else {
            if draggedObject.tag == 0 {
                draggedObject.snp.remakeConstraints({
                    $0.centerY.height.equalToSuperview()
                    $0.centerX.equalTo(draggedObject.superview!.snp.leading).offset(draggedObject.center.x)
                    $0.width.equalTo(16)
                })
                if let second = player.currentItem?.duration.seconds {
                    let newTime = Int(draggedObject.center.x * CGFloat(second) / vScrollable.contentSize.width)
                    player.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
                    startPoint = Int(draggedObject.center.x * CGFloat(waveform.totalSamples) / vScrollable.contentSize.width)
                    updateWaveForm()
                }
            } else {
                draggedObject.snp.remakeConstraints({
                    $0.centerY.height.equalToSuperview()
                    $0.centerX.equalTo(draggedObject.superview!.snp.leading).offset(draggedObject.center.x)
                    $0.width.equalTo(16)
                })
                self.endPoint = Int(draggedObject.center.x * CGFloat(waveform.totalSamples) / vScrollable.contentSize.width)
                updateWaveForm()
            }
        }
    }
    
    @objc func actionCut() {
        let vc = PopupFinalViewController { (name, url, exportType, soundQuality, soundType) -> (Void) in
            if let currentItem = self.player.currentItem {
                let start = Double(self.startPoint) / Double(self.waveform.totalSamples) * currentItem.duration.seconds
                let ending = Double(self.endPoint) / Double(self.waveform.totalSamples) * currentItem.duration.seconds
                MediaPascer.shared.audioURLParse(url: url, asset: self.player.currentItem!.asset, newName: name, export: exportType, quality: soundQuality, type: soundType, starting: CMTime(value: CMTimeValue(start * 1000), timescale: 1000), ending: CMTime(value: CMTimeValue(ending * 1000), timescale: 1000), failed: { (error) in
                    print("error: \(error)")
                }) { () in
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
//                    print("Parse: \(code) - \(url)")
                    print("-----------------------------")
                }
            }
        }
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
//    private func actCutAudio(){
//        MediaPascer.shared.audioURLParse(starting: Int64(startPoint), export: , duration: Int64(endPoint - startPoint)) { (code, url) in
//            print("Parse: \(code) - \(url)")
//            print("-----------------------------")
//        }
//    }
    
//    @objc func cut(){
//        if let asset = player.currentItem?.asset {
//        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
//        exporter!.outputURL = soundFile1
//            exporter!.outputFileType = AVFileType.mp3
//        let duration = CMTimeGetSeconds(avAsset1.duration)
//        print(duration)
//        if (duration < 5.0) {
//            print("sound is not long enough")
//            return
//        }
//        // e.g. the first 30 seconds
//        let startTime = CMTimeMake(0, 1)
//        let stopTime = CMTimeMake(30,1)
//        let exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
//        print(exportTimeRange)
//        exporter!.timeRange = exportTimeRange
//        print(exporter!.timeRange)
//        }
//    }
}

extension ActionCutViewController: AVAudioPlayerDelegate {
    
}

extension ActionCutViewController: FDWaveformViewDelegate {
    
    /// Rendering will begin
    func waveformViewWillRender(_ waveformView: FDWaveformView) {
        print("waveformViewWillRender")
    }

    /// Rendering did complete
    func waveformViewDidRender(_ waveformView: FDWaveformView){
        print("waveformViewDidRender")
        if player.currentItem?.status == .readyToPlay {
            if let time = player.currentItem?.duration.seconds {
                let minus : Double = time / 60
                let second : Double = time.advanced(by: 60)
                lbEnd.text = "\(minus.rounded()):\(second)"
            }
        }
        endPoint = waveform.totalSamples
        playerState = .play
//        player.isMuted = true
        player.play()
    }

    /// An audio file will be loaded
    func waveformViewWillLoad(_ waveformView: FDWaveformView){
        print("waveformViewWillLoad")
    }

    /// An audio file was loaded
    func waveformViewDidLoad(_ waveformView: FDWaveformView){
        print("waveformViewDidLoad")
    }

    /// The panning gesture began
    func waveformDidBeginPanning(_ waveformView: FDWaveformView){
         print("waveformDidBeginPanning")
    }

    /// The panning gesture ended
    func waveformDidEndPanning(_ waveformView: FDWaveformView){
         print("waveformDidEndPanning")
    }

    /// The scrubbing gesture ended
    func waveformDidEndScrubbing(_ waveformView: FDWaveformView){
         print("waveformDidEndScrubbing")
    }
}

extension ActionCutViewController {
    func setupUI(){
        self.view.backgroundColor = .white
        
        self.view.addSubview(vScrollable)
        vScrollable.snp.makeConstraints({
            $0.centerX.top.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.4)
        })
        vScrollable.bounces = false
        vScrollable.addSubview(waveform)
        waveform.snp.makeConstraints({
            $0.top.leading.trailing.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(ratioWidth)
            $0.height.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview().offset(-24)
        })
        let lineStart = UIView()
        vScrollable.addSubview(layerStart)
        layerStart.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        
        vScrollable.addSubview(tagStart)
        tagStart.snp.makeConstraints({
            $0.width.equalTo(32)
            $0.top.bottom.equalToSuperview()
        })
        layerStart.snp.makeConstraints({
            $0.leading.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-24)
            $0.trailing.equalTo(tagStart.snp.centerX)
        })
        tagStart.center = CGPoint(x: 0, y: 0)
        tagStart.addSubview(lineStart)
        lineStart.snp.makeConstraints({
            $0.top.centerX.equalToSuperview()
            $0.width.equalTo(1)
            $0.bottom.equalToSuperview().offset(-24)
        })
        lineStart.backgroundColor = .blue
        
        let icTag = UIImageView(image: UIImage(named: "ic_tag")?.withRenderingMode(.alwaysTemplate))
        icTag.tintColor = actType.color
        icTag.transform = CGAffineTransform(rotationAngle: .pi * 1.5)
        tagStart.addSubview(icTag)
        icTag.snp.makeConstraints({
            $0.bottom.equalToSuperview()
            $0.centerX.equalTo(lineStart.snp.centerX)
            $0.top.equalTo(lineStart.snp.bottom)
        })
        icTag.contentMode = .scaleAspectFit
        
        tagStart.isUserInteractionEnabled = true
        tagStart.tag = 0
        tagStart.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.actPanStart(_:))))
        
        //TagEnd
        let lineEnd = UIView()
        vScrollable.addSubview(layerEnd)
        layerEnd.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        
        vScrollable.addSubview(tagEnd)
        tagEnd.snp.makeConstraints({
            $0.width.equalTo(32)
            $0.top.bottom.equalToSuperview()
        })
        layerEnd.snp.makeConstraints({
            $0.trailing.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-24)
            $0.leading.equalTo(tagEnd.snp.centerX)
        })
        tagEnd.center = CGPoint(x: 8, y: 0)
        tagEnd.addSubview(lineEnd)
        lineEnd.snp.makeConstraints({
            $0.centerX.top.equalToSuperview()
            $0.width.equalTo(1)
            $0.bottom.equalToSuperview().offset(-24)
        })
        lineEnd.backgroundColor = .blue
        
        let icTagEnd = UIImageView(image: UIImage(named: "ic_tag")?.withRenderingMode(.alwaysTemplate))
        icTagEnd.tintColor = actType.color
        icTagEnd.transform = CGAffineTransform(rotationAngle: .pi * 1.5)
        tagEnd.addSubview(icTagEnd)
        icTagEnd.snp.makeConstraints({
            $0.bottom.equalToSuperview()
            $0.centerX.equalTo(lineEnd.snp.centerX)
            $0.top.equalTo(lineEnd.snp.bottom)
        })
        icTagEnd.contentMode = .scaleAspectFit
        
        tagEnd.isUserInteractionEnabled = true
        tagEnd.tag = 1
        tagEnd.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.actPanStart(_:))))
        
        let vInfo = UIView()
        self.view.addSubview(vInfo)
        vInfo.snp.makeConstraints({
            $0.top.equalTo(vScrollable.snp.bottom).offset(8)
            $0.centerX.width.equalToSuperview()
        })
        vInfo.addSubview(lbName)
        lbName.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().offset(-32)
            $0.top.equalToSuperview().offset(8)
        })
        lbName.numberOfLines = 0
        
        let lbTitleSt = UILabel(text: "Bắt đầu: ", font: UIFont.systemFont(ofSize: 14, weight: .semibold), color: actType.color)
        let lbTitleEnd = UILabel(text: "Kết thúc: ", font: UIFont.systemFont(ofSize: 14, weight: .semibold), color: actType.color)
        vInfo.addSubview(lbTitleSt)
        lbTitleSt.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(lbName.snp.bottom).offset(8)
            $0.bottom.equalToSuperview()
        })
        vInfo.addSubview(lbStart)
        lbStart.snp.makeConstraints({
            $0.centerY.equalTo(lbTitleSt)
            $0.leading.equalTo(lbTitleSt.snp.trailing).offset(4)
        })
        
        vInfo.addSubview(lbEnd)
        lbEnd.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(lbTitleSt)
        })
        
        vInfo.addSubview(lbTitleEnd)
        lbTitleEnd.snp.makeConstraints({
            $0.centerY.equalTo(lbEnd)
            $0.trailing.equalTo(lbEnd.snp.leading).offset(-4)
        })
        
        self.view.addSubview(btnPlay)
        btnPlay.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.top.equalTo(vInfo.snp.bottom).offset(24)
            $0.size.equalTo(52)
        })
        btnPlay.setImage(UIImage(named: "ic_play")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnPlay.imageView?.tintColor = UIColor.gray.withAlphaComponent(0.8)
        btnPlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.playPauseAudio)))
        
        let btnBack = UIButton()
        btnBack.setTitle("TRỞ LẠI", for: .normal)
        btnBack.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btnBack.setTitleColor(ActionType.actCut.color, for: .normal)
        btnBack.layer.cornerRadius = 4
        btnBack.layer.borderColor = ActionType.actCut.color.cgColor
        btnBack.layer.borderWidth = 1
        
        let btnReset = UIButton()
        btnReset.setTitle("ĐẶT LẠI", for: .normal)
        btnReset.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btnReset.setTitleColor(ActionType.actCut.color, for: .normal)
        btnReset.layer.cornerRadius = btnBack.layer.cornerRadius
        btnReset.layer.borderColor = btnBack.layer.borderColor
        btnReset.layer.borderWidth = 1
        
        let btnCut = UIButton()
        btnCut.setTitle("CẮT", for: .normal)
        btnCut.setTitleColor(.white, for: .normal)
        btnCut.titleLabel?.font = btnBack.titleLabel?.font
        btnCut.layer.cornerRadius = 4
        btnCut.backgroundColor = ActionType.actCut.color
        
        let stackAction = UIStackView()
        stackAction.alignment = .fill
        stackAction.distribution = .equalCentering
        stackAction.axis = .horizontal
        
        self.view.addSubview(stackAction)
        stackAction.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().offset(-32)
            $0.bottom.equalTo(self.view.layoutMarginsGuide.snp.bottom).offset(-16)
            $0.height.equalTo(36)
        })
        stackAction.addArrangedSubview(btnBack)
        stackAction.addArrangedSubview(btnReset)
        stackAction.addArrangedSubview(btnCut)
        btnBack.snp.makeConstraints({
            $0.width.equalToSuperview().multipliedBy(0.3)
        })
        btnReset.snp.makeConstraints({
            $0.width.equalToSuperview().multipliedBy(0.3)
        })
        btnCut.snp.makeConstraints({
            $0.width.equalToSuperview().multipliedBy(0.3)
        })
        btnCut.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actionCut)))
    }
}

extension UILabel {
    convenience init(text : String, font : UIFont, color : UIColor) {
        self.init(frame: CGRect.zero)
        self.textColor = color
        self.font = font
        self.text = text
    }
}
