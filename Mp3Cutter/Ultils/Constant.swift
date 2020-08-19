//
//  Constant.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/16/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import Foundation
import UIKit

struct ActionType{
    var type: ListType
    var text: String
    var color: UIColor
    
    static let actCut = ActionType(type: .cut, text: "Cắt âm thanh", color: UIColor.red.withAlphaComponent(0.5))
    static let actMerge = ActionType(type: .merge, text: "Ghép âm thanh", color: UIColor.blue.withAlphaComponent(0.5))
    static let actConvert = ActionType(type: .convert, text: "Chuyển định dạng", color: UIColor.yellow.withAlphaComponent(0.5))
    static let actVideo = ActionType(type: .video, text: "Cắt video", color: UIColor.orange.withAlphaComponent(0.5))
    static let actCollection = ActionType(type: .collection, text: "Bộ sưu tập của tôi", color: UIColor.cyan.withAlphaComponent(0.5))
}

class Constant {
    struct Text {
        static let fontNormal = UIFont.systemFont(ofSize: 14)
        static let fontSmall = UIFont.systemFont(ofSize: 12)
        static let colorBlack = UIColor.black
        static let colorGray = UIColor.gray.withAlphaComponent(0.9)
    }
    static let viewCorner : CGFloat = 4
    static let viewGray = UIColor.gray.withAlphaComponent(0.6)
    static let backPopup = UIColor.black.withAlphaComponent(0.7)
    static let viewBorder = UIColor.gray.withAlphaComponent(0.6).cgColor
}
