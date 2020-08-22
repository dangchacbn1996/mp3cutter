//
//  MediaInfoModel.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/21/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import Foundation
import AVKit

enum ExportType : String{
    case wav = "WAV"
    case m4a = "M4A"
    case caf = "CAF"
    case aif = "AIF"
//    case aifc = "AIFC"
//    "wav", "aif", "caf", "m4a"
//    "mp3",
//    "snd",
//    "au",
//    "sd2",
//    "aiff",
//    "aifc",
//    "aac",
//    "mp4",
//    "m4v",
//    "mov",
}

enum SoundQuality : String {
    case kbps128 = "128Kbps"
    case kbps320 = "320Kbps"
}
enum SoundType : String {
    case ringtone = "Nhạc chuông"
    case warning = "Âm báo"
    case audioFile = "File nhạc"
}

class MediaInfoModel {
    var name: String = ""
    var url: [URL] = []
    var typeExport = ExportType.m4a
    var videoQuality = AVAssetExportPresetLowQuality
    var typeQuality = SoundQuality.kbps128
    var typeTarget = SoundType.audioFile
    
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
