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
    private let lbName = UILabel(text: "", font: UIFont.systemFont(ofSize: 14, weight: .semibold), color: UIColor.black.withAlphaComponent(0.8))
    private let lbStart = UILabel(text: "00:00:00", font: UIFont.systemFont(ofSize: 14, weight: .semibold), color: UIColor.black.withAlphaComponent(0.8))
    private let lbEnd = UILabel(text: "00:00:00", font: UIFont.systemFont(ofSize: 14, weight: .semibold), color: UIColor.black.withAlphaComponent(0.8))
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
    private let btnNext = UIButton()
    private let btnRewind = UIButton()
    private var endPoint = 0
    private var urlAsset: URL = URL(fileURLWithPath: "")
    private var ratioWidth = 3
    private var tagSelected : UIView = UIView() {
        didSet {
            updateSeekButton()
            tagStart.subviews.first?.transform = CGAffineTransform(scaleX: tagSelected == tagStart ? 5 : 1, y: 1)
            if let tag = tagStart.subviews.last as? UIImageView {
                tag.tintColor = tagSelected == tagStart ? actType.color : UIColor.gray.withAlphaComponent(0.8)
            }
            tagEnd.subviews.first?.transform = CGAffineTransform(scaleX: tagSelected == tagEnd ? 5 : 1, y: 1)
            if let tag = tagEnd.subviews.last as? UIImageView {
                tag.tintColor = tagSelected == tagEnd ? actType.color : UIColor.gray.withAlphaComponent(0.8)
            }
        }
    }
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
                if player.currentItem != nil {
                    player.seek(to: convertPointToTime(startPoint) )
                } else {
                    player.seek(to: CMTime(seconds: 0, preferredTimescale: 0))
                }
                player.pause()
                btnPlay.setImage(UIImage(named: "ic_stop")?.withRenderingMode(.alwaysTemplate), for: .normal)
                break
            default:
                break
            }
        }
    }
    
    private var player = AVPlayer()
    
    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        self.urlAsset = url
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            self.waveform.audioURL = urlAsset
            self.waveform.delegate = self
            self.waveform.progressColor = ActionType.actCut.color
            self.waveform.loadingInProgress = true
            self.waveform.wavesColor = UIColor.gray.withAlphaComponent(0.4)
            self.waveform.doesAllowScrubbing = false
            self.waveform.doesAllowStretch = false
            self.waveform.doesAllowScroll = false
            player = AVPlayer(url: urlAsset)
            lbName.text = urlAsset.lastPathComponent
            Loading.sharedInstance.show(in: self.view, deadline: 20.0)
            self.player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.02, preferredTimescale: 1000), queue: DispatchQueue.main, using: { (time) in
                self.updateWaveForm()
            })
//            if let url = localMusic[indexPath.row].url {
                let asset = AVAsset(url: urlAsset)
//                sub += " \(Int(asset.duration.seconds) / 60):\(Int(asset.duration.seconds.truncatingRemainder(dividingBy: 60)))"
            lbEnd.text = NSString(format: "%02d:%02d", Int(asset.duration.seconds/60), Int(asset.duration.seconds.truncatingRemainder(dividingBy: 60))) as String
//            }
        } catch {
            print(error)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
        player.replaceCurrentItem(with: nil)
    }
    
    private func convertPointToTime(_ value: Int) -> (CMTime) {
        if let current = player.currentItem {
            let duration = current.duration.seconds
            let totalWave = self.waveform.totalSamples
            let currentTime = Double(value) * duration / Double(totalWave)
            return CMTime(value: CMTimeValue(currentTime * 1000), timescale: 1000)
        }
        return CMTime(seconds: 0, preferredTimescale: 0)
    }

private func updateWaveForm(){
    if self.player.currentItem?.status == .readyToPlay {
            let currentTime = CMTimeGetSeconds(self.player.currentTime())
            let totalTime = CMTimeGetSeconds(self.player.currentItem?.duration ?? CMTime(seconds: 1, preferredTimescale: 1))
            let highlight = Int((currentTime * Double(self.waveform.totalSamples)) / totalTime)
            if highlight < startPoint {
                self.waveform.highlightedSamples = (self.startPoint..<self.startPoint + 1)
            } else {
                if highlight > self.endPoint {
                    self.playerState = .stop
                    self.waveform.highlightedSamples = (self.startPoint..<self.endPoint)
                } else {
                    self.waveform.highlightedSamples = (self.startPoint..<highlight)
                }
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
            playerState = .play
            break
        default:
            break
        }
    }
    
    @objc func actGoBack(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func selectStart(){
        tagSelected = tagStart
    }
    
    @objc func selectEnd(){
        tagSelected = tagEnd
    }
    
    @objc func actNextPage() {
        panTo(draggedObject: tagSelected, translation: vScrollable.contentSize.width / 8)
        seekTo(draggedObject: tagSelected)
    }
    
    @objc func actRewind() {
        panTo(draggedObject: tagSelected, translation: -vScrollable.contentSize.width / 8)
        seekTo(draggedObject: tagSelected)
    }
    
    @objc func actPanStart(_ gesture: UIPanGestureRecognizer) {
//        let pos = gesture.translation(in: vScrollable)
        guard let draggedObject = gesture.view else { return }

        if gesture.state == .began || gesture.state == .changed {
            let translation = gesture.translation(in: vScrollable)
            panTo(draggedObject: draggedObject, translation: translation.x)
            gesture.setTranslation(CGPoint.zero, in: self.view)
        } else {
            seekTo(draggedObject: draggedObject)
        }
    }
    
    private func panTo(draggedObject: UIView, translation: CGFloat){
        if draggedObject.tag == 0 {
            tagSelected = tagStart
        } else {
            tagSelected = tagEnd
        }
        if (draggedObject.center.x + translation) < 0 {
            draggedObject.center = CGPoint(x: 0, y: draggedObject.center.y)
            return
        } else if (draggedObject.center.x + translation) > vScrollable.contentSize.width {
            draggedObject.center = CGPoint(x: vScrollable.contentSize.width, y: draggedObject.center.y)
            return
        } else {
            let duration = player.currentItem?.duration.seconds ?? Double(vScrollable.contentSize.width * 52 / 6)
            let space5s = (5 / duration) * Double(vScrollable.contentSize.width)
            if draggedObject.tag == 0 {
                if (draggedObject.center.x + translation) > tagEnd.center.x - CGFloat(space5s) {
                    Toast.shared.makeToast(.error, string: "File cut không dưới 5s", inView: self.view, time: 2.0)
                    draggedObject.center = CGPoint(x: tagEnd.center.x - CGFloat(space5s), y: draggedObject.center.y)
                    return
                }
            }
            if draggedObject.tag == 1 {
                if (draggedObject.center.x + translation) < tagStart.center.x + CGFloat(space5s) {
                    Toast.shared.makeToast(.error, string: "File cut không dưới 5s", inView: self.view, time: 2.0)
                    draggedObject.center = CGPoint(x: tagStart.center.x + CGFloat(space5s), y: draggedObject.center.y)
                    return
                }
            }
            draggedObject.center = CGPoint(x: draggedObject.center.x + translation, y: draggedObject.center.y)
        }
    }
        
    private func seekTo(draggedObject: UIView){
        if draggedObject.tag == 0 {
            draggedObject.snp.remakeConstraints({
                $0.centerY.height.equalToSuperview()
                $0.centerX.equalTo(draggedObject.superview!.snp.leading).offset(draggedObject.center.x)
                $0.width.equalTo(56)
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
                $0.width.equalTo(56)
            })
            self.endPoint = Int(draggedObject.center.x * CGFloat(waveform.totalSamples) / vScrollable.contentSize.width)
            updateWaveForm()
        }
        updateSeekButton()
    }
    
    private func updateSeekButton(){
        if tagSelected == tagStart && tagStart.center.x == 0 {
            btnRewind.alpha = 0.5
            btnNext.alpha = 1
        } else if tagSelected == tagEnd && tagEnd.center.x == vScrollable.contentSize.width {
            btnRewind.alpha = 1
            btnNext.alpha = 0.5
        } else {
            btnRewind.alpha = 1
            btnNext.alpha = 1
        }
    }
    
    @objc func actReset(){
        playerState = .pause
        panTo(draggedObject: tagStart, translation: -self.vScrollable.contentSize.width)
        seekTo(draggedObject: tagStart)
        
        panTo(draggedObject: tagEnd, translation: self.vScrollable.contentSize.width)
        seekTo(draggedObject: tagEnd)
    }
    
    @objc func actionCut() {
        if let asset = self.player.currentItem?.asset {
            var name = urlAsset.lastPathComponent
            let last = name.lastIndex(of: ".") ?? name.endIndex
            name.removeSubrange(last..<name.endIndex)
            var vc : PopupFinalViewController!
            vc = PopupFinalViewController(name: name, url: [urlAsset], doAction: {(media, url) -> (Void) in
                if let currentItem = self.player.currentItem {
                    let start = Double(self.startPoint) / Double(self.waveform.totalSamples) * currentItem.duration.seconds
                    let ending = Double(self.endPoint) / Double(self.waveform.totalSamples) * currentItem.duration.seconds
                    Loading.sharedInstance.show(in: vc.view)
                    MediaPascer.shared.audioURLParse(info: media, newURL: url, asset: asset, starting: CMTime(value: CMTimeValue(start * 1000), timescale: 1000), ending: CMTime(value: CMTimeValue(ending * 1000), timescale: 1000), failed: { (error) in
                        Loading.sharedInstance.dismiss()
                        Toast.shared.makeToast(.error, string: error, inView: vc.view, time: 2.0)
                    }) { () in
                        Loading.sharedInstance.dismiss()
                        Toast.shared.makeToast(.success, string: "Tạo file thành công!", inView: vc.view, time: 2.0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            vc.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            })
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        } else {
            Toast.shared.makeToast(.error, string: "Không thể load được file âm thanh", inView: self.view, time: 2.0)
        }
    }
}

extension ActionCutViewController: FDWaveformViewDelegate {
    
    /// Rendering will begin
    func waveformViewWillRender(_ waveformView: FDWaveformView) {
        print("waveformViewWillRender")
    }

    /// Rendering did complete
    func waveformViewDidRender(_ waveformView: FDWaveformView){
        print("waveformViewDidRender")
        Loading.sharedInstance.dismiss()
        endPoint = waveform.totalSamples
        playerState = .play
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
        self.title = actType.text
        
//        if actType.text == ActionType.actVideo.text {
//            let playerLayer = AVPlayerLayer(player: self.player)
//            playerLayer.frame = self.view.bounds
//            self.view.layer.addSublayer(playerLayer)
//        }
        self.view.addSubview(vScrollable)
        vScrollable.snp.makeConstraints({
            $0.centerX.top.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.6)
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
            $0.width.equalTo(56)
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
        lineStart.backgroundColor = UIColor(hexString: "42A5F5")
        
        let icTag = UIImageView(image: UIImage(named: "ic_tag")?.withRenderingMode(.alwaysTemplate))
        icTag.tintColor = actType.color
        icTag.transform = CGAffineTransform(rotationAngle: .pi)
        tagStart.addSubview(icTag)
        icTag.snp.makeConstraints({
//            $0.bottom.equalToSuperview()
            $0.width.equalTo(24)
            $0.leading.equalTo(lineStart.snp.centerX)
            $0.centerY.equalTo(lineStart.snp.bottom)
        })
        icTag.contentMode = .scaleAspectFit
        
        tagStart.isUserInteractionEnabled = true
        tagStart.tag = 0
        tagStart.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.actPanStart(_:))))
        tagStart.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.selectStart)))
        
        //TagEnd
        let lineEnd = UIView()
        vScrollable.addSubview(layerEnd)
        layerEnd.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
        
        vScrollable.addSubview(tagEnd)
        tagEnd.snp.makeConstraints({
            $0.width.equalTo(tagStart.snp.width)
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
        lineEnd.backgroundColor = UIColor(hexString: "0D47A1")
        
        let icTagEnd = UIImageView(image: UIImage(named: "ic_tag")?.withRenderingMode(.alwaysTemplate))
        icTagEnd.tintColor = actType.color
        tagEnd.addSubview(icTagEnd)
        icTagEnd.snp.makeConstraints({
//            $0.leading.equalToSuperview().offset(-4)
            $0.width.equalTo(icTag.snp.width)
            $0.trailing.equalTo(lineEnd.snp.centerX)
            $0.centerY.equalTo(lineEnd.snp.bottom)
        })
        icTagEnd.contentMode = .scaleAspectFit
        
        tagEnd.isUserInteractionEnabled = true
        tagEnd.tag = 1
        tagEnd.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.selectEnd)))
        tagEnd.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.actPanStart(_:))))
        
        tagSelected = tagStart
        
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
        
        let lbTitleSt = UILabel(text: "Playing: ", font: UIFont.systemFont(ofSize: 14, weight: .semibold), color: actType.color)
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
        
        self.view.addSubview(btnRewind)
        btnRewind.snp.makeConstraints({
            $0.centerY.size.equalTo(btnPlay)
            $0.trailing.equalTo(btnPlay.snp.leading).offset(-24)
        })
        btnRewind.setImage(UIImage(named: "ic_skip")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnRewind.imageView?.tintColor = UIColor.gray.withAlphaComponent(0.8)
        btnRewind.transform = CGAffineTransform(rotationAngle: .pi)
        btnRewind.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actRewind)))
        
        self.view.addSubview(btnNext)
        btnNext.snp.makeConstraints({
            $0.centerY.size.equalTo(btnPlay)
            $0.leading.equalTo(btnPlay.snp.trailing).offset(24)
        })
        btnNext.setImage(UIImage(named: "ic_skip")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnNext.imageView?.tintColor = UIColor.gray.withAlphaComponent(0.8)
        btnNext.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actNextPage)))
        
        let btnBack = UIButton()
        btnBack.setTitle("TRỞ LẠI", for: .normal)
        btnBack.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btnBack.setTitleColor(ActionType.actCut.color, for: .normal)
        btnBack.layer.cornerRadius = 4
        btnBack.layer.borderColor = ActionType.actCut.color.cgColor
        btnBack.layer.borderWidth = 1
        btnBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actGoBack)))
        
        let btnReset = UIButton()
        btnReset.setTitle("ĐẶT LẠI", for: .normal)
        btnReset.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btnReset.setTitleColor(ActionType.actCut.color, for: .normal)
        btnReset.layer.cornerRadius = btnBack.layer.cornerRadius
        btnReset.layer.borderColor = btnBack.layer.borderColor
        btnReset.layer.borderWidth = 1
        btnReset.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actReset)))
        
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
