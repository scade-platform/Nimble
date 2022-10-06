import Cocoa

@available(macOS 10.15, *)
class OutlineViewDataSource<Data: Sequence>: NSObject, NSOutlineViewDataSource
where Data.Element: Identifiable {
    var items: [OutlineViewItem<Data>]

    init(items: [OutlineViewItem<Data>]) {
        self.items = items
    }

    private func typedItem(_ item: Any) -> OutlineViewItem<Data> {
        item as! OutlineViewItem<Data>
    }

    func outlineView(
        _ outlineView: NSOutlineView,
        numberOfChildrenOfItem item: Any?
    ) -> Int {
        if let item = item.map(typedItem) {
            return item.children?.count ?? 0
        } else {
            return items.count
        }
    }

    func outlineView(
        _ outlineView: NSOutlineView,
        isItemExpandable item: Any
    ) -> Bool {
        typedItem(item).children != nil
    }

    func outlineView(
        _ outlineView: NSOutlineView,
        child index: Int,
        ofItem item: Any?
    ) -> Any {
        if let item = item.map(typedItem) {
            // Should only be called if item has children.
            return item.children.unsafelyUnwrapped[index]
        } else {
            return items[index]
        }
    }
}
