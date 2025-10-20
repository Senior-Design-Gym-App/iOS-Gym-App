import Foundation
import SwiftUI

//extension Int {
//    var plural: String {
//        self == 1 ? "" : "s"
//    }
//}

extension Double {
    var oneDecimal: String {
        String(format: "%.1f", self)
    }
}
