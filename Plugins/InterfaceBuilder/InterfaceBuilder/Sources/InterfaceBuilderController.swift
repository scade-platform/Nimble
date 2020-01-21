import Cocoa
import ScadeKit
import NimbleCore

class InterfaceBuilderController: NSViewController {

  var highlighter: WidgetHighlighter?

  @IBOutlet
  weak var pageView: PageView? = nil
  
  weak var doc: PageDocument? = nil {
    didSet {
      //loadPage()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    doc?.observers.add(observer: self)

    if let view = pageView {
      let size = (pageView?.superview?.frame.size)!

      for c in view.constraints {
        switch c.identifier {
        case .some("width"):
          c.constant = size.width
          
        case .some("height"):
          c.constant = size.height
          
        default:
          break
        }
      }
      view.phoenixView.frame.size = size
      //Swift.print("set frame: \(size)")
    }
    loadPage()
  }

  private func loadPage() {
    if let pageDocument = doc {
      if let page = pageDocument.page {
        addTouchListeners(page);
      }
      if let svg = pageDocument.svgRoot {
        render(svg, size: pageView!.phoenixView.frame.size)
      }
    }
  }

  private func addTouchListeners(_ page: SCDWidgetsPage) {
    if highlighter == nil {
      highlighter = WidgetHighlighter()
      highlighter?.visit(page)
    }
  }

  private func render(_ root: SCDSvgBox, size: CGSize) {
    SCDRuntime.renderSvg(root, x: 0, y: 0, size:size);
  }
}



extension InterfaceBuilderController: WorkbenchEditor { }

extension InterfaceBuilderController: DocumentObserver {
  public func documentDidChange(_ document: Document) {
    loadPage()
  }
}
