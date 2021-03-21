#if os(iOS) || os(tvOS)
    import UIKit
#endif

@available(iOS 8.0, *)
public extension ConstraintLayoutSupport {
    var snp: ConstraintLayoutSupportDSL {
        return ConstraintLayoutSupportDSL(support: self)
    }
}
