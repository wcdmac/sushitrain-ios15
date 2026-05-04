import SwiftUI

struct CompatContentUnavailableView: View {
	let title: String
	let systemImage: String?
	let description: Text?

	init(_ title: String, systemImage: String? = nil, description: Text? = nil) {
		self.title = title
		self.systemImage = systemImage
		self.description = description
	}

	var body: some View {
		if #available(iOS 17, macOS 14, *) {
			if let systemImage = systemImage, let description = description {
				ContentUnavailableView(title, systemImage: systemImage, description: description)
			} else if let systemImage = systemImage {
				ContentUnavailableView(title, systemImage: systemImage, description: Text(""))
			} else if let description = description {
				ContentUnavailableView(title, systemImage: "questionmark", description: description)
			} else {
				ContentUnavailableView(title, systemImage: "questionmark", description: Text(""))
			}
		} else {
			fallbackView
		}
	}

	@ViewBuilder private var fallbackView: some View {
		VStack(spacing: 12) {
			if let systemImage = systemImage {
				Image(systemName: systemImage)
					.font(.system(size: 48))
					.foregroundStyle(.secondary)
			}
			Text(title)
				.font(.headline)
				.foregroundStyle(.primary)
			if let description = description {
				description
					.font(.subheadline)
					.foregroundStyle(.secondary)
					.multilineTextAlignment(.center)
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.padding()
	}
}

struct CompatContentUnavailableCustomView<Content: View, Description: View>: View {
	let content: Content
	let description: Description

	init(@ViewBuilder content: () -> Content, @ViewBuilder description: () -> Description) {
		self.content = content()
		self.description = description()
	}

	var body: some View {
		if #available(iOS 17, macOS 14, *) {
			ContentUnavailableView {
				content
			} description: {
				description
			}
		} else {
			VStack(spacing: 12) {
				content
					.foregroundStyle(.secondary)
				description
					.font(.subheadline)
					.foregroundStyle(.secondary)
					.multilineTextAlignment(.center)
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.padding()
		}
	}
}
