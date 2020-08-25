//
//  UIUltils.swift
//  Mp3Cutter
//
//  Created by Chac Ngo Dang on 8/26/20.
//  Copyright © 2020 Chac Ngo Dang. All rights reserved.
//

import Foundation
import UIKit

class UIUltils  {
    static func indexPathFrom(_ tableView : UITableView, gesture : UIGestureRecognizer) -> (IndexPath?) {
        let pos = gesture.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: pos) {
            return indexPath
        }
        return nil
    }
}
