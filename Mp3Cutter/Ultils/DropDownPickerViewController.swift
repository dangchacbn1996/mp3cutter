//
//  DropDownPickerViewController.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/15/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import UIKit
import SnapKit

protocol DropdownPickerViewDelegate {
    func layoutConstraint(dropdown: DropdownPickerViewController, tableView : UITableView) -> (point : CGPoint, width : CGFloat, height : CGFloat)
    func numberOfRow(dropdown: DropdownPickerViewController, tableView : UITableView) -> (Int)
    func setData(dropdown: DropdownPickerViewController, tableView : UITableView, indexPath : IndexPath) -> (UITableViewCell)
    func didSelect(dropdown: DropdownPickerViewController, tableView : UITableView, index : Int)
    func onShowEffect()
    func onDismissEffect()
    func heightForCell(dropdown: DropdownPickerViewController, tableView: UITableView, indexPath : IndexPath) -> (CGFloat)
}

class DropdownPickerViewController : UIViewController {
    private var sizeContent = CGSize(width: 0, height: 0)
    private var stackMain = UIStackView(axis: .vertical, distribution: .equalSpacing, alignment: .fill, spacing: 0, edgeInset: nil, custom: nil)
    var tablePicker = UITableView()
    private var cellHeight : CGFloat = 32 {
        didSet {
            tablePicker.rowHeight = self.cellHeight
        }
    }
    private var delegate : DropdownPickerViewDelegate? = nil
    private var tbHeight : CGFloat = 0
    private var dummySearch = UITextField()
    private var isSearching = false
    var viewContainer = UIView()
    var viewPos: UIView? = nil
    var indexPath: IndexPath? = nil
    var listData : [String] = []
    var listObj : [Any] = []
    
    convenience init(delegate : DropdownPickerViewDelegate, viewDrop: inout UIView?, background : UIColor? = UIColor.white, border : CGColor?) {
        self.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.viewPos = viewDrop
        self.tablePicker.backgroundColor = background
        self.viewContainer.backgroundColor = background
        self.viewContainer.layer.borderColor = border ?? UIColor.clear.cgColor
        self.viewContainer.layer.borderWidth = border == nil ? 0 : 0.8
        self.modalPresentationStyle = .overCurrentContext
    }
    
    convenience init(delegate : DropdownPickerViewDelegate, background : UIColor? = UIColor.white, border : CGColor?) {
        self.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.tablePicker.backgroundColor = background
        self.viewContainer.backgroundColor = background
        self.viewContainer.layer.borderColor = border ?? UIColor.clear.cgColor
        self.viewContainer.layer.borderWidth = border == nil ? 0 : 0.8
        self.modalPresentationStyle = .overCurrentContext
    }
    
    convenience init(delegate : DropdownPickerViewDelegate, indexPathInTableParent: IndexPath, background : UIColor? = UIColor.white, border : CGColor?) {
        self.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.indexPath = indexPathInTableParent
        self.tablePicker.backgroundColor = background
        self.viewContainer.backgroundColor = background
        self.viewContainer.layer.borderColor = border ?? UIColor.clear.cgColor
        self.viewContainer.layer.borderWidth = border == nil ? 0 : 0.8
        self.modalPresentationStyle = .overCurrentContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindData()
    }
    
    func bindData(){
        let width = delegate?.layoutConstraint(dropdown: self, tableView: tablePicker).width ?? 32
        tbHeight = delegate?.layoutConstraint(dropdown: self, tableView: tablePicker).height ?? 32
        tablePicker.snp.makeConstraints { (maker) in
            maker.width.equalTo(width)
            maker.height.equalTo(tbHeight)
        }
        viewContainer.snp.makeConstraints({
            $0.top.equalToSuperview().offset(delegate?.layoutConstraint(dropdown: self, tableView: tablePicker).point.y ?? 0)
            $0.leading.equalToSuperview().offset(delegate?.layoutConstraint(dropdown: self, tableView: tablePicker).point.x ?? 0)
            $0.width.equalTo(width)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tablePicker.reloadData()
//        if ((delegate?.numberOfRow(dropdown: self, tableView: tablePicker) ?? 0) > 0) {
            delegate?.onShowEffect()
            UIView.animate(withDuration: 0.2) {
                self.tablePicker.isHidden = false
            }
//        } else {
//            ToastView.makeToast("NBO Cannot find data!".localized(), type: .ERROR)
//            self.dismiss()
//        }
    }
    
    func dismiss(){
        UIView.animate(withDuration: 0.2, animations: {
            self.tablePicker.isHidden = true
        }) { (success) in
            self.dismiss(animated: false, completion: nil)
        }
        delegate?.onDismissEffect()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first?.location(in: self.view)
        if (!viewContainer.frame.contains(touch!)) {
            dismiss()
        }
    }
}

extension DropdownPickerViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return delegate?.setData(dropdown: self, tableView: tableView, indexPath: indexPath) ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.numberOfRow(dropdown: self, tableView: tablePicker) ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return delegate?.heightForCell(dropdown: self, tableView: tableView, indexPath: indexPath) ?? UITableView.automaticDimension
    }
}

extension DropdownPickerViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(dropdown: self, tableView: tablePicker, index: indexPath.row)
        dismiss()
    }
}

extension DropdownPickerViewController {
    func setupUI(){
        self.view.backgroundColor = .clear
        self.view.addSubview(viewContainer)
        viewContainer.layer.cornerRadius = 4
        viewContainer.clipsToBounds = true
        self.viewContainer.addSubview(stackMain)
        stackMain.snp.makeConstraints { (maker) in
            maker.top.leading.bottom.trailing.equalToSuperview()
        }
        stackMain.clipsToBounds = true
        let v = UIView()
        v.backgroundColor = .clear
        v.snp.makeConstraints { (maker) in
            maker.height.equalTo(1)
        }
        stackMain.addArrangedSubview(v)
        stackMain.addArrangedSubview(tablePicker)
        tablePicker.delegate = self
        tablePicker.dataSource = self
        tablePicker.isHidden = true
        tablePicker.tableFooterView = UIView()
        tablePicker.separatorStyle = .singleLine
        tablePicker.separatorColor = UIColor.white.withAlphaComponent(0.2)
        tablePicker.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
