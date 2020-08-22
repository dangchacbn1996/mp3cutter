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
import AudioKit

class MediaPascer {
    
    static let shared = MediaPascer()
    
    func audioURLParse(info: MediaInfoModel, newURL: URL, asset: AVAsset, starting: CMTime? = nil, ending: CMTime? = nil, failed: @escaping ((String) -> Void), success: @escaping () -> Void) -> Void
    {
        var timeRange : CMTimeRange!
        if starting == nil || ending == nil {
            timeRange = nil
        } else {
            timeRange = CMTimeRangeFromTimeToTime(start: starting!, end: ending!)
        }
        exportFile(info: info, newURL: newURL, asset: asset, timeRange: timeRange, failed: failed, success: success)
    }
    
    func mergeFilesWithUrl(info: MediaInfoModel, newURL: URL, listURL: [URL], failed: @escaping ((String) -> Void), success: @escaping () -> Void) -> Void
    {

//        let mixComposition : AVMutableComposition = AVMutableComposition()
//
//        var mutableCompositionVideoTrack : [AVMutableCompositionTrack] = []
//        var mutableCompositionAudioTrack : [AVMutableCompositionTrack] = []
//        var mutableCompositionAudioOfVideoTrack : [AVMutableCompositionTrack] = []
//        let totalVideoCompositionInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()

        var listAsset : [AVAsset] = []
        listURL.forEach({
            listAsset.append(AVAsset(url: $0))
        })

        let composition = AVMutableComposition()
        listURL.forEach({
            let audioAsset = AVURLAsset(url: $0, options: nil)
            let audioTrack: AVMutableCompositionTrack? = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            let error: Error?
            do {
                try? audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: audioAsset.duration), of: audioAsset.tracks(withMediaType: AVMediaType.audio)[0], at: composition.duration)
                print("AddTrack: \($0.lastPathComponent) \(composition.duration.seconds)")
            } catch {
                DispatchQueue.main.async {
                    failed("Xảy ra lỗi trong quá trình ghép file")
                }
            }
        })
        print("Merge: composition \(composition.tracks.count)")
        exportFile(info: info, newURL: newURL, asset: composition, failed: failed, success: success)

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
        
        guard let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else { return }
//        var string = newURL.absoluteString
//        let length = newURL.pathExtension.count
//        string.removeLast(length)
//        string += "m4a"
        var clipboardURL = newURL
        clipboardURL.deletePathExtension()
        clipboardURL.appendPathExtension("m4a")
        session.outputURL = clipboardURL
        if timeRange != nil {
            session.timeRange = timeRange!
        }
        session.outputFileType = .m4a
        session.exportAsynchronously {
            switch session.status {
            case  AVAssetExportSessionStatus.failed:
                
                if let e = session.error {
                    DispatchQueue.main.async {
                        print("export failed \(e)")
                        failed("export failed \(e)")
                    }
                }
                
            case AVAssetExportSessionStatus.cancelled:
                DispatchQueue.main.async {
                    print("export cancelled \(String(describing: session.error))")
                    failed("export cancelled \(String(describing: session.error))")
                }
            case .completed:
                if newURL.pathExtension == "m4a" {
                    DispatchQueue.main.async {
                        success()
                    }
                    return
                } else {
                    let convert = AKConverter.init(inputURL: clipboardURL, outputURL: newURL)
                    convert.start { (error) in
                        if error == nil {
                            DispatchQueue.main.async {
                                do {
                                    try? FileManager.default.removeItem(atPath: clipboardURL.path)
                                } catch {
                                    
                                }
                                success()
                            }
                        } else {
                            DispatchQueue.main.async {
                                failed(error?.localizedDescription ?? "")
                            }
                        }
                    }
                }
            default:
                break
                // change core data data here
            }
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
