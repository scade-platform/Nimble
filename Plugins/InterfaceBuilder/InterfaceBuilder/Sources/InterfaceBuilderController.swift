import Cocoa
import ScadeKit

class InterfaceBuilderController: NSViewController {
  @IBOutlet
  weak var pageView: PageView? = nil
  
  weak var doc: PageDocument? = nil {
    didSet {
      //loadPage()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    if let svgSize = doc?.svgSize {
      if let view = pageView {
        for c in view.constraints {
          switch c.identifier {
          case .some("width"):
            c.constant = svgSize.width
            
          case .some("height"):
            c.constant = svgSize.height
            
          default:
            break
          }
        }
        view.phoenixView.frame.size = svgSize
      }
      Swift.print("set frame: \(svgSize)")
      loadPage()
    }
  }
  
  private func loadPage() {
    if let pageDocument = doc {
      if let page = pageDocument.page {
        addTouchListeners(page);
      }
      if let svg = pageDocument.svgRoot {
        if let size = pageDocument.svgSize {
          render(svg, size: size)
        }
      }
    }
  }

  private func addTouchListeners(_ page: SCDWidgetsPage) {
    let visitor = TouchListenerApplier()
    visitor.visit(page)
    // let visitor = {(_ widget: SCDWidgetsWidget, f: (SCDWidgetsWidget) -> Void) -> Void in
    //   f(widget)

    //   if let contaner = widget as? SCDWidgetsContainer {
    //     contaner.children.forEach { visitor($0, f: f)}
    //   }
    // }

    //visitor(page, {Swift.print($0)})
  }

  private func render(_ root: SCDSvgBox, size: CGSize) {
    SCDRuntime.renderSvg(root, x: 0, y: 0, size:size);
  }
}
