#if os(iOS) || os(tvOS)
    import UIKit
#else
    import AppKit
#endif

public class ConstraintMakerPriortizable: ConstraintMakerFinalizable {
    @discardableResult
    public func priority(_ amount: ConstraintPriority) -> ConstraintMakerFinalizable {
        self.description.priority = amount.value
        return self
    }

    @discardableResult
    public func priority(_ amount: ConstraintPriorityTarget) -> ConstraintMakerFinalizable {
        self.description.priority = amount
        return self
    }

    @available(*, deprecated, message: "Use priority(.required) instead.")
    @discardableResult
    public func priorityRequired() -> ConstraintMakerFinalizable {
        return self.priority(.required)
    }

    @available(*, deprecated, message: "Use priority(.high) instead.")
    @discardableResult
    public func priorityHigh() -> ConstraintMakerFinalizable {
        return self.priority(.high)
    }

    @available(*, deprecated, message: "Use priority(.medium) instead.")
    @discardableResult
    public func priorityMedium() -> ConstraintMakerFinalizable {
        return self.priority(.medium)
    }

    @available(*, deprecated, message: "Use priority(.low) instead.")
    @discardableResult
    public func priorityLow() -> ConstraintMakerFinalizable {
        return self.priority(.low)
    }
}
