#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    public protocol ConstraintDirectionalInsetTarget: ConstraintConstantTarget {}

    @available(iOS 11.0, tvOS 11.0, *)
    extension ConstraintDirectionalInsets: ConstraintDirectionalInsetTarget {}

    extension ConstraintDirectionalInsetTarget {
        @available(iOS 11.0, tvOS 11.0, *)
        internal var constraintDirectionalInsetTargetValue: ConstraintDirectionalInsets {
            if let amount = self as? ConstraintDirectionalInsets {
                return amount
            }
            else {
                return ConstraintDirectionalInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            }
        }
    }
#endif
