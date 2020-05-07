import AppKit
import NimbleCore
import ScadeKit
import SVGEditor

public final class PageDocument: NimbleDocument, SVGDocumentProtocol {

  let adapter = SCDLatticeEditorPageAdapter()

  public var svgWidth: SCDSvgUnit? {
    guard let width = page?.size.width else { return nil }

    return SCDSvgUnit(value: Float(width))
  }
  
  public var svgHeight: SCDSvgUnit? {
    guard let height = page?.size.height else { return nil }

    return SCDSvgUnit(value: Float(height))
  }

  public var rootSvg: SCDSvgBox? {
    return page?.drawing as? SCDSvgBox
  }

  public var page: SCDWidgetsPage? {
    return adapter.page
  }

  private lazy var editorView: EditorView = {
    let view = EditorView.loadFromNib()
    view.document = self

    return view
  }()

  override public func presentedItemDidChange() {
    guard let url = self.fileURL, let type = self.fileType  else { return }

    DispatchQueue.main.async { [weak self] in
      try! self?.read(from: url, ofType: type)
      self?.onFileDidChange()
    }
  }
  
  public override func read(from url: URL, ofType typeName: String) throws {
    adapter.load(url.path)
    onPageLoad()
  }
  
  public override func data(ofType typeName: String) throws -> Data {
    if let page = adapter.page,
       let container = page.eContainer(),
       let resource = container as? SCDCoreXmiResource {
      return resource.data
    }
    return "".data(using: .utf8)!
  }

  private func onPageLoad() {
    if let size = adapter.page?.size {
      if size.width == 0 || size.height == 0 {
        size.width = 320
        size.height = 480
      }
    }
  }
}

extension PageDocument: Document {
  public var editor: WorkbenchEditor? { editorView }
  
  /// TODO: register UTIs for the page files
  public static var typeIdentifiers: [String] = []
  
  public static func canOpen(_ file: File) -> Bool {
    return file.path.extension == "page"
  }
  
  public static func isDefault(for file: File) -> Bool {
    return canOpen(file)
  }
}

extension PageDocument: CreatableDocument {
  public static let newMenuTitle: String = "Page"

  public static func createUntitledDocument() -> Document? {
    let doc = PageDocument()
    doc.adapter.loadTemplatePage()
    doc.onPageLoad()

    return doc
  }
}
