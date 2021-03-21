#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

public extension ConstraintView {
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_left: ConstraintItem { return self.snp.left }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_top: ConstraintItem { return self.snp.top }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_right: ConstraintItem { return self.snp.right }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_bottom: ConstraintItem { return self.snp.bottom }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_leading: ConstraintItem { return self.snp.leading }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_trailing: ConstraintItem { return self.snp.trailing }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_width: ConstraintItem { return self.snp.width }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_height: ConstraintItem { return self.snp.height }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_centerX: ConstraintItem { return self.snp.centerX }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_centerY: ConstraintItem { return self.snp.centerY }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_baseline: ConstraintItem { return self.snp.baseline }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, OSX 10.11, *)
    var snp_lastBaseline: ConstraintItem { return self.snp.lastBaseline }

    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, OSX 10.11, *)
    var snp_firstBaseline: ConstraintItem { return self.snp.firstBaseline }

    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_leftMargin: ConstraintItem { return self.snp.leftMargin }

    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_topMargin: ConstraintItem { return self.snp.topMargin }

    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_rightMargin: ConstraintItem { return self.snp.rightMargin }

    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_bottomMargin: ConstraintItem { return self.snp.bottomMargin }

    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_leadingMargin: ConstraintItem { return self.snp.leadingMargin }

    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_trailingMargin: ConstraintItem { return self.snp.trailingMargin }

    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_centerXWithinMargins: ConstraintItem { return self.snp.centerXWithinMargins }

    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_centerYWithinMargins: ConstraintItem { return self.snp.centerYWithinMargins }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_edges: ConstraintItem { return self.snp.edges }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_size: ConstraintItem { return self.snp.size }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_center: ConstraintItem { return self.snp.center }

    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_margins: ConstraintItem { return self.snp.margins }

    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_centerWithinMargins: ConstraintItem { return self.snp.centerWithinMargins }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    func snp_prepareConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> [Constraint] {
        return self.snp.prepareConstraints(closure)
    }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    func snp_makeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        self.snp.makeConstraints(closure)
    }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    func snp_remakeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        self.snp.remakeConstraints(closure)
    }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    func snp_updateConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        self.snp.updateConstraints(closure)
    }

    @available(*, deprecated, message: "Use newer snp.* syntax.")
    func snp_removeConstraints() {
        self.snp.removeConstraints()
    }

    var snp: ConstraintViewDSL {
        return ConstraintViewDSL(view: self)
    }
}
