import Foundation

struct LoadingInfo {
    let position: Position; enum Position {
        case top
        case bottom
    }
}

extension LoadingInfo: Hashable {}
extension LoadingInfo.Position: Hashable {}
