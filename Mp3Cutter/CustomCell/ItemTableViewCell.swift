//
//  ItemTableViewCell.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/11/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import UIKit
import M13Checkbox
import MGSwipeTableCell
import AVFoundation
import MediaPlayer

class ItemTableViewCell: MGSwipeTableCell{
    
    static let id = "ItemTableViewCell"
    static let cellHeight: CGFloat = 56
    
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbExt: UILabel!
    @IBOutlet weak var lbSub: UILabel!
    @IBOutlet weak var vIcon: UIView!
    @IBOutlet weak var vCheckBox: UIView!
    @IBOutlet weak var btnMore: UIButton!
    private var checkBox = M13Checkbox()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        lbExt.adjustsFontSizeToFitWidth = true
        // Initialization code
    }
    
    func isOn() -> Bool {
        return checkBox.checkState == .checked
    }
    
    func checkOn(isOn: Bool? = nil){
        let check = isOn ?? (checkBox.checkState == .checked ? false : true)
        checkBox.setCheckState(check ? .checked : .unchecked, animated: true)
    }
    
    func bind(_ data: MPMediaItem, checkColor: UIColor?, showCheck: Bool) {
        var artist = data.artist ?? "Artist"
        if let url = data.assetURL {
            let asset = AVAsset(url: url)
            artist += NSString(format: " | %02d:%02d", Int(asset.duration.seconds/60), Int(asset.duration.seconds.truncatingRemainder(dividingBy: 60))) as String
        }
        self.btnMore.alpha = 0
        self.btnMore.isUserInteractionEnabled = false
        self.bind(title: data.title ?? "NONAME", sub: artist, ext: data.assetURL?.pathExtension ?? "", checkColor: checkColor, showCheck: showCheck)
    }
    
    func bind(_ data: MusicData, checkColor: UIColor?, showCheck: Bool) {
        var sub = (data.artist ?? "") == "" ? "" : "\(data.artist!) | "
        sub += NSString(format: "%02d:%02d", Int(data.asset.duration.seconds/60), Int(data.asset.duration.seconds.truncatingRemainder(dividingBy: 60))) as String
        self.btnMore.alpha = 1
        self.btnMore.isUserInteractionEnabled = true
        self.bind(title: data.title ?? "NONAME", sub: sub, ext: data.url?.pathExtension ?? "", checkColor: checkColor, showCheck: showCheck)
    }
    
    func bind(title: String, sub: String, ext: String, checkColor: UIColor?, showCheck: Bool) {
        lbName.text = title
        lbSub.text = sub
        lbExt.text = ext
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
        btnMore.setImage(UIImage(named: "ic_more")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnMore.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 8)
        btnMore.imageView?.tintColor = Constant.viewGray
        btnMore.imageView?.contentMode = .scaleAspectFit
        vIcon.layer.cornerRadius = (ItemTableViewCell.cellHeight - 16) / 2
    }
    
}
