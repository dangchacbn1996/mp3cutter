////
////  ViewController.swift
////  Audience
////
////  Created by 이요한 on 2019/11/20.
////  Copyright © 2019 yo. All rights reserved.
////
//
//import UIKit
//import AVKit
//import MediaPlayer
//import fluid_slider
//
//class PlayViewController: UIViewController {
//
//  // MARK: - Oulet
//
//  @IBOutlet var coverImage: UIImageView!
//  @IBOutlet var titleLabel: UILabel!
//  @IBOutlet var artistLabel: UILabel!
//  @IBOutlet var coverOuterView: UIView!
//
//  @IBOutlet var defaultSlider: UISlider!
//  @IBOutlet var timeCurrentLabel: UILabel!
//  @IBOutlet var timeRemainingLabel: UILabel!
//  @IBOutlet var volumeView: UIView!
//
//  @IBOutlet var playButton: UIButton!
//  @IBOutlet var previousButton: UIButton!
//  @IBOutlet var nextButton: UIButton!
//
//  // MARK: - Variable
//  var progressTimer: Timer!
//  var fileManager = FileManager.default
//
//  var listVC: ListViewController?
//  var slider: Slider!
//
//  // MARK: - Cycle
//  override func viewDidLoad() {
//    super.viewDidLoad()
//
//    listVC = self.tabBarController?.viewControllers![1] as? ListViewController
//
//    coverImage.image = #imageLiteral(resourceName: "icon")
//    titleLabel.text = "Welcome"
//    artistLabel.text = "Audience"
//
//    setFluidSlider()
//    setCoverImage()
//    setVolumeSlder()
//    setDefalutSlide()
//
//  }
//
//  override func viewWillAppear(_ animated: Bool) {
//
//    loadTimeData()
//
//  }
//
//  // MARK: - Action
//  @IBAction func tapPlaybutton(_ sender: Any) {
//
////    if listVC!.choiceMusic && listVC!.nowPlaying {
////
////      listVC!.playButton.setBackgroundImage(UIImage(systemName: "play.fill"),
////                                    for: .normal)
////      listVC?.musicPlayer?.pause()
////      listVC!.nowPlaying = false
////      listVC?.setNotPlayingViewAnimation()
////
////
////      playButton.setBackgroundImage(UIImage(systemName: "play.circle.fill"),
////      for: .normal)
////
////    } else {
////
////
////      guard listVC!.choiceMusic else {return}
////
////      listVC?.musicPlayer?.play()
////      listVC!.playButton.setBackgroundImage(UIImage(systemName: "pause.fill"),
////                                    for: .normal)
////      listVC?.setNowPlayingAnimation()
////
////      playButton.setBackgroundImage(UIImage(systemName: "pause.circle.fill"),
////      for: .normal)
////
////      if let name = listVC?.musicName {
////        listVC?.playViewLabel.text = name
////      }
////    }
//  }
//
//  @IBAction func tapFirstTimePreviousButton(_ sender: Any) {
//    if let second = UserDefaultManager.getBigIconJumpValue() {
//      listVC?.musicPlayer?.currentTime = (listVC?.musicPlayer!.currentTime)! - TimeInterval(second)
//    } else {
//      listVC?.musicPlayer?.currentTime = (listVC?.musicPlayer!.currentTime)! - 5
//    }
//  }
//
//  @IBAction func tapSecondTimePreviousButton(_ sender: Any) {
//    if let second = UserDefaultManager.getSmallIconJumpValue() {
//        listVC?.musicPlayer?.currentTime = (listVC?.musicPlayer!.currentTime)! - TimeInterval(second)
//      } else {
//        listVC?.musicPlayer?.currentTime = (listVC?.musicPlayer!.currentTime)! - 10
//      }
//    }
//
//
//  @IBAction func tapFirstTimeNextButton(_ sender: Any) {
//    if let second = UserDefaultManager.getBigIconJumpValue() {
//      listVC?.musicPlayer?.currentTime = (listVC?.musicPlayer!.currentTime)! + TimeInterval(second)
//    } else {
//      listVC?.musicPlayer?.currentTime = (listVC?.musicPlayer!.currentTime)! + 5
//    }
//  }
//
//  @IBAction func tapSecondTimeNextButton(_ sender: Any) {
//     if let second = UserDefaultManager.getSmallIconJumpValue() {
//         listVC?.musicPlayer?.currentTime = (listVC?.musicPlayer!.currentTime)! + TimeInterval(second)
//       } else {
//         listVC?.musicPlayer?.currentTime = (listVC?.musicPlayer!.currentTime)! + 10
//    }
//  }
//
//  @IBAction func tapPreviousButton(_ sender: Any) {
////    guard listVC!.choiceMusic else {return}
////
////
////    if listVC?.selectedRow! == 0 {
////      listVC?.selectedRow = listVC?.musicInfo.count
////    }
////    guard  (listVC?.selectedRow!)! <  (listVC?.musicInfo.count)! + 1 else {return}
////
////
////    listVC?.selectedRow =  (listVC?.selectedRow!)! - 1
////    listVC?.listTableView.selectRow(at: IndexPath(row:  (listVC?.selectedRow!)!, section: 0),
////                            animated: true,
////                            scrollPosition: .top)
////
////
////    let documentsDir =  listVC?.fileManager.urls(for: .documentDirectory,
////                                        in: .userDomainMask)
////
////    let nextMusicFile =  listVC?.musicInfo[ (listVC?.selectedRow!)!]
////    let nextMusicName =  listVC?.musicInfo[ (listVC?.selectedRow!)!].musicName
////    let nextMusicCover =  listVC?.musicInfo[ (listVC?.selectedRow!)!].cover
////    UserDefaultManager.saveLastPlayMusic(list: nextMusicName!)
////
////    listVC?.toPlayView(nextMusicFile!)
////
////    if let documentPath: URL = documentsDir?.first {
////      let nextMusicPath = documentPath.appendingPathComponent(nextMusicName!)
////
////       listVC?.nextMusicURL = nextMusicPath
////
////      if  listVC?.nowPlaying == true {
////
////        listVC?.playMusic(url: (listVC?.nextMusicURL!)!)
////
////         listVC?.setNowPlayingAnimation()
////         listVC?.playViewLabel.text = nextMusicName
////        listVC?.playViewCoverImage.image = nextMusicCover
////
////      } else {
////
////         listVC?.musicName = nextMusicName
////         listVC?.playViewCoverImage.image = nextMusicCover
////
////         listVC?.playMusic(url: (listVC?.nextMusicURL!)!)
////         listVC?.musicPlayer?.stop()
////        //        playButton.setBackgroundImage(UIImage(systemName: "pause.fill"),for: .normal)
////      }
////
////    }
//
//
//  }
//
//  @IBAction func tapNextButton(_ sender: Any) {
//
////    guard listVC!.choiceMusic else {return}
////
////    if listVC?.selectedRow! == (listVC?.musicInfo.count)! - 1 {
////       listVC?.selectedRow = -1
////    }
////    guard  (listVC?.selectedRow!)! <  (listVC?.musicInfo.count)! - 1 else {return} // 마지막 리스트 일 때
////
////
////    listVC?.selectedRow =  (listVC?.selectedRow!)! + 1
////    listVC?.listTableView.selectRow(at: IndexPath(row:  (listVC?.selectedRow!)!, section: 0),
////                            animated: true,
////                            scrollPosition: .top)
////
////
////    let documentsDir =  listVC?.fileManager.urls(for: .documentDirectory,
////                                        in: .userDomainMask)
////
////    let nextMusicFile =  listVC?.musicInfo[ (listVC?.selectedRow!)!]
////    let nextMusicName =  listVC?.musicInfo[ (listVC?.selectedRow!)!].musicName
////    let nextMusicCover =  listVC?.musicInfo[ (listVC?.selectedRow!)!].cover
////    UserDefaultManager.saveLastPlayMusic(list: nextMusicName!)
////
////    listVC?.toPlayView(nextMusicFile!)
////
////    if let documentPath: URL = documentsDir?.first {
////      let nextMusicPath = documentPath.appendingPathComponent(nextMusicName!)
////
////       listVC?.nextMusicURL = nextMusicPath
////
////      if  listVC?.nowPlaying == true {
////
////        listVC?.playMusic(url: (listVC?.nextMusicURL!)!)
////
////         listVC?.setNowPlayingAnimation()
////         listVC?.playViewLabel.text = nextMusicName
////        listVC?.playViewCoverImage.image = nextMusicCover
////
////      } else {
////
////         listVC?.musicName = nextMusicName
////         listVC?.playViewCoverImage.image = nextMusicCover
////
////         listVC?.playMusic(url: (listVC?.nextMusicURL!)!)
////         listVC?.musicPlayer?.stop()
////        //        playButton.setBackgroundImage(UIImage(systemName: "pause.fill"),for: .normal)
////      }
////
////    }
//  }
//
//  // MARK: - func
//
//  func timeSelector(type: String) -> Selector {
//    if type == "current" {
//      return #selector(PlayViewController.updateCurrentTime)
//    } else if type == "remaining" {
//      return  #selector(PlayViewController.updateRemainingTime)
//    } else if type == "progress" {
//      return  #selector(PlayViewController.updateProgressTime)
//    }
//    return #selector(PlayViewController.updateCurrentTime)
//  }
//
//
//  func loadTimeData() {
//
//    if let player = listVC?.musicPlayer {
//      if player.isPlaying {
//        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timeSelector(type: "current"), userInfo: nil, repeats: true)
//        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timeSelector(type: "remaining"), userInfo: nil, repeats: true)
//        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timeSelector(type: "progress"), userInfo: nil, repeats: true)
//      }
//    }
//  }
//
//  func setCoverImage() {
//    coverOuterView.layer.cornerRadius = 20
//    coverOuterView.layer.shadowOffset = CGSize(width: 0.0, height: 8)
//    coverOuterView.layer.shadowRadius = 10
//    coverOuterView.layer.shadowOpacity = 0.4
//
//    coverImage.layer.cornerRadius = 20
//    coverImage.clipsToBounds = true
//  }
//
//  static func convertTimeInterval(_ time: TimeInterval) -> String {
//    let min = Int(time/60)
//    let sec = Int(time.truncatingRemainder(dividingBy: 60))
//    let strTime = String(format: "%02d:%02d", min, sec)
//    return strTime
//  }
//
//  func setVolumeSlder() {
//
//    let volumeBar = MPVolumeView(frame: volumeView.bounds)
//    volumeView.addSubview(volumeBar)
//    volumeView.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
//  }
//
//
//
//  func setFluidSlider() {
//
//    let sliderFrame = CGRect(x: 50, y: view.bounds.height * 0.58, width:  view.bounds.width * 0.74, height: 10)
//    slider = Slider(frame: sliderFrame)
//    slider.sizeToFit()
//    view.addSubview(slider)
//
//    let labelTextAttributes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .medium), .foregroundColor: UIColor.white]
//
//    slider.fraction = 0
//
//    slider.setMinimumLabelAttributedText(NSAttributedString(string: "", attributes: labelTextAttributes))
//    slider.setMaximumLabelAttributedText(NSAttributedString(string: "", attributes: labelTextAttributes))
//
//    slider.shadowOffset = CGSize(width: 0, height: 10)
//    slider.shadowBlur = 5
//    slider.shadowColor = UIColor(white: 0, alpha: 0.1)
//    slider.contentViewColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
//      //UIColor(red: 78/255.0, green: 77/255.0, blue: 224/255.0, alpha: 1)
//    slider.valueViewColor = .white
//    slider.isHidden = true
//
//    slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
//
//  }
//
//  func setDefalutSlide() {
//    defaultSlider.value = 0
//    defaultSlider.addTarget(self, action: #selector(sliderDefaultValueChanged), for: .valueChanged)
//  }
//
//  func setLastMusicInfo() {
//
////    let documentsDir = fileManager.urls(for: .documentDirectory,
////                                        in: .userDomainMask)[0].path
////    fileManager.changeCurrentDirectoryPath(documentsDir)
////
////    var image: UIImage!
////    var artistString: String!
////    var musicName: String!
////
////    if let list = UserDefaultManager.getMusicList() {
////      for item in list {
////        musicName = item
////
////
////        do {
////          let items = try fileManager.contentsOfDirectory(atPath: documentsDir)
////
////          for name in items {
////            if musicName == name {
////
////              let url = URL(fileURLWithPath: name)
////              let asset = AVAsset(url: url) as AVAsset
////
////              let meta = asset.commonMetadata.filter
////              { $0.commonKey?.rawValue == "artwork"}
////
////              if meta.count > 0 {
////                let imageData = meta[0].value
////                image = UIImage(data: imageData as! Data)
////              } else {
////                image = UIImage(named: "noImage")
////              }
////
////              let metaArtist = asset.commonMetadata.filter
////              { $0.commonKey?.rawValue == "artist"}
////
////              if !metaArtist.isEmpty {
////                artistString = metaArtist[0].value as? String
////              } else {
////                artistString = "작자미상"
////              }
////
////              listVC?.musicInfo.append(MusicData(cover: image,
////                                                 title: musicName,
////                                                 artist: artistString,
////                                                 musicName: musicName))
////            }
////          }
////
////        } catch {
////          print("not Found item")
////        }
////
////      }
////    }
////
////
////    if let lastMusic = UserDefaultManager.getLastPlayMusic() {
////      let last = listVC?.musicInfo.filter { $0.musicName == lastMusic }
////      let info = last?.first
////
////      coverImage.image = info?.cover
////      titleLabel.text = info?.title
////      artistLabel.text = info?.artist
////
////      if let path: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
////        let musicURL = path.appendingPathComponent(lastMusic)
////        listVC?.playMusic(url: musicURL)
////      }
////    }
//  }
//
//
//
//
//
//  // MARK: - Selector
//
//  @objc func updateCurrentTime() {
//    timeCurrentLabel.text = PlayViewController.convertTimeInterval((listVC?.musicPlayer!.currentTime)!)
//  }
//
//  @objc func updateRemainingTime() {
//    let duration = Int((listVC?.musicPlayer!.duration)!)
//    let curretTime = Int((listVC?.musicPlayer!.currentTime)!)
//    let ramainingTime = TimeInterval(duration - curretTime)
//
//    timeRemainingLabel.text = "-" + PlayViewController.convertTimeInterval(ramainingTime)
//  }
//
//  @objc func updateProgressTime()  {
//
//    if let slider = slider {
//      let currenTime = CGFloat((listVC?.musicPlayer!.currentTime)!)
//      let duration = CGFloat((listVC?.musicPlayer!.duration)!)
//      slider.fraction = currenTime/duration
//    }
//
//    if !(defaultSlider.isHidden) {
//      if let player = listVC?.musicPlayer {
//        let currenTime = Float((player.currentTime))
//        let duration = Float((player.duration))
//
//        defaultSlider.value = currenTime/duration
//      }
//    }
//
//  }
//
//  @objc func sliderValueChanged() {
//    if let player = listVC?.musicPlayer {
//      let duration = CGFloat((player.duration))
//      let progress = TimeInterval(duration * slider.fraction  )
//      listVC?.musicPlayer?.currentTime = progress
//    }
//  }
//
//  @objc func sliderDefaultValueChanged() {
//     if let player = listVC?.musicPlayer {
//       let duration = CGFloat((player.duration))
//      let progress = TimeInterval(duration * CGFloat(defaultSlider.value))
//       listVC?.musicPlayer?.currentTime = progress
//     }
//   }
//
//
//
//}
//
