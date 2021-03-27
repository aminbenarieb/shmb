import Foundation

public final class Atomic<A> {
    private let queue = DispatchQueue(
        label: "amin.benarieb.SHMB",
        attributes: .concurrent
    )
    private var _value: A

    public init(_ value: A) {
        self._value = value
    }

    public var value: A { self.queue.sync { self._value } }

    public func mutate(_ transform: (inout A) -> Void) {
        self.queue.sync(flags: .barrier) { transform(&self._value) }
    }
}
