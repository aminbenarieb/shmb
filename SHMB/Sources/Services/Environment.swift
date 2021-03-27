import Foundation
import os.log

class Environment {
    private let keyValueStorage: [String: String]

    init(keyValueStorage: [String: String]) {
        self.keyValueStorage = keyValueStorage
        os_log(
            .debug,
            "Environment: %s",
            String(describing: keyValueStorage.filter { $0.key.hasPrefix("SHMB") })
        )
    }

    var webMocked: Bool {
        self.keyValueStorage["SHMB_WEB_MOCKED"] != nil
    }

    var webMockedError: String? {
        self.keyValueStorage["SHMB_WEB_MOCKED_ERROR"]
    }

    var webMockedDelay: Int? {
        guard let value = self.keyValueStorage["SHMB_WEB_MOCKED_DELAY"], let int = Int(value) else {
            return nil
        }
        return int
    }
}
