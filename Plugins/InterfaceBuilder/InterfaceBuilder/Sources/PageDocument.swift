import AppKit
import NimbleCore
import ScadeKit

public final class PageDocument: NimbleDocument {
  public var svgRoot: SCDSvgBox?
  public var page: SCDWidgetsPage?

  private lazy var builderController: InterfaceBuilderController = {
    let controller = InterfaceBuilderController.loadFromNib()
    controller.doc = self
    return controller
  }()

  //  public override func read(from data: Data, ofType typeName: String) throws {
  //    svgRoot = SCDRuntime.parseSvg("") as! SCDSvgBox
  //  }

  override public func presentedItemDidChange() {
    DispatchQueue.main.async {
      guard let url = self.fileURL, let type = self.fileType  else { return }
      try! self.read(from: url, ofType: type)

      self.observers.notify { $0.documentDidChange(self) }
    }
  }
  
  public override func read(from url: URL, ofType typeName: String) throws {
    if url.pathExtension == "page" {
      let resource = SCDRuntime.loadXmiResource(url.path) as! SCDCoreResource
      let resourceContents = resource.contents
      if !resourceContents.isEmpty {
        let root = SCDSvgBox()
        root.children.append(resourceContents[resourceContents.count - 1] as! SCDSvgBox)

        if let page = resourceContents[0] as? SCDWidgetsPage {
          self.page = page
          // var width = page.size.width
          // var height = page.size.height
          // let minSize = page.minArea
          // if minSize.width > 0 && minSize.height > 0 {
          //   width = minSize.width
          //   height = minSize.height
          // }
          root.viewBox = "0 0 \(page.size.width) \(page.size.height)"
          //root.alignment = .xmidymid
          //root.width.value = Float(width)
          //root.height.value = Float(height)
          //Swift.print("size: \(page.size.width)x\(page.size.height)")
          svgRoot = root
        }
      }
    }

    else if url.pathExtension == "svg" {
      let content = """
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:scade="http://www.scade.io/v0.1" contentScriptType="text/ecmascript" zoomAndPan="magnify" contentStyleType="text/css" preserveAspectRatio="xMidYMid meet" version="1.0">
        <image id="image" preserveAspectRatio="xMidYMid meet" width="100%" height="100%" xlink:href="\(url.path)"/>
        </svg>
        """
      
      svgRoot = SCDRuntime.parseSvgContent(content) as? SCDSvgBox
    }

    try super.read(from: url, ofType: typeName)
  }
  
  public override func data(ofType typeName: String) throws -> Data {
    return "".data(using: .utf8)!
  }
}

extension PageDocument: Document {
  public var editor: WorkbenchEditor? { builderController }
  
  /// TODO: register UTIs for the page files
  public static var typeIdentifiers: [String] = []
  
  public static func canOpen(_ file: File) -> Bool {
    return file.path.extension == "page" || file.path.extension == "svg"
  }
  
  public static func isDefault(for file: File) -> Bool {
    return canOpen(file)
  }
}
