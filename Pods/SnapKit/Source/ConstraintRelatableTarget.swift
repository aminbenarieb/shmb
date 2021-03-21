#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

public protocol ConstraintRelatableTarget {}

extension Int: ConstraintRelatableTarget {}

extension UInt: ConstraintRelatableTarget {}

extension Float: ConstraintRelatableTarget {}

extension Double: ConstraintRelatableTarget {}

extension CGFloat: ConstraintRelatableTarget {}

extension CGSize: ConstraintRelatableTarget {}

extension CGPoint: ConstraintRelatableTarget {}

extension ConstraintInsets: ConstraintRelatableTarget {}

#if os(iOS) || os(tvOS)
    @available(iOS 11.0, tvOS 11.0, *)
    extension ConstraintDirectionalInsets: ConstraintRelatableTarget {}
#endif

extension ConstraintItem: ConstraintRelatableTarget {}

extension ConstraintView: ConstraintRelatableTarget {}

@available(iOS 9.0, OSX 10.11, *)
extension ConstraintLayoutGuide: ConstraintRelatableTarget {}
