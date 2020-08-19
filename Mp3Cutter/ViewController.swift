//
//  ViewController.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/11/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import UIKit
import SnapKit

enum ListType : Int {
    case cut = 0
    case merge = 1
    case convert = 2
    case video = 3
    case collection = 4
}

class ViewController: UIViewController {
    
    
    private let scrollMain = UIScrollView()
    private let viewContainer = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
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
    
    @objc func openAction(){
        let vc = ActionCutViewController()
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
        btnBack.addTarget(self, action: #selector(backDismiss), for: .touchUpInside)
        btnBack.snp.makeConstraints({
            $0.center.equalToSuperview()
            $0.width.height.equalToSuperview().multipliedBy(0.7)
        })
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: vButton)
        self.present(navi, animated: true, completion: nil)
    }
    
    @objc func backDismiss(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension ViewController {
    func setupUI(){
        let vHeader = UIView()
        self.view.addSubview(vHeader)
        vHeader.snp.makeConstraints({
            $0.top.centerX.width.equalToSuperview()
            $0.height.equalTo(64)
        })
        self.view.addSubview(scrollMain)
        scrollMain.snp.makeConstraints({
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(vHeader.snp.bottom)
        })
        scrollMain.addSubview(viewContainer)
        viewContainer.snp.makeConstraints({
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().offset(-32)
            $0.height.equalToSuperview().offset(-32)
        })
        let imageBack = UIImageView()
        viewContainer.addSubview(imageBack)
        imageBack.snp.makeConstraints({
            $0.centerX.width.top.equalToSuperview()
            $0.height.equalTo(imageBack.snp.width).multipliedBy(0.5)
        })
        imageBack.image = UIImage(named: "ic_background")
        
        let btnCut = makeButton(type: .actCut, imgName: "ic_cut")
        let btnMerge = makeButton(type: .actMerge, imgName: "ic_cut")
        let btnConvert = makeButton(type: .actConvert, imgName: "ic_cut")
        let btnVideo = makeButton(type: .actVideo, imgName: "ic_cut")
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
        
        let btnLibrary = makeButton(type: .actCollection, imgName: "ic_cut")
        viewContainer.addSubview(btnLibrary)
        btnLibrary.snp.makeConstraints({
            $0.centerX.width.equalToSuperview()
            $0.height.equalTo(btnCut)
            $0.top.equalTo(btnConvert.snp.bottom).offset(16)
            $0.bottom.lessThanOrEqualToSuperview()
        })
        
        btnCut.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openAction)))
        btnMerge.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actFunction(_:))))
        btnConvert.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actFunction(_:))))
        btnVideo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actFunction(_:))))
        btnLibrary.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actFunction(_:))))
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
