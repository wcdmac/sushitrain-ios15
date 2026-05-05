import SwiftUI

enum CompatNavigationSplitViewVisibility {
	case automatic
	case doubleColumn
	case detailOnly

	@available(iOS 16, macOS 13, *)
	var native: NavigationSplitViewVisibility {
		switch self {
		case .automatic: return .automatic
		case .doubleColumn: return .doubleColumn
		default: return .detailOnly
		}
	}
}

struct CompatNavigationStack<Content: View>: View {
	@ViewBuilder let content: () -> Content

	var body: some View {
		if #available(iOS 16, macOS 13, *) {
			NavigationStack {
				content()
			}
		} else {
			NavigationView {
				content()
			}
			#if os(iOS)
			.navigationViewStyle(StackNavigationViewStyle())
			#endif
		}
	}
}

struct CompatNavigationSplitView<Sidebar: View, Detail: View>: View {
	@Binding var columnVisibility: CompatNavigationSplitViewVisibility
	@ViewBuilder let sidebar: () -> Sidebar
	@ViewBuilder let detail: () -> Detail

	init(columnVisibility: Binding<CompatNavigationSplitViewVisibility> = .constant(.automatic), @ViewBuilder sidebar: @escaping () -> Sidebar, @ViewBuilder detail: @escaping () -> Detail) {
		self._columnVisibility = columnVisibility
		self.sidebar = sidebar
		self.detail = detail
	}

	var body: some View {
		if #available(iOS 16, macOS 13, *) {
			NavigationSplitView(columnVisibility: Binding(
				get: { columnVisibility.native },
				set: { v in
					if v == .automatic {
						columnVisibility = .automatic
					} else if v == .doubleColumn {
						columnVisibility = .doubleColumn
					} else {
						columnVisibility = .detailOnly
					}
				}
			), sidebar: sidebar, detail: detail)
		} else {
			NavigationView {
				sidebar()
				detail()
			}
			.navigationViewStyle(DoubleColumnNavigationViewStyle())
		}
	}
}

struct CompatNavigationDestinationModifier<Destination: View>: ViewModifier {
	@Binding var isPresented: Bool
	@ViewBuilder let destination: () -> Destination

	func body(content: Content) -> some View {
		if #available(iOS 16, macOS 13, *) {
			content.navigationDestination(isPresented: $isPresented) {
				destination()
			}
		} else {
			content.background(
				NavigationLink(
					destination: destination(),
					isActive: $isPresented,
					label: { EmptyView() }
				)
				.hidden()
			)
		}
	}
}

struct CompatNavigationDestinationItemModifier<Item: Hashable, Destination: View>: ViewModifier {
	@Binding var item: Item?
	@ViewBuilder let destination: (Item) -> Destination

	func body(content: Content) -> some View {
		if #available(iOS 17, macOS 14, *) {
			content.navigationDestination(item: $item) { value in
				destination(value)
			}
		} else {
			content.background(
				Group {
					if let value = item {
						NavigationLink(
							destination: destination(value),
							isActive: Binding(
								get: { item != nil },
								set: { if !$0 { item = nil } }
							),
							label: { EmptyView() }
						)
						.hidden()
					}
				}
			)
		}
	}
}

extension View {
	func compatNavigationDestination<Destination: View>(isPresented: Binding<Bool>, @ViewBuilder destination: @escaping () -> Destination) -> some View {
		self.modifier(CompatNavigationDestinationModifier(isPresented: isPresented, destination: destination))
	}

	func compatNavigationDestination<Item: Hashable, Destination: View>(item: Binding<Item?>, @ViewBuilder destination: @escaping (Item) -> Destination) -> some View {
		self.modifier(CompatNavigationDestinationItemModifier(item: item, destination: destination))
	}
}
