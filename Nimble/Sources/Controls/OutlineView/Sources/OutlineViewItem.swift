/// A wrapper for holding the outline view data items. This wrapper exposes the `id` of the
/// wrapped value for its conformance to `Equatable` and `Hashable`. `NSOutlineView`
/// requires that Swift value types be "equal" to correctly find the stored item internally.
/// `OutlineView` chooses to use the `Identifiable` protocol for identifying items,
/// necessitating the use of a wrapper.
///
/// Reference: AppKit Release Notes for macOS 10.14 - API Changes - `NSOutlineView`
/// https://developer.apple.com/documentation/macos-release-notes/appkit-release-notes-for-macos-10_14
struct OutlineViewItem<Data: Sequence>: Equatable, Hashable, Identifiable where Data.Element: Identifiable {
  var childrenPath: KeyPath<Data.Element, Data?>
  var value: Data.Element
  
  var children: [OutlineViewItem]? {
    value[keyPath: childrenPath]?.map { OutlineViewItem(value: $0, children: childrenPath) }
  }
  
  init(value: Data.Element, children: KeyPath<Data.Element, Data?>) {
    self.value = value
    childrenPath = children
  }
  
  var id: Data.Element.ID {
    value.id
  }
  
  static func == (lhs: OutlineViewItem<Data>, rhs: OutlineViewItem<Data>) -> Bool {
    lhs.value.id == rhs.value.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(value.id)
  }
}
