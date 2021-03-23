import UIKit

enum UIViewError: Error {
    case failedToLoadFromNib
}

extension UIView {
    class func fromNib<T: UIView>() throws -> T {
        guard
            let view = Bundle(for: T.self)
            .loadNibNamed(String(describing: T.self), owner: nil, options: nil)?[0] as? T
        else {
            throw UIViewError.failedToLoadFromNib
        }

        return view
    }
}
