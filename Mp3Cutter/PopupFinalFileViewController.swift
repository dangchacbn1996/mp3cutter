//
//  PopupFinalFileViewController.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/15/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import UIKit

enum ExportType : String{
    case mp3 = "MP3"
    case m4a = "M4A"
    case acc = "ACC"
}

enum SoundQuality : String {
    case kbps128 = "128Kbps"
    case kbps320 = "320Kbps"
}
enum SoundType : String {
    case ringtone = "Nhạc chuông"
    case warning = "Âm báo"
    case audioFile = "File nhạc"
}

class PopupFinalViewController: UIViewController {
    
    enum selectType : Int {
        case export = 1
        case quality = 2
        case type = 3
    }
    
    private let viewContainer = UIView()
    private let actionType = ActionType.actCut
    private let tfNewName = UITextField()
    private var lbExport = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), color: .black)
    private var lbQuality = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), color: .black)
    private var lbSoundType = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), color: .black)
    private var doneBlock: ((String, URL, ExportType, SoundQuality, SoundType) -> (Void))!
    private var typeExport = ExportType.mp3 {
        didSet {
            lbExport.text = typeExport.rawValue
        }
    }
    private var typeQuality = SoundQuality.kbps128 {
        didSet {
            lbQuality.text = typeQuality.rawValue
        }
    }
    private var typeSound = SoundType.audioFile {
        didSet {
            lbSoundType.text = typeSound.rawValue
        }
    }
    private var vcDrop = DropdownPickerViewController()
    
    init(doAction: @escaping ((String, URL, ExportType, SoundQuality, SoundType) -> (Void))) {
        super.init(nibName: nil, bundle: nil)
        self.doneBlock = doAction
    }
    
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @objc func goBack(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func doAction() {
        let name = tfNewName.text ?? ""
        if name.replacingOccurrences(of: " ", with: "") == "" {
            print("Vui lòng nhập tên file")
            return
        }
        do {
            typeExport = .m4a
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent("\(tfNewName.text ?? "").\(typeExport.rawValue)")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                let vcWarning = UIAlertController(title: "File đã tồn tại", message: "Thư mục đã tồn tại file \(tfNewName.text ?? "").\(typeExport.rawValue). Đổi tên hoặc xoá file để tiếp tục?", preferredStyle: .alert)
                vcWarning.addAction(UIAlertAction(title: "Đổi tên", style: .default, handler: { (alert) in
                    self.dismiss(animated: true, completion: nil)
                }))
                vcWarning.addAction(UIAlertAction(title: "Xoá file", style: .default, handler: { (alert) in
                    do {
                        try? FileManager.default.removeItem(atPath: fileURL.path)
                        try? FileManager.default.createDirectory(atPath: fileURL.path, withIntermediateDirectories: true, attributes: nil)
                        self.doneBlock(name, fileURL, self.typeExport, self.typeQuality, self.typeSound)
                    } catch {
                        print("")
                    }
                }))
                self.present(vcWarning, animated: true, completion: nil)
                return
            } else {
                try? FileManager.default.createDirectory(atPath: fileURL.path, withIntermediateDirectories: true, attributes: nil)
            }
            doneBlock(name, fileURL, typeExport, typeQuality, typeSound)
        } catch {
            print("Somethings went wrong!")
        }
    }
    
    @objc func actDropList(_ gesture: UIGestureRecognizer) {
        if let viewGes = gesture.view {
            var vGes = gesture.view
            vcDrop = DropdownPickerViewController(delegate: self, viewDrop: &vGes, border: Constant.viewBorder)
            var listObj : [Any] = []
            var listData : [String] = []
            switch viewGes.tag {
            case selectType.export.rawValue:
                listObj = [ExportType.acc, ExportType.m4a, ExportType.mp3]
                listObj.forEach({
                    listData.append(($0 as! ExportType).rawValue)
                })
                break
            case selectType.quality.rawValue:
                listObj = [SoundQuality.kbps128, SoundQuality.kbps320]
                listObj.forEach({
                    listData.append(($0 as! SoundQuality).rawValue)
                })
                break
            case selectType.type.rawValue:
                listObj = [SoundType.audioFile, SoundType.ringtone, SoundType.warning]
                listObj.forEach({
                    listData.append(($0 as! SoundType).rawValue)
                })
                break
            default:
                break
            }
            vcDrop.listObj = listObj
            vcDrop.listData = listData
            self.present(vcDrop, animated: false, completion: nil)
            vcDrop.viewContainer.layer.cornerRadius = viewGes.layer.cornerRadius
        }
    }
    
}

extension PopupFinalViewController: DropdownPickerViewDelegate {
    func layoutConstraint(dropdown: DropdownPickerViewController, tableView: UITableView) -> (point: CGPoint, width: CGFloat, height: CGFloat) {
        let viewDropDown = dropdown.viewPos!
        let errorPoint = CGPoint(x: (self.view.bounds.width * 0.25), y: (self.view.bounds.height / 2 - (32 * 1.5)))
        let point = viewDropDown.superview?.convert(viewDropDown.frame.origin, to: nil) ?? errorPoint
        let width = viewDropDown.frame.width
        let height = viewDropDown.frame.height
        return (point, width, height * 3.5)
    }
    
    func numberOfRow(dropdown: DropdownPickerViewController, tableView: UITableView) -> (Int) {
        return dropdown.listObj.count
    }
    
    func setData(dropdown: DropdownPickerViewController, tableView: UITableView, indexPath: IndexPath) -> (UITableViewCell) {
//        let cell = tableView.dequeueReusableCell(withIdentifier: MarketWatchListItemTVC.id, for: indexPath) as! MarketWatchListItemTVC
//        let name = (dropdown.listObj[indexPath.row] as? MarketServices.UrlListIndex)?.rawValue.uppercased() ?? (dropdown.listObj[indexPath.row] as? MarketWatchListItem)?.Name?.uppercased()
//        cell.bind(title: name ?? "", removable: cateType == .collection)
//        cell.btnRemove.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.removeCollection(_:))))
        let cell = UITableViewCell()
        cell.textLabel?.text = dropdown.listData[indexPath.row]
        return cell
    }
    
    func didSelect(dropdown: DropdownPickerViewController, tableView: UITableView, index: Int) {
        if let vDrop = dropdown.viewPos {
            switch vDrop.tag {
            case selectType.export.rawValue:
                typeExport = dropdown.listObj[index] as! ExportType
                break
            case selectType.quality.rawValue:
                typeQuality = dropdown.listObj[index] as! SoundQuality
                break
            case selectType.type.rawValue:
                typeSound = dropdown.listObj[index] as! SoundType
                break
            default:
                break
            }
        }
    }
    
//    private func selectType(_ selected: MarketServices.UrlListIndex) {
//        lbCategory.text = selected.rawValue.uppercased()
//        page = 0
//        self.listIndex = []
//        self.tableView.reloadData()
//        startLoading()
//        MarketServices.shared.getListIndex(type: selected, failed: { (error) in
//            self.stopLoading()
//            APIBaseManager.toastError(error)
//        }) { (listIndex) in
//            self.stopLoading()
//            self.listIndex = listIndex
//            self.loadData(.stay, showLoading: true)
//        }
//    }
//
//    private func selectType(_ selected: MarketWatchListItem) {
//        currentWatch = selected
//    }
    
    func onShowEffect() {
//        lazy = UIView()
//        self.view.addSubview(lazy)
//        lazy.snp.makeConstraints({
//            $0.edges.equalToSuperview()
//        })
//        lazy.alpha = 0
//        lazy.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
//        UIView.animate(withDuration: 0.3) {
//            self.lazy.alpha = 1
//        }
    }
    
    func onDismissEffect() {
//        UIView.animate(withDuration: 0.2, animations: {
//            self.lazy.alpha = 0
//        }) { (Bool) in
//            self.lazy.removeFromSuperview()
//        }
    }
    
    func heightForCell(dropdown: DropdownPickerViewController, tableView: UITableView, indexPath: IndexPath) -> (CGFloat) {
        return 32
    }
    
    
}

extension PopupFinalViewController {
    func setupUI(){
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.view.addSubview(viewContainer)
        viewContainer.snp.makeConstraints({
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.8)
//            $0.height.equalTo(viewContainer.snp.width).multipliedBy(1)
        })
        viewContainer.backgroundColor = .white
        viewContainer.layer.cornerRadius = Constant.viewCorner
        
        let lbTitle = UILabel(text: "Xuất file", font: UIFont.systemFont(ofSize: 14, weight: .medium), color: .black)
        
        let lbTitleName = UILabel(text: "Tên mới", font: Constant.Text.fontSmall, color: Constant.Text.colorGray)
        let lbTitleExportType = UILabel(text: "Chọn định dạng", font: Constant.Text.fontSmall, color: Constant.Text.colorGray)
        let lbTitleType = UILabel(text: "Loại", font: Constant.Text.fontSmall, color: Constant.Text.colorGray)
        
        let space : CGFloat = 8
        let boxHeight : CGFloat = 32
        viewContainer.addSubview(lbTitle)
        lbTitle.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(8)
        })
        viewContainer.addSubview(lbTitleName)
        lbTitleName.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().offset(-32)
            $0.top.equalTo(lbTitle.snp.bottom).offset(16)
        })
        viewContainer.addSubview(tfNewName)
        tfNewName.snp.makeConstraints({
            $0.centerX.width.equalTo(lbTitleName)
            $0.top.equalTo(lbTitleName.snp.bottom).offset(4)
            $0.height.equalTo(boxHeight)
        })
        tfNewName.placeholder = "Tên sẽ lưu"
        tfNewName.borderStyle = .roundedRect
        viewContainer.addSubview(lbTitleExportType)
        lbTitleExportType.snp.makeConstraints({
            $0.top.equalTo(tfNewName.snp.bottom).offset(space)
            $0.centerX.width.equalTo(lbTitleName)
        })
        let viewExportType = initViewDrop(label: &lbExport)
        viewContainer.addSubview(viewExportType)
        viewExportType.snp.makeConstraints({
            $0.leading.equalTo(lbTitleName)
            $0.top.equalTo(lbTitleExportType.snp.bottom).offset(4)
            $0.width.equalToSuperview().multipliedBy(0.5)
            $0.height.equalTo(boxHeight)
        })
        viewExportType.tag = selectType.export.rawValue
        viewExportType.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actDropList(_:))))
        
        let viewQuality = initViewDrop(label: &lbQuality)
        viewContainer.addSubview(viewQuality)
        viewQuality.snp.makeConstraints({
            $0.centerY.height.equalTo(viewExportType)
            $0.leading.equalTo(viewExportType.snp.trailing).offset(8)
            $0.trailing.equalTo(lbTitleName)
        })
        viewQuality.tag = selectType.quality.rawValue
        viewQuality.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actDropList(_:))))
        
        viewContainer.addSubview(lbTitleType)
        lbTitleType.snp.makeConstraints({
            $0.top.equalTo(viewQuality.snp.bottom).offset(space)
            $0.centerX.width.equalTo(lbTitleName)
        })
        let viewType = initViewDrop(label: &lbSoundType)
        viewContainer.addSubview(viewType)
        viewType.snp.makeConstraints({
            $0.centerX.width.equalTo(lbTitleName)
            $0.height.equalTo(boxHeight)
            $0.top.equalTo(lbTitleType.snp.bottom).offset(4)
        })
        viewType.tag = selectType.type.rawValue
        viewType.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actDropList(_:))))

        let buttonBack = UIButton()
        viewContainer.addSubview(buttonBack)
        buttonBack.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalTo(viewContainer.snp.centerX).offset(-16)
            $0.height.equalTo(boxHeight + 8)
            $0.top.equalTo(viewType.snp.bottom).offset(24)
            $0.bottom.equalToSuperview().offset(-16)
        })
        buttonBack.layer.cornerRadius = Constant.viewCorner
        buttonBack.layer.borderColor = actionType.color.cgColor
        buttonBack.layer.borderWidth = 1
        buttonBack.backgroundColor = .white
        buttonBack.setTitle("Trở lại", for: .normal)
        buttonBack.setTitleColor(actionType.color, for: .normal)
        buttonBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.goBack)))

        let buttonAction = UIButton()
        viewContainer.addSubview(buttonAction)
        buttonAction.snp.makeConstraints({
            $0.centerY.size.equalTo(buttonBack)
            $0.trailing.equalToSuperview().offset(-32)
        })
        buttonAction.layer.cornerRadius = Constant.viewCorner
        buttonAction.backgroundColor = actionType.color
        buttonAction.setTitle("Thực hiện", for: .normal)
        buttonAction.setTitleColor(.white, for: .normal)
        buttonAction.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.doAction)))
    }
    
    func initViewDrop(label: inout UILabel) -> (UIView) {
        let vResult = UIView()
        vResult.layer.cornerRadius = Constant.viewCorner
        vResult.layer.borderWidth = 1
        vResult.layer.borderColor = UIColor.gray.withAlphaComponent(0.6).cgColor
        
        vResult.addSubview(label)
        label.snp.makeConstraints({
            $0.centerY.height.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
        })
        
        let icDrop = UIImageView(image: UIImage(named: "ic_drop")?.withRenderingMode(.alwaysTemplate))
        icDrop.tintColor = UIColor.gray.withAlphaComponent(0.6)
        vResult.addSubview(icDrop)
        icDrop.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.size.equalTo(vResult.snp.height).multipliedBy(0.7)
            $0.trailing.equalToSuperview().offset(-8)
            $0.leading.equalTo(label.snp.trailing).offset(4)
        })
        return vResult
    }
}