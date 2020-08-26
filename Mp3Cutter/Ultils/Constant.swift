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

    static var actCut = ActionType(type: .cut, text: "Cắt âm thanh".localized(), color: UIColor(hexString: "FCACAE"))
    static var actMerge = ActionType(type: .merge, text: "Ghép âm thanh".localized(), color: UIColor(hexString: "707DF6"))
    static var actConvert = ActionType(type: .convert, text: "Chuyển định dạng".localized(), color: UIColor(hexString: "F7CF53"))
    static var actVideo = ActionType(type: .video, text: "Cắt video".localized(), color: UIColor(hexString: "F2AA8E"))
    static var actCollection = ActionType(type: .collection, text: "Bộ sưu tập của tôi".localized(), color: UIColor(hexString: "42A5F5"))
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
