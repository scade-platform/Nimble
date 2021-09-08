import CodeEditor
import Cocoa


extension CodeEditorView: WorkbenchEditorZoomSupport {

  func zoomIn() {
    zoom(delta: 1)
  }

  func zoomOut() {
    zoom(delta: -1)
  }

  func zoomActualSize() {
    guard let theme = ThemeManager.shared.currentTheme,
          let lineNumberView = self.textView.lineNumberView else { return }

    self.textView.font = theme.general.font


    lineNumberView.setFontSize(size: theme.general.font.pointSize)
    lineNumberView.setNeedsDisplay(lineNumberView.bounds)
  }

  private func zoom(delta: CGFloat) {
    self.textView.modifyFontSize(delta: delta)

    guard let lineNumberView = self.textView.lineNumberView else { return }

    lineNumberView.incrementFontSize(delta: delta)
    lineNumberView.setNeedsDisplay(lineNumberView.bounds)
  }
}
