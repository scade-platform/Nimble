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

    if let view = pageView {
      let svgSize = getSvgSize()

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
      Swift.print("set frame: \(svgSize)")
    }
    loadPage()
  }
  
  private func loadPage() {
    if let pageDocument = doc {
      if let page = pageDocument.page {
        addTouchListeners(page);
      }
      if let svg = pageDocument.svgRoot {
        if let size = pageDocument.svgSize {
          render(svg, size: size)
        } else {
          render(svg, size: pageView!.frame.size)
        }
      }
    }
  }

  private func addTouchListeners(_ page: SCDWidgetsPage) {
    TouchListenerApplier().visit(page)
  }

  private func getSvgSize() -> CGSize {
    if let size = doc?.svgSize {
      return size
    }

    if let superViewSize = pageView?.superview?.frame.size {
      if let svg = doc?.svgRoot {
        let getUnitValue = {
          (unit: SCDSvgUnit, bound: Float) -> Int in
          switch unit.measurement {
          case .percentage:
            return Int(unit.value * bound / 100.0)

          case .pixel:
            return Int(unit.value)

            @unknown default:
              return 0
          }
        }

        return CGSize(width: getUnitValue(svg.width, Float(superViewSize.width)),
                      height: getUnitValue(svg.height, Float(superViewSize.height)))
      }
    }
    
    return CGSize(width: 100, height: 100)
  }

  private func render(_ root: SCDSvgBox, size: CGSize) {
    SCDRuntime.renderSvg(root, x: 0, y: 0, size:size);
  }
}
