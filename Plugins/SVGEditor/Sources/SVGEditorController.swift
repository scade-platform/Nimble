import Cocoa
import ScadeKit
import NimbleCore

class SVGEditorController: NSViewController {

  let maxSize: CGFloat = 400

  weak var doc: SVGDocument? = nil

  override func viewDidLoad() {
    super.viewDidLoad()

    doc?.observers.add(observer: self)

    guard let svgView = ScadeKitExtensions.createPhoenixView() else { return }
    
    view.addSubview(svgView)

    svgView.translatesAutoresizingMaskIntoConstraints = false

    svgView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    svgView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

    svgView.widthAnchor.constraint(equalToConstant: maxSize).isActive = true
    svgView.heightAnchor.constraint(equalToConstant: maxSize).isActive = true

    if let root = doc?.svgRoot {
      SCDRuntime.renderSvg(root, x: 0, y: 0, size: NSMakeSize(maxSize, maxSize))
    }
  }
}

extension SVGEditorController: WorkbenchEditor { }

extension SVGEditorController: DocumentObserver {

  func documentFileDidChange(_ document: Document) {
    //loadPage()
  }
}
