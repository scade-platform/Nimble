import AppKit
import NimbleCore
import ScadeKit

public final class PageDocument: NSDocument, Document {
  public var svgRoot: SCDSvgBox?
  public var svgSize: CGSize?
  public var page: SCDWidgetsPage?
  
  private lazy var builderController: InterfaceBuilderController = {
    let controller = InterfaceBuilderController.loadFromNib()
    controller.doc = self
    return controller
  }()
  
  public var contentViewController: NSViewController? { return builderController }
  
  public static func canOpen(_ file: File) -> Bool {
    return file.path.extension == "page" || file.path.extension == "svg"
  }
  
  public static func isDefault(for file: File) -> Bool {
    return canOpen(file)
  }
  
  //  public override func read(from data: Data, ofType typeName: String) throws {
  //    svgRoot = SCDRuntime.parseSvg("") as! SCDSvgBox
  //  }
  
  public override func read(from url: URL, ofType typeName: String) throws {
    if url.pathExtension == "page" {
      let resource = SCDRuntime.loadXmiResource(url.path) as! SCDCoreResource
      let resourceContents = resource.contents
      if !resourceContents.isEmpty {
        svgRoot = resourceContents[resourceContents.count - 1] as? SCDSvgBox
        if let page = resourceContents[0] as? SCDWidgetsPage {
          self.page = page
          var width = page.size.width
          var height = page.size.height
          let minSize = page.minArea
          if minSize.width > 0 && minSize.height > 0 {
            width = minSize.width
            height = minSize.height
          }
          svgSize = CGSize(width: width, height: height)
        }
      }
    }

    else if url.pathExtension == "svg" {
      let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(UUID().uuidString)

      let data: Data = """
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:scade="http://www.scade.io/v0.1" contentScriptType="text/ecmascript" zoomAndPan="magnify" contentStyleType="text/css" preserveAspectRatio="xMidYMid meet" version="1.0">
        <image id="image" width="100%" height="100%" xlink:href="\(url.path)"/>
        </svg>
        """.data(using: .utf8)!
      try data.write(to: tempUrl, options: .atomicWrite)

      svgRoot = SCDRuntime.parseSvg(tempUrl.path) as? SCDSvgBox

      try FileManager.default.removeItem(at: tempUrl)
    }
  }
  
  public override func data(ofType typeName: String) throws -> Data {
    return "".data(using: .utf8)!
  }
}
