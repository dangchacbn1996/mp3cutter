//
//  UserDefaultManager.swift
//  Audience
//
//  Created by 이요한 on 2020/01/03.
//  Copyright © 2020 yo. All rights reserved.
//

import Foundation
import UIKit

class UserDefaultManager {
  
  static let sharedInsatance = UserDefaultManager()
  static let defaults = UserDefaults.standard
  
  
  static func saveMusicList(_ musicName: [String]) {
    defaults.set(musicName, forKey: "musicNameForSave" )
  }
  static func getMusicList() -> [String]? {
    return defaults.array(forKey: "musicNameForSave") as? [String]
  }
  
  static func saveLastPlayMusic(list: String) {
    defaults.set(list, forKey: "lastPlay")
  }
  static func getLastPlayMusic() -> String? {
    return defaults.string(forKey: "lastPlay")}
  
  static func saveLastMusicTime(time: Int) {
    defaults.set(time, forKey: "lastMusicTime")
  }
  static func getLastMusicTime() -> TimeInterval {
    return TimeInterval(defaults.integer(forKey: "lastMusicTime"))
  }
  
  
  static func saveProgressBarStyle(_ style: String?) {
    defaults.set(style, forKey: "progressBarStyle")
  }
  static func getProgressBarStyle() -> String? {
    return defaults.string(forKey: "StringprogressBarStyle")
  }
  
  static func saveBigIconJumpValue(second: Int) {
    defaults.set(second, forKey: "firstPrevious")
  }
  static func getBigIconJumpValue() -> Int? {
    return defaults.integer(forKey: "firstPrevious")
  }

  static func saveSmallIconJumpValue(second: Int) {
    defaults.set(second, forKey: "secondPrevious")
  }
  static func getSmallIconJumpValue() -> Int? {
    return defaults.integer(forKey: "secondPrevious")
  }

  
}
