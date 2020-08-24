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
import MGSwipeTableCell

struct MusicData {
    
    var url : URL?
    var cover: UIImage?
    var title: String?
    var artist: String?
    var musicName: String?
    var asset: AVAsset!
    
    init(url: URL, cover: UIImage?, title: String?, artist: String?, musicName: String?) {
        self.url = url
        self.cover = cover
        self.title = title
        self.artist = artist
        self.musicName = musicName
        self.asset = AVAsset(url: url)
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
    var listHidden : [IndexPath] = []
    var refreshControl = UIRefreshControl()
    private var textSearch = "" {
        didSet {
            if textSearch.replacingOccurrences(of: " ", with: "") == "" {
                listHidden.removeAll()
                tableView.reloadData()
                return
            }
            listHidden = []
            for index in 0..<musicData.count {
                if !(musicData[index].title?.lowercased().contains(textSearch.lowercased()) ?? true) {
                    listHidden.append(IndexPath(row: index, section: 0))
                }
            }
            for index in 0..<localMusic.count {
                if !(localMusic[index].title?.lowercased().contains(textSearch.lowercased()) ?? true) {
                    listHidden.append(IndexPath(row: index, section: 1))
                }
            }
            tableView.reloadData()
        }
    }
    private let lbTitle = UILabel()
    private let viewSearch = UIView()
    private let vNavigation = UIView()
    private let tfSearch = UITextField()
    private let tableView = UITableView()
    private let vAction = UIView()
    private let btnAction = UIButton()
    private let stackMain = UIStackView()
    private var multiChoise: [IndexPath]? = nil
    private var vcSort = DropdownPickerViewController()
    private let btnSort = UIButton()
    private let sortOpts = ["A -> Z", "Z -> A", "Kích thước", "Thời gian"]
    var actType = ActionType.actCut
    var mainColor : UIColor? = UIColor.red.withAlphaComponent(0.5)
    
    convenience init(actionType: Int) {
        self.init()
        self.actType = ActionType.getType(actionType)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if self.actType.type == .merge {
            multiChoise = []
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMusics()
    }
    
    @objc func loadMusics(){
        var supportType: [String] = []
        self.localMusic = []
        switch actType.type {
        case .cut, .merge, .convert:
            supportType = ["mp3", "m4a", "m4r"]
            if let demoUrl = Bundle(for: type(of: self)).url(forResource: "Presentations", withExtension: "mp3") {
                localMusic.append(MusicData(url: demoUrl, cover: nil, title: "Presentations", artist: "demo", musicName: nil))
            }
            break
        case .video:
            supportType = ["m4v", "mp4", "mov"]
            if let demoVideo = Bundle(for: type(of: self)).url(forResource: "demovideo", withExtension: "mp4") {
                localMusic.append(MusicData(url: demoVideo, cover: nil, title: "demovideo", artist: "demo", musicName: nil))
            }
            break
        default:
            break
        }
        refreshControl.endRefreshing()
        if let mediaItems = MPMediaQuery.songs().items {
            mediaItems.forEach({
                if supportType.count != 0 {
                    if !supportType.contains($0.assetURL?.pathExtension.lowercased() ?? "") {
                        return
                    }
                }
                self.musicData.append($0)
            })
        }
        if self.actType.type == .merge {
            self.multiChoise = []
        }
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            fileURLs.forEach({
                var title = $0.lastPathComponent
                if supportType.count != 0 {
                    if !supportType.contains($0.pathExtension.lowercased()) {
                        return
                    }
                }
//                if !title.contains(ExportType.m4a.rawValue.lowercased())
//                    && !title.contains(ExportType.aif.rawValue.lowercased())
//                    && !title.contains(ExportType.caf.rawValue.lowercased())
//                    && !title.contains(ExportType.wav.rawValue.lowercased()) {
//                    return
//                }
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
        textSearch = tfSearch.text ?? ""
    }
    
    @objc func goBack(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func actSort(){
        vcSort = DropdownPickerViewController(delegate: self, background: .white, border: UIColor.gray.withAlphaComponent(0.3).cgColor)
        self.present(vcSort, animated: false, completion: nil)
    }
    
    @objc func actAction(){
        if actType.type == .merge {
            if multiChoise?.count ?? 0 < 2 {
                Toast.shared.makeToast(.error, string: "Vui lòng chọn ít nhất 2 file âm thanh", inView: self.view, time: 2.0)
                return
            }
            var listURL = getListChoice()
            var vc : PopupFinalViewController!
            vc = PopupFinalViewController(name: "Tên mới", actType: actType, url: listURL, doAction: {(media, url) -> (Void) in
                Loading.sharedInstance.show(in: vc.view)
                MediaPascer.shared.mergeFilesWithUrl(info: media, newURL: url, listURL: listURL, failed: { (error) in
                    Loading.sharedInstance.dismiss()
                    Toast.shared.makeToast(.error, string: error, inView: self.view, time: 2.0)
                }) {
                    Loading.sharedInstance.dismiss()
                    Toast.shared.makeToast(.success, string: "Tạo file thành công!", inView: vc.view, time: 2.0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        vc.dismiss(animated: true, completion: nil)
                    }
                    print("SUCCESS: \(url.absoluteString)")
                    print("-----------------------------")
                }
            })
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    private func getListChoice() -> ([URL]) {
        if let listChoice = multiChoise {
            var listURL: [URL] = []
            listChoice.forEach({
                if $0.section == 0 {
                    if musicData.count > $0.row {
                        if let url = musicData[$0.row].assetURL {
                            listURL.append(url)
                        }
                    }
                }
                if $0.section == 1 {
                    if localMusic.count > $0.row {
                        if let url = localMusic[$0.row].url {
                            listURL.append(url)
                        }
                    }
                }
            })
            return listURL
        }
        return []
    }
}

extension ListViewController: DropdownPickerViewDelegate {
    func layoutConstraint(dropdown: DropdownPickerViewController, tableView: UITableView) -> (point: CGPoint, width: CGFloat, height: CGFloat) {
        let width = self.view.frame.width * 0.4
        var point = btnSort.superview?.convert(btnSort.frame.origin, to: nil) ?? CGPoint(x: 0, y: 0)
        point.y = point.y + btnSort.bounds.height
        point.x = point.x - width + btnSort.frame.width
        return (point, width, btnSort.frame.height * 4)
    }
    
    func numberOfRow(dropdown: DropdownPickerViewController, tableView: UITableView) -> (Int) {
        return sortOpts.count
    }
    
    func setData(dropdown: DropdownPickerViewController, tableView: UITableView, indexPath: IndexPath) -> (UITableViewCell) {
        let cell = UITableViewCell()
        cell.textLabel?.text = sortOpts[indexPath.row]
        return cell
    }
    
    func didSelect(dropdown: DropdownPickerViewController, tableView: UITableView, index: Int) {
        switch index {
        case 0:
            musicData.sorted { ($0.title ?? "a") < ($1.title ?? "b") }
            localMusic.sorted { ($0.title ?? "a") < ($1.title ?? "b") }
            break
        case 1:
            musicData.sorted { ($0.title ?? "a") > ($1.title ?? "b") }
            localMusic.sorted { ($0.title ?? "a") > ($1.title ?? "b") }
            break
        case 2:
            break
        case 3:
//            musicData.sorted{
//                let sort0 = AVAsset(url: $0.assetURL)
//                ($0.assetURL ?? "a") > ($1.title ?? "b")
//            }
//            localMusic.sorted{
//                ($1.asset.duration.seconds) > ($1.asset.duration.seconds)
//            }
            break
        default:
            break
        }
        tableView.reloadData()
    }
    
    func onShowEffect() {
        
    }
    
    func onDismissEffect() {
        
    }
    
    func heightForCell(dropdown: DropdownPickerViewController, tableView: UITableView, indexPath: IndexPath) -> (CGFloat) {
        return btnSort.frame.height
    }
    
    
}

extension ListViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        actSearch()
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? musicData.count : localMusic.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = UITableViewCell()
        cell.textLabel?.text = section == 0 ? "Nhạc itunes (\(musicData.count))" : "Bộ sưu tập (\(localMusic.count))"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        cell.textLabel?.textColor = UIColor.gray.withAlphaComponent(0.8)
        cell.contentView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        for item in listHidden {
            if item.section == indexPath.section && item.row == indexPath.row {
                return 0
            }
        }
        return ItemTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.id, for: indexPath) as! ItemTableViewCell
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            cell.bind(musicData[indexPath.row], checkColor: multiChoise != nil ? mainColor : .clear, showCheck: true)
            cell.rightButtons = []
        } else {
            var data = localMusic[indexPath.row]
            cell.bind(data, checkColor: multiChoise != nil ? mainColor : .clear, showCheck: true)
            var actions : [MGSwipeButton] = []
            actions.append(MGSwipeButton.init(title: "Xoá", backgroundColor: UIColor(hexString: "b9b2b2"), callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                let vcWarning = UIAlertController(title: "Xoá file", message: "Bạn chắc chắn muốn xoá file \(data.title ?? "")?", preferredStyle: .alert)
                vcWarning.addAction(UIAlertAction(title: "Huỷ", style: .default, handler: { (alert) in
                    vcWarning.dismiss(animated: true, completion: nil)
                }))
                vcWarning.addAction(UIAlertAction(title: "Xoá file", style: .default, handler: { (alert) in
                    do {
                        try? FileManager.default.removeItem(atPath: data.url?.path ?? "")
                        self.loadMusics()
                    } catch {
                        Toast.shared.makeToast(.error, string: "Có lỗi trong quá trình xoá file!", inView: self.view, time: 2.0)
                    }
                }))
                self.present(vcWarning, animated: true, completion: nil)
                return true
            }))
            
            cell.rightButtons = actions
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if multiChoise != nil {
            if let cell = tableView.cellForRow(at: indexPath) as? ItemTableViewCell {
                if cell.isOn() {
                    for index in 0..<multiChoise!.count {
                        if multiChoise![index].section == indexPath.section && multiChoise![index].row == indexPath.row {
                            multiChoise?.remove(at: index)
                            break
                        }
                    }
                }
                else {
                    multiChoise?.append(indexPath)
                }
                cell.checkOn()
                var time : Double = 0
                getListChoice().forEach({
                    let asset = AVAsset(url: $0)
                    time += asset.duration.seconds
                })
                var title = "Ghép(\(multiChoise!.count)) / "
                title += NSString(format: "%02d:%02d", Int(time / 60), Int(time.truncatingRemainder(dividingBy: 60))) as String
                
                btnAction.setTitle(title, for: .normal)
            }
        } else {
            switch actType.type {
            case .cut, .video:
                var url : URL? = nil
                url = indexPath.section == 0 ? (musicData[indexPath.row].assetURL) : localMusic[indexPath.row].url
                if url == nil {
                    return
                }
                let vc = ActionCutViewController(url: url!, action: self.actType)
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
                btnBack.setImage(UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
                btnBack.imageView?.tintColor = .white
                btnBack.imageView?.contentMode = .scaleAspectFit
                btnBack.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
                btnBack.snp.makeConstraints({
                    $0.center.equalToSuperview()
                    $0.width.height.equalToSuperview().multipliedBy(0.6)
                })
                vc.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: vButton)
                self.present(navi, animated: true, completion: nil)
                break
            case .convert:
                var vc : PopupFinalViewController!
                var assetURL : URL? = nil
                assetURL = indexPath.section == 0 ? (musicData[indexPath.row].assetURL) : localMusic[indexPath.row].url
                if assetURL == nil {
                    return
                }
                let asset = AVAsset(url: assetURL!)
                vc = PopupFinalViewController(name: "Tên mới", actType: actType, url: [assetURL!], doAction: {(media, url) -> (Void) in
                    Loading.sharedInstance.show(in: vc.view)
                    MediaPascer.shared.audioURLParse(info: media, newURL: url, asset: asset, failed: { (error) in
                        Loading.sharedInstance.dismiss()
                        Toast.shared.makeToast(.error, string: error, inView: vc.view, time: 2.0)
                    }) { () in
                        Loading.sharedInstance.dismiss()
                        Toast.shared.makeToast(.success, string: "Tạo file thành công!", inView: vc.view, time: 2.0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            vc.dismiss(animated: true, completion: nil)
                        }
                    }
                })
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            case .collection:
                var assetURL : URL? = nil
                assetURL = indexPath.section == 0 ? (musicData[indexPath.row].assetURL) : localMusic[indexPath.row].url
                if assetURL == nil {
                    return
                }
                let vc = PopupPlayerViewController()
                vc.url = assetURL
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
                break
            case .video:
                let vc = ActionVideoViewController()
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
                btnBack.setImage(UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
                btnBack.imageView?.tintColor = .white
                btnBack.imageView?.contentMode = .scaleAspectFit
                btnBack.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
                btnBack.snp.makeConstraints({
                    $0.center.equalToSuperview()
                    $0.width.height.equalToSuperview().multipliedBy(0.6)
                })
                vc.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: vButton)
                self.present(navi, animated: true, completion: nil)
            default:
                break
            }
        }
    }
}

extension ListViewController {
    
    private func configType(){
        switch actType.type {
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
            self.lbTitle.text = "Bộ sưu tập của tôi"
            vAction.isHidden = true
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
        btnBack.setImage(UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnBack.imageView?.tintColor = .white
        btnBack.imageView?.contentMode = .scaleAspectFit
        btnBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.goBack)))
        
        vNavigation.addSubview(btnSort)
        btnSort.snp.makeConstraints({
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.size.equalTo(btnBack)
        })
        btnSort.setImage(UIImage(named: "ic_sort")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnSort.imageView?.tintColor = .white
        btnSort.imageView?.contentMode = .scaleAspectFit
        btnSort.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actSort)))
        
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
        tfSearch.delegate = self
        let btnSearch = UIButton()
        vSearch.addSubview(btnSearch)
        btnSearch.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.5)
            $0.leading.equalTo(tfSearch.snp.trailing).offset(4)
            $0.trailing.equalToSuperview().offset(-10)
            $0.width.equalTo(btnSearch.snp.height)
        })
        btnSearch.setImage(UIImage(named: "ic_search")?.withRenderingMode(.alwaysTemplate), for: .normal)
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
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ItemTableViewCell", bundle: nil), forCellReuseIdentifier: ItemTableViewCell.id)
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(self.loadMusics), for: .valueChanged)
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
            $0.width.equalTo(btnAction.snp.height).multipliedBy(4)
        })
        btnAction.layer.cornerRadius = 4
        btnAction.backgroundColor = mainColor
        btnAction.setTitle("Ghép", for: .normal)
        btnAction.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btnAction.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actAction)))
        
        configType()
    }
}