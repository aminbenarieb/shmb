#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

internal struct ConstraintAttributes: OptionSet, ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = UInt

    internal init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    internal init(_ rawValue: UInt) {
        self.init(rawValue: rawValue)
    }

    internal init(nilLiteral _: ()) {
        self.rawValue = 0
    }

    internal init(integerLiteral rawValue: IntegerLiteralType) {
        self.init(rawValue: rawValue)
    }

    internal private(set) var rawValue: UInt
    internal static var allZeros: ConstraintAttributes { return 0 }
    internal static func convertFromNilLiteral() -> ConstraintAttributes { return 0 }
    internal var boolValue: Bool { return self.rawValue != 0 }

    internal func toRaw() -> UInt { return self.rawValue }
    internal static func fromRaw(_ raw: UInt) -> ConstraintAttributes? { return self.init(raw) }
    internal static func fromMask(_ raw: UInt) -> ConstraintAttributes { return self.init(raw) }

    // normal

    internal static var none: ConstraintAttributes { return 0 }
    internal static var left: ConstraintAttributes { return 1 }
    internal static var top: ConstraintAttributes { return 2 }
    internal static var right: ConstraintAttributes { return 4 }
    internal static var bottom: ConstraintAttributes { return 8 }
    internal static var leading: ConstraintAttributes { return 16 }
    internal static var trailing: ConstraintAttributes { return 32 }
    internal static var width: ConstraintAttributes { return 64 }
    internal static var height: ConstraintAttributes { return 128 }
    internal static var centerX: ConstraintAttributes { return 256 }
    internal static var centerY: ConstraintAttributes { return 512 }
    internal static var lastBaseline: ConstraintAttributes { return 1024 }

    @available(iOS 8.0, OSX 10.11, *)
    internal static var firstBaseline: ConstraintAttributes { return 2048 }

    @available(iOS 8.0, *)
    internal static var leftMargin: ConstraintAttributes { return 4096 }

    @available(iOS 8.0, *)
    internal static var rightMargin: ConstraintAttributes { return 8192 }

    @available(iOS 8.0, *)
    internal static var topMargin: ConstraintAttributes { return 16384 }

    @available(iOS 8.0, *)
    internal static var bottomMargin: ConstraintAttributes { return 32768 }

    @available(iOS 8.0, *)
    internal static var leadingMargin: ConstraintAttributes { return 65536 }

    @available(iOS 8.0, *)
    internal static var trailingMargin: ConstraintAttributes { return 131_072 }

    @available(iOS 8.0, *)
    internal static var centerXWithinMargins: ConstraintAttributes { return 262_144 }

    @available(iOS 8.0, *)
    internal static var centerYWithinMargins: ConstraintAttributes { return 524_288 }

    // aggregates

    internal static var edges: ConstraintAttributes { return 15 }
    internal static var directionalEdges: ConstraintAttributes { return 58 }
    internal static var size: ConstraintAttributes { return 192 }
    internal static var center: ConstraintAttributes { return 768 }

    @available(iOS 8.0, *)
    internal static var margins: ConstraintAttributes { return 61440 }

    @available(iOS 8.0, *)
    internal static var directionalMargins: ConstraintAttributes { return 245_760 }

    @available(iOS 8.0, *)
    internal static var centerWithinMargins: ConstraintAttributes { return 786_432 }

    internal var layoutAttributes: [LayoutAttribute] {
        var attrs = [LayoutAttribute]()
        if self.contains(ConstraintAttributes.left) {
            attrs.append(.left)
        }
        if self.contains(ConstraintAttributes.top) {
            attrs.append(.top)
        }
        if self.contains(ConstraintAttributes.right) {
            attrs.append(.right)
        }
        if self.contains(ConstraintAttributes.bottom) {
            attrs.append(.bottom)
        }
        if self.contains(ConstraintAttributes.leading) {
            attrs.append(.leading)
        }
        if self.contains(ConstraintAttributes.trailing) {
            attrs.append(.trailing)
        }
        if self.contains(ConstraintAttributes.width) {
            attrs.append(.width)
        }
        if self.contains(ConstraintAttributes.height) {
            attrs.append(.height)
        }
        if self.contains(ConstraintAttributes.centerX) {
            attrs.append(.centerX)
        }
        if self.contains(ConstraintAttributes.centerY) {
            attrs.append(.centerY)
        }
        if self.contains(ConstraintAttributes.lastBaseline) {
            attrs.append(.lastBaseline)
        }

        #if os(iOS) || os(tvOS)
            if self.contains(ConstraintAttributes.firstBaseline) {
                attrs.append(.firstBaseline)
            }
            if self.contains(ConstraintAttributes.leftMargin) {
                attrs.append(.leftMargin)
            }
            if self.contains(ConstraintAttributes.rightMargin) {
                attrs.append(.rightMargin)
            }
            if self.contains(ConstraintAttributes.topMargin) {
                attrs.append(.topMargin)
            }
            if self.contains(ConstraintAttributes.bottomMargin) {
                attrs.append(.bottomMargin)
            }
            if self.contains(ConstraintAttributes.leadingMargin) {
                attrs.append(.leadingMargin)
            }
            if self.contains(ConstraintAttributes.trailingMargin) {
                attrs.append(.trailingMargin)
            }
            if self.contains(ConstraintAttributes.centerXWithinMargins) {
                attrs.append(.centerXWithinMargins)
            }
            if self.contains(ConstraintAttributes.centerYWithinMargins) {
                attrs.append(.centerYWithinMargins)
            }
        #endif

        return attrs
    }
}

internal func + (left: ConstraintAttributes, right: ConstraintAttributes) -> ConstraintAttributes {
    return left.union(right)
}

internal func += (left: inout ConstraintAttributes, right: ConstraintAttributes) {
    left.formUnion(right)
}

internal func -= (left: inout ConstraintAttributes, right: ConstraintAttributes) {
    left.subtract(right)
}

internal func == (left: ConstraintAttributes, right: ConstraintAttributes) -> Bool {
    return left.rawValue == right.rawValue
}
