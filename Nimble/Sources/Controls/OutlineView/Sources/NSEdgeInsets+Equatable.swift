import AppKit

extension NSEdgeInsets: Equatable {
  public static func == (lhs: NSEdgeInsets, rhs: NSEdgeInsets) -> Bool {
    NSEdgeInsetsEqual(lhs, rhs)
  }
}
