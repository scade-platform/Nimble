import Cocoa
import NimbleCore

class ImageViewerController: NSViewController {
  @IBOutlet
  weak var imageView: NSImageView? = nil
  
  weak var doc: ImageDocument? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imageView?.image = doc?.image
  }
}

extension ImageViewerController: WorkbenchEditor {}
