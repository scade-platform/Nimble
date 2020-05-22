import Cocoa

class SnippetPlaceholderView: NSTextView {

  private var snippetText: String = ""

  var range: NSRange!

  private weak var editorView: NSTextView?

  private var snippetTextStorage = NSTextStorage()

  func configure(for editorView: NSTextView, range: NSRange, text: String) {
    self.editorView = editorView
    self.range = range
    self.snippetText = text
    self.isEditable = false
    self.textContainer?.lineFragmentPadding = 0

    if let layoutManager = self.layoutManager,
       let textContainer = self.textContainer {

      self.snippetTextStorage.addLayoutManager(layoutManager)

      self.updateContent(isSelected: false)

      layoutManager.ensureLayout(for: textContainer)
      self.frame = layoutManager.usedRect(for: textContainer)
    }

    self.selectedTextAttributes = getSelectedAttributes()
  }

  override var shouldDrawInsertionPoint: Bool  {false}

  func getFont() -> NSFont {
    guard let editorView = self.editorView,
          let font = editorView.font else {
      return NSFont.systemFont(ofSize: 20)
    }

    return font
  }

  func getUnSelectedAttributes() -> [NSAttributedString.Key : Any] {
    return [
      .font: getFont(),
      .foregroundColor: NSColor.white,
      .backgroundColor: NSColor.lightGray
    ]
  }

  func getSelectedAttributes() -> [NSAttributedString.Key : Any] {
    return [
      .font: getFont(),
      .foregroundColor: NSColor.white,
      .backgroundColor: NSColor.systemBlue
    ]
  }

  func updateContent(isSelected flag: Bool) {
    let attributes =
      flag ? getSelectedAttributes() : getUnSelectedAttributes()
    let string =
      NSAttributedString(string: snippetText, attributes: attributes)

    self.textStorage?.setAttributedString(string)
  }

  func returnCursorToParent(position value: Int, mooveBackward: Bool = false) {
    if let editorView = self.editorView {
      editorView.setSelectedRange(NSMakeRange(value, 0))
      if mooveBackward {
        editorView.moveBackward(nil)
      }
      NSApplication.shared.mainWindow?.makeFirstResponder(editorView)
    }
  }

  override func becomeFirstResponder() -> Bool {
    updateContent(isSelected: true)

    return super.becomeFirstResponder()
  }

  override func resignFirstResponder() -> Bool {
    updateContent(isSelected: false)

    return super.resignFirstResponder()
  }

  override func keyDown(with event: NSEvent) {
    guard let specialKey = event.specialKey else { return }

    switch specialKey {

    case .leftArrow:
      returnCursorToParent(position: range.lowerBound)

    case .rightArrow:
      returnCursorToParent(position: range.upperBound + 1,
                           mooveBackward: true)

    default:
      break
    }
  }
}
