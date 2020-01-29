import Cocoa
import ScadeKit
import NimbleCore

class SVGEditorController: NSViewController {

  @IBOutlet
  weak var docView: NSView? = nil
  
  weak var doc: SVGDocument? = nil

  override func viewDidLoad() {
    super.viewDidLoad()

    //view.setBackgroundColor(NSColor.red)

    doc?.observers.add(observer: self)

    guard let phoenixView = ScadeKitExtensions.createPhoenixView() else { return }
    view.addSubview(phoenixView)

    phoenixView.frame = NSMakeRect(0, 0, 100, 100)

    if let root = doc?.svgRoot {
      SCDRuntime.renderSvg(root, x: 0, y: 0, size: phoenixView.frame.size)
    }
  }
}

extension SVGEditorController: WorkbenchEditor { }

extension SVGEditorController: DocumentObserver {

  func documentFileDidChange(_ document: Document) {
    //loadPage()
  }
}
