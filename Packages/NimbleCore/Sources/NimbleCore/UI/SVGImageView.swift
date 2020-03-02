import Cocoa
import SwiftSVG

public class SVGImageView: NSView {
  public override var isFlipped: Bool { true }

  public var url: URL? {
    didSet {
      if let newUrl = url {
        self.layer =
          CALayer(svgURL: newUrl) {$0.resizeToFit(self.bounds) }
      }
    }
  }

}
