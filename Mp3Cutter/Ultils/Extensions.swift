//
//  Extensions.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/16/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import Foundation
import UIKit

extension UIStackView {
    convenience init(axis : NSLayoutConstraint.Axis, distribution : UIStackView.Distribution, alignment : UIStackView.Alignment, spacing : CGFloat, edgeInset : UIEdgeInsets? = nil, custom: ((UIStackView) -> Void)? = nil){
        
        self.init(frame: .zero)
        self.axis = axis
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
        
        if (edgeInset != nil) {
            self.layoutMargins = edgeInset ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.isLayoutMarginsRelativeArrangement = true
        }
        custom?(self)
    }
}
