//
//  AVPlay.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/22/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import Foundation
import JGProgressHUD

class Loading {
    static let sharedInstance = Loading()
    var progress = JGProgressHUD(style: .dark)
    private init() {
    }
    
    func show(in view: UIView){
        progress.show(in: view)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
//            if (self.progress.isVisible) {
////                Toast.shared.makeToastNotification(mess: "Tốc độ kết nối Internet không đủ nhanh!", inView: view)
//                self.dismiss()
//            }
//        }
    }
    
    func show(in view: UIView, deadline : Double){
        progress.show(in: view)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + deadline) {
            if (self.progress.isVisible) {
                //                Toast.shared.makeToastNotification(mess: "Tốc độ kết nối Internet không đủ nhanh!", inView: view)
                self.dismiss()
            }
        }
    }
    
    func dismiss(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.progress.dismiss()
        }
        
    }
}
