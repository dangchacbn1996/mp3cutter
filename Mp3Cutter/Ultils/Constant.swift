//
//  Constant.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/16/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    convenience init(hexString: String) {
        
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (0, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1)
    }
}

enum ListType : Int {
    case cut = 0
    case merge = 1
    case convert = 2
    case video = 4
    case collection = 5
}

struct ActionType{
    var type: ListType
    var text: String
    var color: UIColor
    
    static func getType(_ type: ListType) -> ActionType {
        return ActionType.getType(type.rawValue)
    }
    
    static func getType(_ index: Int) -> ActionType {
           switch index {
           case ListType.cut.rawValue:
               return ActionType.actCut
           case ListType.merge.rawValue:
               return ActionType.actMerge
           case ListType.convert.rawValue:
               return ActionType.actConvert
           case ListType.video.rawValue:
               return ActionType.actVideo
           default:
               return ActionType.actCollection
           }
       }

    static let actCut = ActionType(type: .cut, text: "Cắt âm thanh", color: UIColor(255,128,171).withAlphaComponent(0.7))
    static let actMerge = ActionType(type: .merge, text: "Ghép âm thanh", color: UIColor(red: 63/255.0, green: 81/255.0, blue: 181/255.0, alpha: 1).withAlphaComponent(0.7))
    static let actConvert = ActionType(type: .convert, text: "Chuyển định dạng", color: UIColor(red: 253/255.0, green: 216/255.0, blue: 53/255.0, alpha: 1).withAlphaComponent(0.7))
    static let actVideo = ActionType(type: .video, text: "Cắt video", color: UIColor(red: 244/255.0, green: 81/255.0, blue: 30/255.0, alpha: 1).withAlphaComponent(0.7))
    static let actCollection = ActionType(type: .collection, text: "Bộ sưu tập của tôi", color: UIColor(red: 2/255.0, green: 136/255.0, blue: 209/255.0, alpha: 1).withAlphaComponent(0.7))
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
