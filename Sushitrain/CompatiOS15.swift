import Foundation
import SwiftUI

extension URL {
	func compatPath(percentEncoded: Bool = true) -> String {
		if #available(iOS 16, macOS 13, *) {
			return self.path(percentEncoded: percentEncoded)
		} else {
			return percentEncoded ? self.absoluteString : self.path
		}
	}

	func compatAppending(path: String) -> URL {
		if #available(iOS 16, macOS 13, *) {
			return self.appending(path: path)
		} else {
			return self.appendingPathComponent(path)
		}
	}

	func compatAppending(component: String) -> URL {
		if #available(iOS 16, macOS 13, *) {
			return self.appending(component: component)
		} else {
			return self.appendingPathComponent(component)
		}
	}
}

extension String {
	func compatTrimmingPrefix(_ prefix: Character) -> String {
		if #available(iOS 16, macOS 13, *) {
			return self.trimmingPrefix(while: { $0 == prefix }).description
		} else {
			var result = self
			while result.first == prefix {
				result.removeFirst()
			}
			return result
		}
	}
}

extension UIApplication {
	func compatSetBadgeCount(_ count: Int) {
		if #available(iOS 16, *) {
			self.setBadgeCount(count)
		} else {
			// Use deprecated API on iOS 15
			UIApplication.shared.applicationIconBadgeNumber = count
		}
	}
}

@available(iOS 16, macOS 13, *)
struct CompatCachesDirectory {
	static let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
}

func compatCachesDirectory() -> URL {
	if #available(iOS 16, macOS 13, *) {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	} else {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
	}
}

import SwiftUI

extension View {
    func compatStrikethrough() -> some View {
        if #available(iOS 16, macOS 13, *) {
            return AnyView(self.strikethrough())
        } else {
            return AnyView(self.foregroundColor(.gray))
        }
    }
}
