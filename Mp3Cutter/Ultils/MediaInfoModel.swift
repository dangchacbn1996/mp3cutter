//
//  MediaInfoModel.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/21/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import Foundation
import AVKit

enum ExtensionType : String{
    case wav = "WAV"
    case m4a = "M4A"
    case caf = "CAF"
    case aif = "AIF"
}

enum SoundType : Int{
    case ringtone = 0
    case music = 1
    case video = 2
}

enum SoundQuality : String {
    case kbps128 = "128Kbps"
    case kbps320 = "320Kbps"
}

class MediaInfoModel {
    var name: String = ""
    var url: [URL] = []
    var typeExport = ExtensionType.m4a
    var videoQuality = AVAssetExportPresetLowQuality
    var typeQuality = SoundQuality.kbps128
    
    var extensionFile : String {
        get {
            return typeExport.rawValue.lowercased()
//            switch typeExport {
//            case .m4a:
//                return "m4a"
//            case .aiff:
//                return "aiff"
//            case .mov:
//                return "mov"
//            default:
//                return ""
//            }
        }
    }
    
    var fileName : String {
        get {
            return name + typeExport.rawValue
        }
    }
    
//    var presetName : String {
//        get {
//            switch typeExport {
//            case .m4a:
//                return AVAssetExportPresetAppleM4A
//            case .aiff:
//                return AVAssetExportPresetMediumQuality
//            case .mov:
//                return AVAssetExportPresetMediumQuality
//            default:
//                return AVAssetExportPresetAppleM4A
//            }
//        }
//    }
}
