//
//  ItemTableViewCell.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/11/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import UIKit
import M13Checkbox

class ItemTableViewCell: UITableViewCell {
    
    static let id = "ItemTableViewCell"
    static let cellHeight: CGFloat = 56
    
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbSub: UILabel!
    @IBOutlet weak var vIcon: UIView!
    @IBOutlet weak var vCheckBox: UIView!
    private var checkBox = M13Checkbox()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        // Initialization code
    }
    
    func checkOn(isOn: Bool? = nil){
        let check = isOn ?? (checkBox.checkState == .checked ? false : true)
        checkBox.setCheckState(check ? .checked : .unchecked, animated: true)
    }
    
    func bind(title: String, sub: String, checkColor: UIColor?, showCheck: Bool) {
        lbName.text = title
        lbSub.text = sub
        checkBox.tintColor = checkColor
        checkBox.secondaryTintColor = checkColor
        checkBox.alpha = showCheck ? 1 : 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupUI(){
        vCheckBox.addSubview(checkBox)
        checkBox.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
        checkBox.checkmarkLineWidth = 3
        checkBox.boxType = .square
        checkBox.setCheckState(.unchecked, animated: false)
        checkBox.isUserInteractionEnabled = false
    }
    
}
