//
//  MediaParser.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/17/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import Foundation
import AVKit
import CoreAudioKit

class MediaPascer {
    
    static let shared = MediaPascer()
    
    func audioURLParse(info: MediaInfoModel, newURL: URL, asset: AVAsset, starting: CMTime, ending: CMTime, failed: @escaping ((String) -> Void), success: @escaping() -> Void) -> Void
    {
        exportFile(info: info, newURL: newURL, asset: asset, timeRange: CMTimeRangeFromTimeToTime(start: starting, end: ending), failed: failed, success: success)
    }
    
//    func merge(audio1: NSURL, audio2:  NSURL) {
//
//
//        var error:NSError?
//
//        var ok1 = false
//        var ok2 = false
//
//
////        var documentsDirectory:String = paths[0] as! String
//
//        //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
//        var composition = AVMutableComposition()
//        var compositionAudioTrack1: AVMutableCompositionTrack? =
//            composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())
//        var compositionAudioTrack2:AVMutableCompositionTrack? = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())
//
//        //create new file to receive data
//        var documentDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as! NSURL
//        var fileDestinationUrl = documentDirectoryURL.URLByAppendingPathComponent("resultmerge.wav")
//        println(fileDestinationUrl)
//
//
//        var url1 = audio1
//        var url2 = audio2
//
//
//        var avAsset1 = AVURLAsset(URL: url1, options: nil)
//        var avAsset2 = AVURLAsset(URL: url2, options: nil)
//
//        var tracks1 =  avAsset1.tracksWithMediaType(AVMediaTypeAudio)
//        var tracks2 =  avAsset2.tracksWithMediaType(AVMediaTypeAudio)
//
//        var assetTrack1:AVAssetTrack = tracks1[0] as! AVAssetTrack
//        var assetTrack2:AVAssetTrack = tracks2[0] as! AVAssetTrack
//
//
//        var duration1: CMTime = assetTrack1.timeRange.duration
//        var duration2: CMTime = assetTrack2.timeRange.duration
//
//        var timeRange1 = CMTimeRangeMake(kCMTimeZero, duration1)
//        var timeRange2 = CMTimeRangeMake(duration1, duration2)
//
//
//        ok1 = compositionAudioTrack1.insertTimeRange(timeRange1, ofTrack: assetTrack1, atTime: kCMTimeZero, error: nil)
//        if ok1 {
//
//            ok2 = compositionAudioTrack2.insertTimeRange(timeRange2, ofTrack: assetTrack2, atTime: duration1, error: nil)
//
//            if ok2 {
//                println("success")
//            }
//        }
//
//        //AVAssetExportPresetPassthrough => concatenation
//
//    }
    
    private func exportFile(info: MediaInfoModel, newURL: URL, asset: AVAsset, timeRange: CMTimeRange? = nil, failed: @escaping (String) -> Void, success: @escaping () -> Void){
        guard let session = AVAssetExportSession(asset: asset, presetName: info.presetName) else { return }
        session.outputURL = newURL
        if timeRange != nil {
            session.timeRange = timeRange!
        }
        session.outputFileType = .m4a
        session.exportAsynchronously {
            switch session.status {
            case  AVAssetExportSessionStatus.failed:
                
                if let e = session.error {
                    failed("export failed \(e)")
                }
                
            case AVAssetExportSessionStatus.cancelled:
                failed("export cancelled \(String(describing: session.error))")
            default:
                break
                // change core data data here
            }
            success()
        }
    }
}

@objc extension AVAudioFile {

    // MARK: - Public Properties

    /// The number of samples can be accessed by .length property,
    /// but samplesCount has a less ambiguous meaning
    open var samplesCount: Int64 {
        return length
    }

    /// strange that sampleRate is a Double and not an Integer
    open var sampleRate: Double {
        return fileFormat.sampleRate
    }
    /// Number of channels, 1 for mono, 2 for stereo
    open var channelCount: UInt32 {
        return fileFormat.channelCount
    }

    /// Duration in seconds
    open var duration: Double {
        return Double(samplesCount) / (sampleRate)
    }

    /// true if Audio Samples are interleaved
    open var interleaved: Bool {
        return fileFormat.isInterleaved
    }

    /// true only if file format is "deinterleaved native-endian float (AVAudioPCMFormatFloat32)"
    open var standard: Bool {
        return fileFormat.isStandard
    }

    /// Human-readable version of common format
    open var commonFormatString: String {
        return "\(fileFormat.commonFormat)"
    }

    /// the directory path as a URL object
    open var directoryPath: URL {
        return url.deletingLastPathComponent()
    }

    /// the file name with extension as a String
    open var fileNamePlusExtension: String {
        return url.lastPathComponent
    }

    /// the file name without extension as a String
    open var fileName: String {
        return url.deletingPathExtension().lastPathComponent
    }

    /// the file extension as a String (without ".")
    open var fileExt: String {
        return url.pathExtension
    }

    open override var description: String {
        return super.description + "\n" + String(describing: fileFormat)
    }

    /// returns file Mime Type if exists
    /// Otherwise, returns nil
    /// (useful when sending an AKAudioFile by email)
    public var mimeType: String? {
        switch fileExt.lowercased() {
        case "wav":
            return "audio/wav"
        case "caf":
            return "audio/x-caf"
        case "aif", "aiff", "aifc":
            return "audio/aiff"
        case "m4r":
            return "audio/x-m4r"
        case "m4a":
            return "audio/x-m4a"
        case "mp4":
            return "audio/mp4"
        case "m2a", "mp2":
            return "audio/mpeg"
        case "aac":
            return "audio/aac"
        case "mp3":
            return "audio/mpeg3"
        default:
            return nil
        }
    }

    /// Static function to delete all audiofiles from Temp directory
    ///
    /// AKAudioFile.cleanTempDirectory()
    ///
    public static func cleanTempDirectory() {
        var deletedFilesCount = 0

        let fileManager = FileManager.default
        let tempPath = NSTemporaryDirectory()

        do {
            let fileNames = try fileManager.contentsOfDirectory(atPath: "\(tempPath)")

            // function for deleting files
            func deleteFileWithFileName(_ fileName: String) {
                let filePathName = "\(tempPath)/\(fileName)"
                do {
                    try fileManager.removeItem(atPath: filePathName)
                    print("\"\(fileName)\" deleted.")
                    deletedFilesCount += 1
                } catch let error as NSError {
                    print("Couldn't delete \(fileName) from Temp Directory " + error.localizedDescription)
                }
            }

            // Checks file type (only Audio Files)
            fileNames.forEach { fn in
                let lower = fn.lowercased()
                _ = [".wav", ".caf", ".aif", ".mp4", ".m4a"].first {
                    lower.hasSuffix($0)
                }.map { _ in
                    deleteFileWithFileName(fn)
                }
            }

            print("\(deletedFilesCount) files deleted")

        } catch let error as NSError {
            print("Couldn't access Temp Directory " + error.localizedDescription)
        }
    }

}
