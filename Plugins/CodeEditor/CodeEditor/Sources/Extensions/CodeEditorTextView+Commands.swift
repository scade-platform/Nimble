import CodeEditor
import Cocoa

extension CodeEditorTextView: WorkbenchEditorZoomSuppot {

  func zoomIn() {
    zoom(delta: 1)
  }

  func zoomOut() {
    zoom(delta: -1)
  }

  private func zoom(delta: CGFloat) {
    modifyFontSize(delta: delta)

    guard let lineNumberView = self.lineNumberView else { return }

    lineNumberView.modifyFontSize(delta: delta)
    lineNumberView.setNeedsDisplay(lineNumberView.bounds)
  }
}
