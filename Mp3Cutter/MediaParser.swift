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

class MediaPascer : NSObject {
    
    static let shared = MediaPascer()
    
    func convert(url: URL, newName: String){
        print("")
//        let command = "/Users/chacnd/Library/Developer/CoreSimulator/Devices/5FCF7F7F-D00D-45C4-AF2E-2C83BA1FDD19/data/Containers/Data/Application/74D17DFD-BBAE-4326-8D94-D1E7FC7AAA79/Documents/Newname.m4a \(url.lastPathComponent) -codec copy \(newName).aac"
//        let command = "/Users/chacnd/Library/Developer/CoreSimulator/Devices/5FCF7F7F-D00D-45C4-AF2E-2C83BA1FDD19/data/Containers/Data/Application/74D17DFD-BBAE-4326-8D94-D1E7FC7AAA79/Documents/Newname.m4a Newname.m4a -codec copy \(Newname).aac"
//        MobileFFmpeg.executeAsync(command, withCallback: self)
    }
    
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
    
    
    
    private func exportFile(info: MediaInfoModel, newURL: URL, asset: AVAsset, timeRange: CMTimeRange? = nil, failed: @escaping (String) -> Void, success: @escaping () -> Void){
        
        guard let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else { return }
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
                success()
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
    
//    var convertVideo = function (source, format, output, success, failure, progress) {
//
//        var converter = ffmpeg(source);
//
//        var audioCodec = "libvorbis";
//
//        if (format.indexOf("mp4") != -1) {
//            audioCodec = "aac";
//        }
//
//        converter.format(format)
//            .withVideoBitrate(1024)
//            .withAudioCodec(audioCodec)
//            .on('end', success)
//            .on('progress', progress)
//            .on('error', failure);
//
//        converter.save(output);
//    };
    
//    func create(){
//        
//
//        if CommandLine.argc < 2 {
//            print("Usage: \(CommandLine.arguments[0]) <input file>")
//            exit(1)
//        }
//        let input = CommandLine.arguments[1]
//
//        do {
//            let fmtCtx = try AVFormatContext(url: input)
//            try fmtCtx.findStreamInfo()
//            
//            fmtCtx.dumpFormat(isOutput: false)
//            
//            guard let stream = fmtCtx.audioStream else {
//                fatalError("No audio stream.")
//            }
//            guard let codec = AVCodec.findDecoderById(stream.codecParameters.codecId) else {
//                fatalError("Codec not found.")
//            }
//            let codecCtx = AVCodecContext(codec: codec)
//            codecCtx.setParameters(stream.codecParameters)
//            try codecCtx.openCodec()
//            
//            let pkt = AVPacket()
//            let frame = AVFrame()
//            
//            while let _ = try? fmtCtx.readFrame(into: pkt) {
//                defer { pkt.unref() }
//                
//                if pkt.streamIndex != stream.index {
//                    continue
//                }
//                
//                try codecCtx.sendPacket(pkt)
//                
//                while true {
//                    do {
//                        try codecCtx.receiveFrame(frame)
//                    } catch let err as AVError where err == .tryAgain || err == .eof {
//                        break
//                    }
//                    
//                    
//                    let str = String(
//                        format: "Frame %3d (type=%@, size=%5d bytes) pts %4lld key_frame %d",
//                        codecCtx.frameNumber,
//                        frame.pictureType.description,
//                        frame.pktSize,
//                        frame.pts,
//                        frame.isKeyFrame
//                    )
//                    
//                    frame.unref()
//                }
//            }
//        } catch {
//            print("Error")
//        }
//
//        print("Done.")
//    }
    
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
