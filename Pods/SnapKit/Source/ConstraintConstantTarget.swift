#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

public protocol ConstraintConstantTarget {}

extension CGPoint: ConstraintConstantTarget {}

extension CGSize: ConstraintConstantTarget {}

extension ConstraintInsets: ConstraintConstantTarget {}

#if os(iOS) || os(tvOS)
    @available(iOS 11.0, tvOS 11.0, *)
    extension ConstraintDirectionalInsets: ConstraintConstantTarget {}
#endif

extension ConstraintConstantTarget {
    internal func constraintConstantTargetValueFor(layoutAttribute: LayoutAttribute) -> CGFloat {
        if let value = self as? CGFloat {
            return value
        }

        if let value = self as? Float {
            return CGFloat(value)
        }

        if let value = self as? Double {
            return CGFloat(value)
        }

        if let value = self as? Int {
            return CGFloat(value)
        }

        if let value = self as? UInt {
            return CGFloat(value)
        }

        if let value = self as? CGSize {
            if layoutAttribute == .width {
                return value.width
            }
            else if layoutAttribute == .height {
                return value.height
            }
            else {
                return 0.0
            }
        }

        if let value = self as? CGPoint {
            #if os(iOS) || os(tvOS)
                switch layoutAttribute {
                case .centerX,
                     .centerXWithinMargins,
                     .leading,
                     .leadingMargin,
                     .left,
                     .leftMargin,
                     .right,
                     .rightMargin,
                     .trailing,
                     .trailingMargin:
                    return value.x
                case .bottom,
                     .bottomMargin,
                     .centerY,
                     .centerYWithinMargins,
                     .firstBaseline,
                     .lastBaseline,
                     .top,
                     .topMargin:
                    return value.y
                case .height,
                     .notAnAttribute,
                     .width:
                    return 0.0
                #if swift(>=5.0)
                    @unknown default:
                        return 0.0
                #endif
                }
            #else
                switch layoutAttribute {
                case .centerX,
                     .leading,
                     .left,
                     .right,
                     .trailing:
                    return value.x
                case .bottom,
                     .centerY,
                     .firstBaseline,
                     .lastBaseline,
                     .top:
                    return value.y
                case .height,
                     .notAnAttribute,
                     .width:
                    return 0.0
                #if swift(>=5.0)
                    @unknown default:
                        return 0.0
                #endif
                }
            #endif
        }

        if let value = self as? ConstraintInsets {
            #if os(iOS) || os(tvOS)
                switch layoutAttribute {
                case .left,
                     .leftMargin:
                    return value.left
                case .firstBaseline,
                     .top,
                     .topMargin:
                    return value.top
                case .right,
                     .rightMargin:
                    return -value.right
                case .bottom,
                     .bottomMargin,
                     .lastBaseline:
                    return -value.bottom
                case .leading,
                     .leadingMargin:
                    return (ConstraintConfig.interfaceLayoutDirection == .leftToRight) ? value
                        .left : value.right
                case .trailing,
                     .trailingMargin:
                    return (ConstraintConfig.interfaceLayoutDirection == .leftToRight) ? -value
                        .right : -value.left
                case .centerX,
                     .centerXWithinMargins:
                    return (value.left - value.right) / 2
                case .centerY,
                     .centerYWithinMargins:
                    return (value.top - value.bottom) / 2
                case .width:
                    return -(value.left + value.right)
                case .height:
                    return -(value.top + value.bottom)
                case .notAnAttribute:
                    return 0.0
                #if swift(>=5.0)
                    @unknown default:
                        return 0.0
                #endif
                }
            #else
                switch layoutAttribute {
                case .left:
                    return value.left
                case .firstBaseline,
                     .top:
                    return value.top
                case .right:
                    return -value.right
                case .bottom,
                     .lastBaseline:
                    return -value.bottom
                case .leading:
                    return (ConstraintConfig.interfaceLayoutDirection == .leftToRight) ? value
                        .left : value.right
                case .trailing:
                    return (ConstraintConfig.interfaceLayoutDirection == .leftToRight) ? -value
                        .right : -value.left
                case .centerX:
                    return (value.left - value.right) / 2
                case .centerY:
                    return (value.top - value.bottom) / 2
                case .width:
                    return -(value.left + value.right)
                case .height:
                    return -(value.top + value.bottom)
                case .notAnAttribute:
                    return 0.0
                #if swift(>=5.0)
                    @unknown default:
                        return 0.0
                #endif
                }
            #endif
        }

        #if os(iOS) || os(tvOS)
            if
                #available(iOS 11.0, tvOS 11.0, *),
                let value = self as? ConstraintDirectionalInsets
            {
                switch layoutAttribute {
                case .left,
                     .leftMargin:
                    return (ConstraintConfig.interfaceLayoutDirection == .leftToRight) ? value
                        .leading : value.trailing
                case .firstBaseline,
                     .top,
                     .topMargin:
                    return value.top
                case .right,
                     .rightMargin:
                    return (ConstraintConfig.interfaceLayoutDirection == .leftToRight) ? -value
                        .trailing : -value.leading
                case .bottom,
                     .bottomMargin,
                     .lastBaseline:
                    return -value.bottom
                case .leading,
                     .leadingMargin:
                    return value.leading
                case .trailing,
                     .trailingMargin:
                    return -value.trailing
                case .centerX,
                     .centerXWithinMargins:
                    return (value.leading - value.trailing) / 2
                case .centerY,
                     .centerYWithinMargins:
                    return (value.top - value.bottom) / 2
                case .width:
                    return -(value.leading + value.trailing)
                case .height:
                    return -(value.top + value.bottom)
                case .notAnAttribute:
                    return 0.0
                #if swift(>=5.0)
                    @unknown default:
                        return 0.0
                #else
                    default:
                        return 0.0
                #endif
                }
            }
        #endif

        return 0.0
    }
}
