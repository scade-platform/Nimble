import Cocoa
import NimbleCore
import SVGEditor
import ScadeKitExtension

class PluginView: SVGEditorView {

  @IBOutlet weak var scrollView: NSScrollView!
  
  override public func viewDidLoad() {
    super.viewDidLoad()

    scrollView.documentView = svgView
    setupScrollView()
  }

  public func zoomIn() {
    scrollView.magnification += 0.25
  }

  public func zoomOut() {
    scrollView.magnification -= 0.25
  }

  public func actualSize() {
    scrollView.magnification = 1
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

extension PluginView: WorkbenchEditor {
  public var editorMenu: NSMenu? {
    SVGEditorMenu.shared.editor = self

    return SVGEditorMenu.editorMenu
  }
}
