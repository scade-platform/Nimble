import Cocoa

extension NSTextView {

  func modifyFontSize(delta: CGFloat) {
    guard let oldFont = self.font,
          let textStorage = self.textStorage else { return }

    let newFont = NSFontManager.shared.convert(oldFont, toSize: oldFont.pointSize + delta)

    for layoutManager in textStorage.layoutManagers {
      layoutManager.firstTextView?.font = newFont
    }
  }
}
