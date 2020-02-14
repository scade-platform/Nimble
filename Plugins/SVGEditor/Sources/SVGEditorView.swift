import Cocoa
import NimbleCore

public class SVGEditorView: NSViewController {

  @IBOutlet weak var scrollView: NSScrollView!

  private let elementSelector = SVGLayerSelector()

  private let sizeMultiplier: CGFloat = 0.8

  weak var doc: SVGDocument? = nil

  override public func viewDidLoad() {
    super.viewDidLoad()

    doc?.observers.add(observer: self)

    if let rootSvg = doc?.rootSvg {
      elementSelector.visit(rootSvg)
    }

    let svgView = SVGView()
    svgView.setSvg(doc?.rootSvg)
    
    scrollView.documentView = svgView

    setupScrollView()

    svgView.translatesAutoresizingMaskIntoConstraints = false

    svgView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    svgView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true


    svgView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                   multiplier: sizeMultiplier).isActive = true
    svgView.heightAnchor.constraint(equalTo: view.heightAnchor,
                                    multiplier: sizeMultiplier).isActive = true
  }

  public func zoomIn() {
    scrollView.magnification += 0.25
  }

  public func zoomOut() {
    scrollView.magnification -= 0.25
  }

  private func setupScrollView() {    
    scrollView.hasHorizontalRuler = true
    scrollView.hasVerticalRuler = true
    scrollView.rulersVisible = true
    
    scrollView.verticalScrollElasticity = .none
    scrollView.horizontalScrollElasticity = .none
    
    scrollView.borderType = .lineBorder
    
    scrollView.horizontalRulerView?.measurementUnits = .points
    scrollView.verticalRulerView?.measurementUnits = .points
    
    scrollView.allowsMagnification = true
    //scrollView.magnification = 10
  }
}

extension SVGEditorView: WorkbenchEditor { }

extension SVGEditorView: DocumentObserver {

  public func documentFileDidChange(_ document: Document) {
    //loadPage()
  }
}

