//
//  ListViewController.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/11/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MediaPlayer
import AVFoundation

struct MusicData {
    
    var url : URL?
    var cover: UIImage?
    var title: String?
    var artist: String?
    var musicName: String?
    
    init(url: URL, cover: UIImage?, title: String?, artist: String?, musicName: String?) {
        self.url = url
        self.cover = cover
        self.title = title
        self.artist = artist
        self.musicName = musicName
    }
}

extension FileManager {
    func urls(for directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = true ) -> [URL]? {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try? contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }
}

class ListViewController: UIViewController {
    
    
    
    var musicData : [MPMediaItem] = []
    var localMusic : [MusicData] = []
    private let lbTitle = UILabel()
    private let viewSearch = UIView()
    private let vNavigation = UIView()
    private let tfSearch = UITextField()
    private let tableView = UITableView()
    private let vAction = UIView()
    private let btnAction = UIButton()
    private let stackMain = UIStackView()
    private var multiChoise = false
    var actType = ListType.cut
    var mainColor : UIColor? = UIColor.red.withAlphaComponent(0.5)
    
    convenience init(actionType: Int) {
        self.init()
        self.actType = ListType.init(rawValue: actionType) ?? ListType.cut
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMusics()
    }
    
    func loadMusics(){
        if let mediaItems = MPMediaQuery.songs().items {
            self.musicData = mediaItems
        }
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            self.localMusic = []
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            fileURLs.forEach({
                var title = $0.lastPathComponent
                if !title.contains("mp3") && !title.contains("m4a") && !title.contains("aiff") {
                    return
                }
                let playerItem = AVPlayerItem(url: $0)
                let metadataList = playerItem.asset.metadata
                var artist = ""
                for item in metadataList {
                    if let stringValue = item.value {
                        if let key = item.commonKey?.rawValue {
                            if key == "title" {
                                title = stringValue as? String ?? "Name"
                            }
                            if key  == "artist" {
                                artist = stringValue as? String ?? "Artist"
                            }
                        }
                    }
                }
                localMusic.append(MusicData(url: $0, cover: nil, title: title, artist: artist, musicName: nil))
            })
            
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        self.tableView.reloadData()
    }
}

/*
 @objc func
 */
extension ListViewController {
    @objc func actSearch(){
        self.view.endEditing(true)
    }
    
    @objc func goBack(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension ListViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? musicData.count : localMusic.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = UITableViewCell()
        cell.textLabel?.text = section == 0 ? "Nhạc itunes" : "Bộ sưu tập"
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if localMusic.count > 0 {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ItemTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.id, for: indexPath) as! ItemTableViewCell
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            cell.bind(title: musicData[indexPath.row].title ?? "Name", sub: musicData[indexPath.row].artist ?? "Artist", checkColor: multiChoise ? mainColor : .clear, showCheck: true)
        } else {
            cell.bind(title: localMusic[indexPath.row].title ?? "Name", sub: localMusic[indexPath.row].artist ?? "Artist", checkColor: multiChoise ? mainColor : .clear, showCheck: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if multiChoise {
            (tableView.cellForRow(at: indexPath) as? ItemTableViewCell)?.checkOn()
        } else {
            switch actType {
            case .cut:
                var url : URL? = nil
                url = indexPath.section == 0 ? (musicData[indexPath.row].assetURL) : localMusic[indexPath.row].url
                if url == nil {
                    return
                }
                let vc = ActionCutViewController(url: url!)
                let navi = UINavigationController(rootViewController: vc)
                navi.navigationBar.tintColor = .white
                navi.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .bold)]
                navi.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
                navi.navigationBar.barTintColor = ActionType.actCut.color
                navi.navigationBar.isTranslucent = false
                navi.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
                navi.modalPresentationStyle = .overCurrentContext
                let vButton = UIView()
                vButton.snp.makeConstraints({
                    $0.width.height.equalTo(navi.navigationBar.frame.height)
                })
                let btnBack = UIButton()
                vButton.addSubview(btnBack)
                btnBack.setImage(UIImage(named: "iconRemove"), for: .normal)
                btnBack.imageView?.contentMode = .scaleAspectFit
                btnBack.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
                btnBack.snp.makeConstraints({
                    $0.center.equalToSuperview()
                    $0.width.height.equalToSuperview().multipliedBy(0.7)
                })
                vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: vButton)
                self.present(navi, animated: true, completion: nil)
            default:
                break
            }
        }
    }
}

extension ListViewController {
    
    private func configType(){
        switch actType {
        case .cut:
            self.lbTitle.text = "Cắt âm thanh"
            vAction.isHidden = true
        case .merge:
            self.lbTitle.text = "Ghép âm thanh"
            vAction.isHidden = false
        case .convert:
            self.lbTitle.text = "Chuyển định dạng"
            vAction.isHidden = true
        case .video:
            self.lbTitle.text = "Cắt video"
            vAction.isHidden = true
        default:
            return
        }
    }
    
    private func setupUI(){
        self.view.backgroundColor = .white
        self.view.addSubview(viewSearch)
        viewSearch.snp.makeConstraints({
            $0.top.centerX.width.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(88)
        })
        viewSearch.backgroundColor = mainColor
        
        viewSearch.addSubview(vNavigation)
        vNavigation.snp.makeConstraints({
            $0.top.equalTo(self.view.layoutMarginsGuide.snp.top)
            $0.centerX.width.equalToSuperview()
            $0.bottom.equalTo(self.view.layoutMarginsGuide.snp.top).offset(32)
        })
        vNavigation.heightAnchor.constraint(equalToConstant: 32).isActive = true
        let btnBack = UIButton()
        vNavigation.addSubview(btnBack)
        btnBack.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.8)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(btnBack.snp.width)
        })
        btnBack.setImage(UIImage(named: "ic_cut")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnBack.imageView?.tintColor = .white
        btnBack.imageView?.contentMode = .scaleAspectFit
        btnBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.goBack)))
        
        vNavigation.addSubview(lbTitle)
        lbTitle.snp.makeConstraints({
            $0.center.equalToSuperview()
        })
        lbTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbTitle.textColor = .white
        
        let vSearch = UIView()
        viewSearch.addSubview(vSearch)
        vSearch.snp.makeConstraints({
            $0.top.equalTo(vNavigation.snp.bottom).offset(8)
            $0.width.equalToSuperview().offset(-32)
            $0.bottom.equalToSuperview().offset(-8)
            $0.centerX.equalToSuperview()
        })
        vSearch.layer.cornerRadius = 20
        vSearch.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        vSearch.addSubview(tfSearch)
        tfSearch.snp.makeConstraints({
            $0.centerY.height.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        })
        tfSearch.textColor = .white
        tfSearch.placeholder = "Nhập từ khoá tìm kiếm"
        let btnSearch = UIButton()
        vSearch.addSubview(btnSearch)
        btnSearch.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(tfSearch.snp.trailing).offset(4)
            $0.height.equalToSuperview().multipliedBy(-4)
            $0.trailing.equalToSuperview().offset(-4)
            $0.width.equalTo(btnSearch.snp.height)
        })
        btnSearch.setImage(UIImage(named: "ic_cut")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnSearch.imageView?.tintColor = .white
        btnSearch.imageView?.contentMode = .scaleAspectFit
        btnSearch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actSearch)))
        
        self.view.addSubview(stackMain)
        stackMain.snp.makeConstraints({
            $0.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
            $0.top.equalTo(viewSearch.snp.bottom)
        })
        stackMain.alignment = .center
        stackMain.axis = .vertical
        stackMain.distribution = .fill
        
        stackMain.addArrangedSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ItemTableViewCell", bundle: nil), forCellReuseIdentifier: ItemTableViewCell.id)
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        tableView.snp.makeConstraints({
            $0.width.equalToSuperview()
        })
        
        stackMain.addArrangedSubview(vAction)
        vAction.snp.makeConstraints({
            $0.width.equalToSuperview()
            $0.height.equalTo(74)
        })
        vAction.addSubview(btnAction)
        btnAction.snp.makeConstraints({
            $0.center.equalToSuperview()
            $0.height.equalTo(42)
            $0.width.equalTo(btnAction.snp.height).multipliedBy(3.5)
        })
        btnAction.layer.cornerRadius = 4
        btnAction.backgroundColor = mainColor
        btnAction.setTitle("Action", for: .normal)
        btnAction.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        
        configType()
    }
}

//extension ListViewController {
//    func loadMusicList() {
//        let documentsDir = fileManager.urls(for: .documentDirectory,
//                                            in: .userDomainMask)[0].path
//        if let files = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
//            do {
//                let fileURLs = try fileManager.contentsOfDirectory(at: files, includingPropertiesForKeys: nil)
//                print(fileURLs)
//                // process files
//            } catch {
//                print("Error while enumerating files \(files.path): \(error.localizedDescription)")
//            }
//        }
//        var image: UIImage!
//        //var titleString: String!
//        var artistString: String!
//        var musicName: String!
//
//        if let list = UserDefaultManager.getMusicList() {
//          if list.isEmpty {
//            musicInfo.removeAll()
//
//            do {
//              let items = try fileManager.contentsOfDirectory(atPath: documentsDir)
//              
//              for item in items {
//                musicName = item
//                
//                let url = URL(fileURLWithPath: item)
//                let asset = AVAsset(url: url) as AVAsset
//                
//                // artwork image 얻기
//                let metaArtwork = asset.commonMetadata.filter
//                { $0.commonKey?.rawValue == "artwork"}
//                
//                if !metaArtwork.isEmpty {
//                  let imageData = metaArtwork[0].value
//                  image = UIImage(data: imageData as! Data)
//                } else {
//                  image = UIImage(named: "noImage")
//                }
//                
//                
//                let metaArtist = asset.commonMetadata.filter
//                { $0.commonKey?.rawValue == "artist"}
//                
//                if !metaArtist.isEmpty {
//                  artistString = metaArtist[0].value as? String
//                } else {
//                  artistString = "Artist"
//                }
//                
//                
//                //          for metaDataItems in asset.commonMetadata {
//                //            if metaDataItems.commonKey?.rawValue == "title" {
//                //              guard let titleData = metaDataItems.value else {return}
//                //              titleString = titleData as? String
//                //            }
//                //            if metaDataItems.commonKey?.rawValue == "artist" {
//                //              guard let artistData = metaDataItems.value else {return }
//                //              artistString = artistData as? String
//                //
//                //            }
//                //          }
//                
//                musicInfo.append(MusicData(cover: image,
//                                           title: musicName,
//                                           artist: artistString,
//                                           musicName: musicName))
//              }
//             
//            } catch {
//              print("Not Found item")
//            }
//            tableView.reloadData()
//            
//          } else {
//            
//            musicInfo.removeAll()
//            let list = UserDefaultManager.getMusicList()
//            
//            for item in list! {
//              musicName = item
//              
//              do {
//                let items = try fileManager.contentsOfDirectory(atPath: documentsDir)
//                
//                for name in items {
//                  if musicName == name {
//                    
//                    let url = URL(fileURLWithPath: musicName)
//                    let asset = AVAsset(url: url) as AVAsset
//                    
//                    let meta = asset.commonMetadata.filter
//                    { $0.commonKey?.rawValue == "artwork"}
//                    
//                    if meta.count > 0 {
//                      let imageData = meta[0].value
//                      image = UIImage(data: imageData as! Data)
//                    } else {
//                      image = UIImage(named: "noImage")
//                    }
//                    
//                    let metaArtist = asset.commonMetadata.filter
//                          { $0.commonKey?.rawValue == "artist"}
//                          
//                          if !metaArtist.isEmpty {
//                            artistString = metaArtist[0].value as? String
//                          } else {
//                            artistString = "작자미상"
//                          }
//                    
//    //                for metaDataItems in asset.commonMetadata {
//    //                  if metaDataItems.commonKey?.rawValue == "title" {
//    //                    guard let titleData = metaDataItems.value else {return}
//    //                    titleString = titleData as? String
//    //                  }
//    //                  if metaDataItems.commonKey?.rawValue == "artist" {
//    //                    guard let artistData = metaDataItems.value else {return}
//    //                    artistString = artistData as? String
//    //
//    //                  }
//    //                }
//                    
//                    musicInfo.append(MusicData(cover: image,
//                                               title: musicName,
//                                               artist: artistString,
//                                               musicName: musicName))
//                    
//                  }
//                }
//                
//              } catch {
//                print("not Found item")
//              }
//              tableView.reloadData()
//            }
//          }
//          
//        } else {
//          
//          musicInfo.removeAll()
//
//          do {
//            let items = try fileManager.contentsOfDirectory(atPath: documentsDir)
//            
//            for item in items {
//              musicName = item
//              
//              let url = URL(fileURLWithPath: item)
//              let asset = AVAsset(url: url) as AVAsset
//              
//              // artwork image 얻기
//              let metaArtwork = asset.commonMetadata.filter
//              { $0.commonKey?.rawValue == "artwork"}
//              
//              if !metaArtwork.isEmpty {
//                let imageData = metaArtwork[0].value
//                image = UIImage(data: imageData as! Data)
//              } else {
//                image = UIImage(named: "noImage")
//              }
//              
//              
//              let metaArtist = asset.commonMetadata.filter
//              { $0.commonKey?.rawValue == "artist"}
//              
//              if !metaArtist.isEmpty {
//                artistString = metaArtist[0].value as? String
//              } else {
//                artistString = "작자미상"
//              }
//              
//              
//    //          for metaDataItems in asset.commonMetadata {
//    //            if metaDataItems.commonKey?.rawValue == "title" {
//    //              guard let titleData = metaDataItems.value else {return}
//    //              titleString = titleData as? String
//    //            }
//    //            if metaDataItems.commonKey?.rawValue == "artist" {
//    //              guard let artistData = metaDataItems.value else {return }
//    //              artistString = artistData as? String
//    //
//    //            }
//    //          }
//              
//              musicInfo.append(MusicData(cover: image,
//                                         title: musicName,
//                                         artist: artistString,
//                                         musicName: musicName))
//            }
//            
//          } catch {
//            print("Not Found item")
//          }
//          tableView.reloadData()
//          
//        }
//      
//        
//      }
//}
