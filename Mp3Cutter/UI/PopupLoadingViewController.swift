//
//  PopupLoadingViewController.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/22/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import UIKit

class PopupLoadingViewController: UIViewController {
    
    private var doneBlock: (() -> Void)? = nil
    private var rejectBlock: (() -> Void)? = nil
    private var maxTime : Int = 10
    private var current = 0
    private var lbTitle = UILabel(text: "", font: UIFont.systemFont(ofSize: 14, weight: .medium), color: UIColor.black)
    private var lbPercent = UILabel(text: "", font: UIFont.systemFont(ofSize: 14, weight: .regular), color: UIColor.black)
    private var layerLoad = UIView()
    private var timer = Timer()

    convenience init(time: Int, rejectBlock: @escaping (() -> Void),doneBlock: @escaping (() -> Void)) {
        self.init()
        self.maxTime = time
        self.rejectBlock = rejectBlock
        self.doneBlock = doneBlock
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.loading), userInfo: nil, repeats: true)
    }
    
    @objc func loading(){
        layerLoad.snp.remakeConstraints({
            $0.leading.centerY.height.equalToSuperview()
            $0.trailing.equalToSuperview().multipliedBy(maxTime)
        })
    }
    
    @objc func actReject(){
        rejectBlock?()
    }
}

extension PopupLoadingViewController {
    private func setupUI(){
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        let viewContainer = UIView()
        self.view.addSubview(viewContainer)
        viewContainer.snp.makeConstraints({
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.7)
            $0.height.equalTo(viewContainer.snp.width).multipliedBy(0.6)
        })
        
        viewContainer.addSubview(lbTitle)
        lbTitle.snp.makeConstraints({
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
        })
        
        let btnBack = UIButton()
        viewContainer.addSubview(btnBack)
        btnBack.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
            $0.width.equalTo(btnBack.snp.height).multipliedBy(3)
        })
        btnBack.setTitle("Huỷ", for: .normal)
        btnBack.layer.cornerRadius = 4
        btnBack.setTitleColor(.white, for: .normal)
        btnBack.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        btnBack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actReject)))
        
        let vLoad = UIView()
        viewContainer.addSubview(vLoad)
        vLoad.snp.makeConstraints({
            $0.top.equalTo(lbTitle.snp.bottom).offset(2)
            $0.centerX.width.equalToSuperview()
            $0.bottom.equalTo(btnBack.snp.top).offset(-2)
        })
        
        let layerBack = UIView()
        vLoad.addSubview(layerBack)
        layerBack.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        layerBack.snp.makeConstraints({
            $0.height.equalTo(8)
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.8)
        })
        layerBack.addSubview(layerLoad)
        layerLoad.backgroundColor = UIColor(255,128,171)
        layerLoad.snp.makeConstraints({
            $0.leading.equalToSuperview()
            $0.centerY.height.equalToSuperview()
        })
        
        vLoad.addSubview(lbPercent)
        lbPercent.snp.makeConstraints({
            $0.trailing.equalTo(layerBack)
            $0.bottom.equalTo(layerBack.snp.top).offset(-4)
        })
        
    }
}
