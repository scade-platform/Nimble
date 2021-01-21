import Cocoa

extension NSTextView {

  func modifyFontSize(delta: CGFloat) {
    guard let oldFont = self.font else { return }
    self.font = NSFontManager.shared.convert(oldFont, toSize: oldFont.pointSize + delta)
  }
  
}
