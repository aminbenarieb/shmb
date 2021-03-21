#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

public class ConstraintMaker {
    public var left: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.left)
    }

    public var top: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.top)
    }

    public var bottom: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.bottom)
    }

    public var right: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.right)
    }

    public var leading: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.leading)
    }

    public var trailing: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.trailing)
    }

    public var width: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.width)
    }

    public var height: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.height)
    }

    public var centerX: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.centerX)
    }

    public var centerY: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.centerY)
    }

    @available(*, deprecated, message: "Use lastBaseline instead")
    public var baseline: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.lastBaseline)
    }

    public var lastBaseline: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.lastBaseline)
    }

    @available(iOS 8.0, OSX 10.11, *)
    public var firstBaseline: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.firstBaseline)
    }

    @available(iOS 8.0, *)
    public var leftMargin: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.leftMargin)
    }

    @available(iOS 8.0, *)
    public var rightMargin: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.rightMargin)
    }

    @available(iOS 8.0, *)
    public var topMargin: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.topMargin)
    }

    @available(iOS 8.0, *)
    public var bottomMargin: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.bottomMargin)
    }

    @available(iOS 8.0, *)
    public var leadingMargin: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.leadingMargin)
    }

    @available(iOS 8.0, *)
    public var trailingMargin: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.trailingMargin)
    }

    @available(iOS 8.0, *)
    public var centerXWithinMargins: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.centerXWithinMargins)
    }

    @available(iOS 8.0, *)
    public var centerYWithinMargins: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.centerYWithinMargins)
    }

    public var edges: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.edges)
    }

    public var directionalEdges: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.directionalEdges)
    }

    public var size: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.size)
    }

    public var center: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.center)
    }

    @available(iOS 8.0, *)
    public var margins: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.margins)
    }

    @available(iOS 8.0, *)
    public var directionalMargins: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.directionalMargins)
    }

    @available(iOS 8.0, *)
    public var centerWithinMargins: ConstraintMakerExtendable {
        return self.makeExtendableWithAttributes(.centerWithinMargins)
    }

    private let item: LayoutConstraintItem
    private var descriptions = [ConstraintDescription]()

    internal init(item: LayoutConstraintItem) {
        self.item = item
        self.item.prepare()
    }

    internal func makeExtendableWithAttributes(_ attributes: ConstraintAttributes)
        -> ConstraintMakerExtendable
    {
        let description = ConstraintDescription(item: self.item, attributes: attributes)
        self.descriptions.append(description)
        return ConstraintMakerExtendable(description)
    }

    internal static func prepareConstraints(
        item: LayoutConstraintItem,
        closure: (_ make: ConstraintMaker) -> Void
    ) -> [Constraint] {
        let maker = ConstraintMaker(item: item)
        closure(maker)
        var constraints: [Constraint] = []
        for description in maker.descriptions {
            guard let constraint = description.constraint else {
                continue
            }
            constraints.append(constraint)
        }
        return constraints
    }

    internal static func makeConstraints(
        item: LayoutConstraintItem,
        closure: (_ make: ConstraintMaker) -> Void
    ) {
        let constraints = self.prepareConstraints(item: item, closure: closure)
        for constraint in constraints {
            constraint.activateIfNeeded(updatingExisting: false)
        }
    }

    internal static func remakeConstraints(
        item: LayoutConstraintItem,
        closure: (_ make: ConstraintMaker) -> Void
    ) {
        self.removeConstraints(item: item)
        self.makeConstraints(item: item, closure: closure)
    }

    internal static func updateConstraints(
        item: LayoutConstraintItem,
        closure: (_ make: ConstraintMaker) -> Void
    ) {
        guard !item.constraints.isEmpty else {
            self.makeConstraints(item: item, closure: closure)
            return
        }

        let constraints = self.prepareConstraints(item: item, closure: closure)
        for constraint in constraints {
            constraint.activateIfNeeded(updatingExisting: true)
        }
    }

    internal static func removeConstraints(item: LayoutConstraintItem) {
        let constraints = item.constraints
        for constraint in constraints {
            constraint.deactivateIfNeeded()
        }
    }
}
