import CodeEditor
import Cocoa


extension CodeEditorView: WorkbenchEditorZoomSupport {

  func zoomIn() {
    zoom(delta: 1)
  }

  func zoomOut() {
    zoom(delta: -1)
  }

  private func zoom(delta: CGFloat) {
    self.textView.modifyFontSize(delta: delta)

    guard let lineNumberView = self.textView.lineNumberView else { return }

    lineNumberView.modifyFontSize(delta: delta)
    lineNumberView.setNeedsDisplay(lineNumberView.bounds)
  }
}
