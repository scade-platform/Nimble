import SwiftUI
import Cocoa

public struct OutlineView<Data: Sequence>: NSViewControllerRepresentable
where Data.Element: Identifiable {
    public typealias NSViewControllerType = OutlineViewController<Data>

    let data: Data
    let children: KeyPath<Data.Element, Data?>
    @Binding var selection: Data.Element?
    var content: (Data.Element) -> NSView
    var separatorInsets: ((Data.Element) -> NSEdgeInsets)?

    /// Outline view style is unavailable on macOS 10.15 and below.
    /// Stored as `Any` to make the property available on all platforms.
    private var _styleStorage: Any?

    var style: NSOutlineView.Style {
        get {
            _styleStorage
                .flatMap { $0 as? NSOutlineView.Style }
                ?? .automatic
        }
        set { _styleStorage = newValue }
    }

    var indentation: CGFloat = 13.0
    var separatorVisibility: SeparatorVisibility
    var separatorColor: NSColor = .separatorColor

    /// Creates an outline view from a collection of root data elements and
    /// a key path to its children.
    ///
    /// This initializer creates an instance that uniquely identifies views
    /// across updates based on the identity of the underlying data element.
    ///
    /// All generated rows begin in the collapsed state.
    ///
    /// Make sure that the identifier of a data element only changes if you
    /// mean to replace that element with a new element, one with a new
    /// identity. If the ID of an element changes, then the content view
    /// generated from that element will lose any current state and animations.
    ///
    /// - NOTE: All elements in data should be uniquely identified. Data with
    /// elements that have a repeated identity are not supported.
    ///
    /// - Parameters:
    ///   - data: A collection of tree-structured, identified data.
    ///   - children: A key path to a property whose non-`nil` value gives the
    ///     children of `data`. A non-`nil` but empty value denotes an element
    ///     capable of having children that's currently childless, such as an
    ///     empty directory in a file system. On the other hand, if the property
    ///     at the key path is `nil`, then the outline group treats `data` as a
    ///     leaf in the tree, like a regular file in a file system.
    ///   - selection: A binding to a selected value.
    ///   - content: A closure that produces an `NSView` based on an
    ///     element in `data`. An `NSTableCellView` subclass is preferred.
    ///     The `NSView` should return the correct `fittingSize`
    ///     as it is used to determine the height of the cell.
    public init(
        _ data: Data,
        children: KeyPath<Data.Element, Data?>,
        selection: Binding<Data.Element?>,
        content: @escaping (Data.Element) -> NSView
    ) {
        self.data = data
        self.children = children
        self._selection = selection
        self.separatorVisibility = .hidden
        self.content = content
    }

    /// Creates an outline view from a collection of root data elements and
    /// a key path to its children. The outline view will have row separator
    /// lines enabled by default, the insets to which will determined by
    /// the `separatorInsets` closure.
    ///
    /// This initializer creates an instance that uniquely identifies views
    /// across updates based on the identity of the underlying data element.
    ///
    /// All generated rows begin in the collapsed state.
    ///
    /// Make sure that the identifier of a data element only changes if you
    /// mean to replace that element with a new element, one with a new
    /// identity. If the ID of an element changes, then the content view
    /// generated from that element will lose any current state and animations.
    ///
    /// - NOTE: All elements in data should be uniquely identified. Data with
    /// elements that have a repeated identity are not supported.
    ///
    /// - Parameters:
    ///   - data: A collection of tree-structured, identified data.
    ///   - children: A key path to a property whose non-`nil` value gives the
    ///     children of `data`. A non-`nil` but empty value denotes an element
    ///     capable of having children that's currently childless, such as an
    ///     empty directory in a file system. On the other hand, if the property
    ///     at the key path is `nil`, then the outline group treats `data` as a
    ///     leaf in the tree, like a regular file in a file system.
    ///   - selection: A binding to a selected value.
    ///   - content: A closure that produces an `NSView` based on an
    ///     element in `data`. An `NSTableCellView` subclass is preferred.
    ///     The `NSView` should return the correct `fittingSize`
    ///     as it is used to determine the height of the cell.
    public init(
        _ data: Data,
        children: KeyPath<Data.Element, Data?>,
        selection: Binding<Data.Element?>,
        separatorInsets: @escaping (Data.Element) -> NSEdgeInsets,
        content: @escaping (Data.Element) -> NSView
    ) {
        self.data = data
        self.children = children
        self._selection = selection
        self.separatorInsets = separatorInsets
        self.separatorVisibility = .visible
        self.content = content
    }

    public func makeNSViewController(context: Context) -> OutlineViewController<Data> {
        let controller = OutlineViewController(
            data: data,
            children: children,
            content: content,
            selectionChanged: { selection = $0 },
            separatorInsets: separatorInsets)
        controller.setIndentation(to: indentation)
        //if #available(macOS 11.0, *) {
            controller.setStyle(to: style)
       // }
        return controller
    }

    public func updateNSViewController(
        _ outlineController: OutlineViewController<Data>,
        context: Context
    ) {
        outlineController.updateData(newValue: data)
        outlineController.changeSelectedItem(to: selection)
        outlineController.setRowSeparator(visibility: separatorVisibility)
        outlineController.setRowSeparator(color: separatorColor)
    }
}

public extension OutlineView {

    /// Sets the style for the `OutlineView`.
    func outlineViewStyle(_ style: NSOutlineView.Style) -> Self {
        var mutableSelf = self
        mutableSelf.style = style
        return mutableSelf
    }

    /// Sets the width of the indentation per level for the `OutlineView`.
    func outlineViewIndentation(_ width: CGFloat) -> Self {
        var mutableSelf = self
        mutableSelf.indentation = width
        return mutableSelf
    }

    /// Sets the visibility of the separator between rows of this outline view.
    func rowSeparator(_ visibility: SeparatorVisibility) -> Self {
        var mutableSelf = self
        mutableSelf.separatorVisibility = visibility
        return mutableSelf
    }

    /// Sets the color of the separator between rows of this outline view.
    /// The default color for the separator is `NSColor.separatorColor`.
    func rowSeparatorColor(_ color: NSColor) -> Self {
        var mutableSelf = self
        mutableSelf.separatorColor = color
        return mutableSelf
    }
}
