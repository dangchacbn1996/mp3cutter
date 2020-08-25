//
//  IntroduceViewController.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/26/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift

class IntroduceViewController: UIViewController {
    
    var currentPage = 1;
    var totalPage = 8;
    private let pageControl = UIPageControl()
    private let viewContainer = UIView()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView(axis: .horizontal, distribution: .fillEqually, alignment: .fill, spacing: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @objc func switchPage(_ sender: UIPanGestureRecognizer) {
        let velocity = sender.velocity(in: self.scrollView)
        let isLeft = (velocity.x < 0)
        
        if(sender.state == UIGestureRecognizer.State.ended)
        {
            if isLeft {
                if currentPage < totalPage {
                    currentPage = currentPage + 1
                }
            }
            else {
                if currentPage > 1 {
                    currentPage = currentPage - 1
                }
            }
            moveToPage()
        }
    }
    
    func moveToPage(){
        pageControl.currentPage = currentPage - 1
        var frame: CGRect = self.scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(currentPage - 1)
        print("NewFrame: \(frame.origin.x)")
        frame.origin.y = 0
        self.scrollView.scrollRectToVisible(frame, animated: true)
    }
    
    @objc func btnStartClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension IntroduceViewController {
    func setupUI(){
//        self.view.addSubview(viewContainer)
//        viewContainer.snp.makeConstraints({
//            $0.center.equalToSuperview()
//            if #available(iOS 11.0, *) {
//                $0.width.height.equalTo(self.view.safeAreaLayoutGuide).multipliedBy(0.95)
//            } else {
//                $0.width.height.equalToSuperview().multipliedBy(0.9)
//            }
//        })
//        viewContainer.backgroundColor = .white
//        viewContainer.layer.cornerRadius = 6
//
//        viewContainer.addSubview(scrollView)
//        scrollView.snp.makeConstraints({
//            $0.height.equalToSuperview().offset(-52)
//            $0.centerX.width.leading.trailing.equalToSuperview()
//            $0.top.equalToSuperview().offset(8)
//        })
//        scrollView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.switchPage(_:))))
//        scrollView.showsHorizontalScrollIndicator = false
//
//        scrollView.addSubview(stackView)
//        stackView.snp.makeConstraints({
//            $0.leading.trailing.equalToSuperview()
//            $0.top.equalToSuperview().offset(8)
//            $0.width.equalToSuperview().multipliedBy(totalPage)
//        })
//
//        viewContainer.addSubview(pageControl)
//        pageControl.snp.makeConstraints({
//            $0.centerX.equalToSuperview()
//            $0.top.equalTo(stackView.snp.bottom)
//            $0.width.equalTo(100)
//            $0.height.equalTo(36)
//        })
//        pageControl.currentPage = currentPage
//        pageControl.numberOfPages = totalPage
//        pageControl.pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.5)
//        pageControl.currentPageIndicatorTintColor = UIColor(hexString: "383850")
//
//        let buttonClose = UIButton()
//        viewContainer.addSubview(buttonClose)
//        buttonClose.snp.makeConstraints({
//            $0.centerX.equalToSuperview()
//            $0.bottom.equalToSuperview().offset(-16)
//            $00.top.equalTo(pageControl.snp.bottom).offset(8)
//            $0.width.equalTo(32 * 3.5)
//            $0.height.equalTo(32)
//        })
//        buttonClose.layer.cornerRadius = 16
//        buttonClose.setTitle("Đóng", for: .normal)
//        buttonClose.backgroundColor = UIColor(hexString: "F06292")
//        buttonClose.setTitleColor(.white, for: .normal)
//        buttonClose.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.btnStartClick(_:))))
        
        self.view.addSubview(viewContainer)
        viewContainer.snp.makeConstraints({
            $0.center.equalToSuperview()
            if #available(iOS 11.0, *) {
                $0.width.height.equalTo(self.view.safeAreaLayoutGuide).multipliedBy(0.95)
            } else {
                $0.width.height.equalToSuperview().multipliedBy(0.95)
            }
        })
        viewContainer.backgroundColor = .white
        viewContainer.layer.cornerRadius = 6
        
        viewContainer.addSubview(scrollView)
        scrollView.snp.makeConstraints({
            $0.height.equalToSuperview().offset(-74)
            $0.centerX.width.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(8)
        })
        scrollView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.switchPage(_:))))
        
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12)
            $0.top.equalToSuperview().offset(8)
            $0.height.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(totalPage)
        })
        
        viewContainer.addSubview(pageControl)
        pageControl.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(36)
            //            $0.top.equalTo(scrollView.snp.bottom)
        })
        
        let buttonClose = UIButton()
        viewContainer.addSubview(buttonClose)
        buttonClose.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
            $00.top.equalTo(pageControl.snp.bottom).offset(8)
            $0.width.equalTo(32 * 3.5)
            $0.height.equalTo(32)
        })
        buttonClose.layer.cornerRadius = 16
        buttonClose.setTitle("Đóng".localized(), for: .normal)
        buttonClose.backgroundColor = UIColor(hexString: "F06292")
        buttonClose.setTitleColor(.white, for: .normal)
        buttonClose.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.btnStartClick(_:))))
        
        
        
        let lang = Localize.currentLanguage()
        var pos_lang = "vi"
        if lang.contains("vi") {
            pos_lang = "vi"
        } else {
            pos_lang = "en"
        }
        for index in 0..<totalPage {
            let subView = UIView()
            let imageName = "intro_step\(index + 1)_\(pos_lang)"
            let imageView = UIImageView(image: UIImage(named: imageName))
            stackView.addArrangedSubview(subView)
            subView.addSubview(imageView)
            imageView.snp.makeConstraints({
                $0.top.bottom.height.equalToSuperview()
                $0.width.equalTo(viewContainer.snp.width)
            })
            imageView.contentMode = .scaleToFill
            
        }
        
        pageControl.currentPage = currentPage
        pageControl.numberOfPages = totalPage
        pageControl.pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.5)
        pageControl.currentPageIndicatorTintColor = UIColor(hexString: "383850")
    }
}
