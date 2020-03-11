import Cocoa
import NimbleCore
import SVGEditor

class EditorView: SVGEditorView {

  @IBOutlet weak var scrollView: NSScrollView!

  override func getScrollView() -> NSScrollView? {
    return scrollView
  }
}

// extension EditorView: WorkbenchEditor {
//   public var editorMenu: NSMenu? {
//     SVGEditorMenu.shared.editor = self

//     return SVGEditorMenu.editorMenu
//   }
// }
