//
//  ViewController.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/11/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import UIKit
import SnapKit
import Localize_Swift

class ViewController: UIViewController{
    
    static var listAddition : [URL] = []
    
    private let scrollMain = UIScrollView()
    private let viewContainer = UIView()
    private let btnLang = UIButton()
    private var btnCut : UIView!
    private var btnMerge : UIView!
    private var btnConvert : UIView!
    private var btnVideo : UIView!
    private var btnCollection : UIView!
    let labelAppName = UILabel(text: "Home Page".localized(), font: UIFont.systemFont(ofSize: 18, weight: .semibold), color: UIColor(hexString: "212121"))
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        openHelp()
        NotificationCenter.default.addObserver(self, selector: #selector(self.localeChange), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    
    deinit {
        // remove all
        NotificationCenter.default.removeObserver(self)
    }
}

/*
 @objc
 */
extension ViewController {
    @objc func actFunction(_ gesture: UIGestureRecognizer){
        let vc = ListViewController(actionType: gesture.view?.tag ?? 0)
        vc.modalPresentationStyle = .overCurrentContext
        vc.mainColor = gesture.view?.backgroundColor
        self.present(vc, animated: true, completion: nil)
    }
    
//    @objc func openAction(){
//
//    }
    
    @objc func localeChange(){
        labelAppName.text = "Home Page".localized()
        ActionType.actCut.text = "Cắt âm thanh".localized()
        ActionType.actMerge.text = "Ghép âm thanh".localized()
        ActionType.actConvert.text = "Chuyển định dạng".localized()
        ActionType.actVideo.text = "Cắt video".localized()
        ActionType.actCollection.text = "Bộ sưu tập của tôi".localized()
        (btnCut.subviews[1] as! UILabel).text = ActionType.actCut.text
        (btnMerge.subviews[1] as! UILabel).text = ActionType.actMerge.text
        (btnConvert.subviews[1] as! UILabel).text = ActionType.actConvert.text
        (btnVideo.subviews[1] as! UILabel).text = ActionType.actVideo.text
        (btnCollection.subviews[1] as! UILabel).text = ActionType.actCollection.text
    }
    
    @objc func openHelp(){
        let lang = Localize.currentLanguage()
        if (lang.contains("vi")) {
            btnLang.setImage(UIImage(named: "lang_en"), for: .normal)
            Localize.setCurrentLanguage("en")
        } else {
            btnLang.setImage(UIImage(named: "lang_vi"), for: .normal)
            Localize.setCurrentLanguage("vi")
        }
        UserDefaults.standard.set(lang, forKey: "locale")
        UserDefaults.standard.synchronize()
    }
    
    @objc func backDismiss(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension ViewController {
    func setupUI(){
        self.view.backgroundColor = .white
        let ivBack = UIImageView(image: UIImage(named: "background"))
        self.view.addSubview(ivBack)
        ivBack.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
        ivBack.alpha = 0.2
        ivBack.contentMode = .scaleAspectFill
        let vHeader = UIView()
        self.view.addSubview(vHeader)
        vHeader.snp.makeConstraints({
            $0.centerX.width.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(46)
        })
        let iconApp = UIImageView(image: UIImage(named: "AppHeader"))
        iconApp.contentMode = .scaleAspectFit
        vHeader.addSubview(iconApp)
        iconApp.snp.makeConstraints({
            $0.height.equalToSuperview().offset(-8)
            $0.width.equalTo(iconApp.snp.height)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        })
        vHeader.addSubview(labelAppName)
        labelAppName.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(iconApp.snp.trailing).offset(16)
        })
        vHeader.addSubview(btnLang)
        btnLang.snp.makeConstraints({
            $0.centerY.equalTo(iconApp)
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(32)
        })
        var language = "en"
        if UserDefaults.standard.string(forKey: "locale") == nil {
            UserDefaults.standard.set("en", forKey: "locale")
            UserDefaults.standard.synchronize()
        } else {
            language = UserDefaults.standard.string(forKey: "locale")!
        }
        Localize.setCurrentLanguage(language)
        btnLang.clipsToBounds = true
        btnLang.imageView?.contentMode = .scaleAspectFill
        btnLang.layer.cornerRadius = 16
        btnLang.setImage(UIImage(named: "")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnLang.imageView?.contentMode = .scaleAspectFit
        btnLang.imageView?.tintColor = UIColor.gray.withAlphaComponent(0.5)
        btnLang.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openHelp)))
        
        self.view.addSubview(scrollMain)
        scrollMain.snp.makeConstraints({
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(vHeader.snp.bottom)
        })
        scrollMain.addSubview(viewContainer)
        viewContainer.snp.makeConstraints({
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().offset(-32)
            $0.height.equalToSuperview().offset(-16)
        })
        let imageBack = UIImageView()
        viewContainer.addSubview(imageBack)
        imageBack.snp.makeConstraints({
            $0.centerX.width.top.equalToSuperview()
            $0.height.equalTo(imageBack.snp.width).multipliedBy(0.5)
        })
        imageBack.layer.cornerRadius = 4
        imageBack.clipsToBounds = true
        imageBack.image = UIImage(named: "ic_background")
        
        btnCut = makeButton(type: .actCut, imgName: "ic_cut")
        btnMerge = makeButton(type: .actMerge, imgName: "ic_merge")
        btnConvert = makeButton(type: .actConvert, imgName: "ic_convert")
        btnVideo = makeButton(type: .actVideo, imgName: "ic_video")
        viewContainer.addSubview(btnCut)
        btnCut.tag = ListType.cut.rawValue
        btnCut.snp.makeConstraints({
            $0.leading.equalToSuperview()
            $0.width.equalTo(imageBack).multipliedBy(0.5).offset(-8)
            $0.top.equalTo(imageBack.snp.bottom).offset(24)
            $0.height.equalTo(btnCut.snp.width).multipliedBy(0.6)
        })
        
        viewContainer.addSubview(btnMerge)
        btnMerge.tag = ListType.merge.rawValue
        btnMerge.snp.makeConstraints({
            $0.size.centerY.equalTo(btnCut)
            $0.trailing.equalToSuperview()
        })
        
        viewContainer.addSubview(btnConvert)
        btnConvert.tag = ListType.convert.rawValue
        btnConvert.snp.makeConstraints({
            $0.size.centerX.equalTo(btnCut)
            $0.top.equalTo(btnCut.snp.bottom).offset(16)
        })
        
        viewContainer.addSubview(btnVideo)
        btnVideo.tag = ListType.video.rawValue
        btnVideo.snp.makeConstraints({
            $0.size.centerY.equalTo(btnConvert)
            $0.trailing.equalToSuperview()
        })
        
        btnCollection = makeButton(type: .actCollection, imgName: "ic_collection")
        viewContainer.addSubview(btnCollection)
        btnCollection.snp.makeConstraints({
            $0.centerX.width.equalToSuperview()
            $0.height.equalTo(btnCut)
            $0.top.equalTo(btnConvert.snp.bottom).offset(16)
            $0.bottom.lessThanOrEqualToSuperview()
        })
        btnCollection.tag = ListType.collection.rawValue
        
        btnCut.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actFunction)))
        btnMerge.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actFunction(_:))))
        btnConvert.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actFunction(_:))))
        btnVideo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actFunction(_:))))
        btnCollection.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actFunction(_:))))
    }
    
    func makeButton(type: ActionType, imgName: String) -> (UIView) {
        let vButton = UIView()
        vButton.backgroundColor = type.color
        let lbTitle = UILabel()
        let icIcon = UIImageView()
        icIcon.contentMode = .scaleAspectFit
        icIcon.image = UIImage(named: imgName)?.withRenderingMode(.alwaysTemplate)
        icIcon.tintColor = .white
        lbTitle.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lbTitle.textAlignment = .center
        lbTitle.textColor = .white
        lbTitle.text = type.text
        vButton.addSubview(icIcon)
        icIcon.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(8)
            $0.height.equalToSuperview().multipliedBy(0.5)
        })
        vButton.addSubview(lbTitle)
        lbTitle.snp.makeConstraints({
            $0.top.equalTo(icIcon.snp.bottom).offset(2)
            $0.centerX.width.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-2)
        })
        vButton.layer.cornerRadius = 4
        return vButton
    }
    
}
