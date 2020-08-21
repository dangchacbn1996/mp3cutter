//
//  MediaInfoModel.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/21/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import Foundation
import AVKit

//enum ExportType : String{
//    case mp3 = "MP3"
//    case m4a = "M4A"
//    case acc = "ACC"
//}

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
    var url: URL = URL(fileURLWithPath: "")
    var typeExport = AVFileType.m4a
    var videoQuality = AVAssetExportPresetLowQuality
    var typeQuality = SoundQuality.kbps128
    var typeTarget = SoundType.audioFile
    
    var extensionFile : String {
        get {
            switch typeExport {
            case .m4a:
                return "m4a"
            case .aiff:
                return "aiff"
            case .mov:
                return "mov"
            default:
                return ""
            }
        }
    }
    
    var fileName : String {
        get {
            return name + typeExport.rawValue
        }
    }
    
    var presetName : String {
        get {
            switch typeExport {
            case .m4a:
                return AVAssetExportPresetAppleM4A
            case .aiff:
                return AVAssetExportPresetMediumQuality
            case .mov:
                return AVAssetExportPresetMediumQuality
            default:
                return AVAssetExportPresetAppleM4A
            }
        }
    }
}
