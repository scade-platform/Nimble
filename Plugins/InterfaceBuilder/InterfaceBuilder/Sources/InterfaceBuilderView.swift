import Cocoa
import NimbleCore
import ScadeKitExtension

class InterfaceBuilderView: NSViewController {

  private let widgetSelector = WidgetSelector()

  private let sizeMultiplier: CGFloat = 0.8

  weak var doc: PageDocument? = nil

  override func viewDidLoad() {
    super.viewDidLoad()

    doc?.observers.add(observer: self)

    if let page = doc?.page {
      widgetSelector.visit(page)
    }

    let svgView = SVGView()
    svgView.setSvg(doc?.rootSvg)
    
    view.addSubview(svgView)

    svgView.translatesAutoresizingMaskIntoConstraints = false

    svgView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    svgView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true


    svgView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                   multiplier: sizeMultiplier).isActive = true
    svgView.heightAnchor.constraint(equalTo: view.heightAnchor,
                                    multiplier: sizeMultiplier).isActive = true
  }
}

extension InterfaceBuilderView: WorkbenchEditor { }

extension InterfaceBuilderView: DocumentObserver {

  func documentFileDidChange(_ document: Document) {
    //loadPage()
  }
}
