import Foundation
import SwiftUI

func adaptyH(_ baseSize: CGFloat) -> CGFloat {
    let baseScreenHeight: CGFloat = 844
    let screenHeight = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .first?
        .screen.bounds.height ?? baseScreenHeight
    
    return (baseSize / baseScreenHeight) * screenHeight
}

func adaptyW(_ baseWidth: CGFloat) -> CGFloat {
    let baseScreenWidth: CGFloat = 390
    let screenWidth = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .first?
        .screen.bounds.width ?? baseScreenWidth
    
    return (baseWidth / baseScreenWidth) * screenWidth
}

