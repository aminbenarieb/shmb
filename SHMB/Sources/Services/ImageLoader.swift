import Combine
import Foundation
import SDWebImage
import UIKit

protocol ImageLoader {
    func load(for imageView: UIImageView?, url: URL?)
}

class ImageLoaderSDImpl: ImageLoader {
    func load(for imageView: UIImageView?, url: URL?) {
        imageView?.sd_setImage(with: url, completed: nil)
    }
}

class ImageLoaderFakeImpl: ImageLoader {
    var imageSet = Set<AnyCancellable>()

    func load(for imageView: UIImageView?, url: URL?) {
        guard let url = url else { return }
        self.image(url: url)
            .sink { _ in

            } receiveValue: { [weak imageView] v in
                imageView?.image = v.value
            }
            .store(in: &self.imageSet)
    }

    private func image(url: URL) -> AnyPublisher<WebClientResponse<UIImage?>, Error> {
        let response = URLResponse()
        let value = UIImage(named: url.lastPathComponent)
        return Just(WebClientResponse(value: value, response: response))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
