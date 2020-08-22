//
//  ToastView.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/22/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//
import Foundation
import Toast_Swift

class Toast {
    public static let shared = Toast()
    
    var toastStyle : ToastStyle!
    
    private init(){
        toastStyle = ToastStyle()
//        toastStyle.verticalPadding = 30
        toastStyle.backgroundColor = UIColor(hexString: "00ba6d").withAlphaComponent(0.85)
        ToastManager.shared.style = toastStyle
        ToastManager.shared.isTapToDismissEnabled = true
    }
    
    
    public func makeToast(_ type : ToastType = .notifi, string : String?, inView : UIView, time : TimeInterval = 4) {
        switch type {
        case .success:
            toastStyle.backgroundColor = UIColor(hexString: "0288d1")
        case .error:
            toastStyle.backgroundColor = UIColor(hexString: "e65100")
        case .validate:
            toastStyle.backgroundColor = UIColor(hexString: "00ba6d")
        default:
            toastStyle.backgroundColor = UIColor(hexString: "00ba6d")
        }
        if (string ?? "") == "" {
            if type == .error {
                inView.makeToast("Có lỗi xảy ra!", duration: time, position: .bottom, title: "", image: nil, style: toastStyle, completion: nil)
            }
            return
        }
        inView.makeToast(string!, duration: time, position: .bottom, title: "", image: nil, style: toastStyle, completion: nil)
    }

    enum ToastType {
        case notifi
        case error
        case validate
        case success
    }
    
    public func makeToastNotification(mess : String, inView : UIView) {
        if (mess.contains("InvalidSessionException")) {
            inView.makeToast("Mất session, vui lòng đăng nhập lại để tiếp tục", duration: 3, position: .top, title: "", image: nil, style: toastStyle, completion: nil)
        } else {
            inView.makeToast(mess, duration: 3, position: .top, title: "", image: nil, style: toastStyle, completion: nil)
        }
    }
}
