import AppKit
import ObjectiveC

/// An NSTableRowView with an adjustable separator line.
//@available(macOS 11.0, *)
final class AdjustableSeparatorRowView: NSTableRowView {
    var separatorInsets: NSEdgeInsets?

    public override init(frame frameRect: NSRect) {
        Self.setupSwizzling
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        Self.setupSwizzling
        super.init(coder: coder)
    }

    /// Our implementation of the private `_separatorRect` method.
    /// Computes the frame of the `_separatorView`.
    @objc
    func separatorRect() -> CGRect {
        // Make sure we only override the behavior for this class.
        guard type(of: self) == AdjustableSeparatorRowView.self else {
            return Self.originalSeparatorRect?(self) ?? .zero
        }

        // Only override the default behavior if the
        // separator insets are not available.
        guard let separatorInsets = separatorInsets else {
            // Get the frame from the original method.
            return Self.originalSeparatorRect?(self) ?? .zero
        }

        guard self.numberOfColumns > 0 else { return .zero }
        let viewRect = (self.view(atColumn: 0)! as! NSView).frame

        // One point thick separator of the width of the first (and only) column.
        let separatorRect = NSRect(
            x: viewRect.origin.x,
            y: max(0, viewRect.height - 1),
            width: viewRect.width,
            height: 1)

        // Inset the separator frame by the separatorInsets.
        return CGRect(
            x: separatorRect.origin.x + separatorInsets.left,
            y: separatorRect.origin.y + separatorInsets.top,
            width: separatorRect.width - separatorInsets.left - separatorInsets.right,
            height: separatorRect.height - separatorInsets.top - separatorInsets.bottom)
    }

    /// Stores the original implementation of `_separatorRect` if successfully swizzled.
    static var originalSeparatorRect: ((NSTableRowView) -> CGRect)?

    /// Swizzle the private `_separatorRect` defined on NSTableRowView.
    /// Should be executed early in the life-cycle of `AdjustableSeparatorRowView`.
    static let setupSwizzling: Void = {
        // Selector for _separatorRect.
        let privateSeparatorRectSelector = Selector(unmangle("^rdo`q`snqQdbs"))
        guard
            let originalMethod = class_getInstanceMethod(
                AdjustableSeparatorRowView.self,
                privateSeparatorRectSelector),
            let newMethod = class_getInstanceMethod(
                AdjustableSeparatorRowView.self,
                #selector(separatorRect))
        else { return }

        // Replace the original implementation with our implementation.
        let originalImplementation = method_setImplementation(
            originalMethod,
            method_getImplementation(newMethod))

        // Store the original implementation for later use.
        originalSeparatorRect = { instance in
            let privateSeparatorRect = unsafeBitCast(
                originalImplementation,
                to: (@convention(c) (Any?, Selector?) -> CGRect).self)
            return privateSeparatorRect(instance, privateSeparatorRectSelector)
        }
    }()
}
