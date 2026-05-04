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

	func compatTrimmingPrefix(_ prefix: String) -> String.SubSequence {
		if #available(iOS 16, macOS 13, *) {
			return self.trimmingPrefix(prefix)
		} else {
			if self.hasPrefix(prefix) {
				return self[self.index(self.startIndex, offsetBy: prefix.count)...]
			}
			return self[...]
		}
	}
}

extension UIApplication {
	func compatSetBadgeCount(_ count: Int) {
		UIApplication.shared.applicationIconBadgeNumber = count
	}
}

@available(iOS 16, macOS 13, *)
struct CompatCachesDirectory {
	static let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
}

func compatCachesDirectory() -> URL {
	return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
}

extension View {
	func compatBold(_ isActive: Bool = true) -> some View {
		if #available(iOS 16, macOS 13, *) {
			return self.bold(isActive)
		} else {
			return self.font(isActive ? .body.bold() : .body)
		}
	}

	func compatMonospaced() -> some View {
		if #available(iOS 16.4, macOS 13.3, *) {
			return self.monospaced()
		} else {
			return self.font(.system(.body, design: .monospaced))
		}
	}
}

struct CompatLabeledContent<Label: View, Content: View>: View {
	let label: Label
	let content: Content

	init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
		self.content = content()
		self.label = label()
	}

	init(_ title: String, @ViewBuilder content: () -> Content) where Label == Text {
		self.label = Text(title)
		self.content = content()
	}

	var body: some View {
		if #available(iOS 16, macOS 13, *) {
			LabeledContent {
				content
			} label: {
				label
			}
		} else {
			HStack {
				label
				Spacer()
				content
			}
		}
	}
}

func compatTaskSleep(seconds: Double) async throws {
	if #available(iOS 16, macOS 13, *) {
		try await Task.sleep(for: .seconds(seconds))
	} else {
		try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
	}
}

func compatTaskSleep(milliseconds: Double) async throws {
	if #available(iOS 16, macOS 13, *) {
		try await Task.sleep(for: .milliseconds(milliseconds))
	} else {
		try await Task.sleep(nanoseconds: UInt64(milliseconds * 1_000_000))
	}
}
