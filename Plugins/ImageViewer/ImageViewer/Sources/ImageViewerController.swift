import Cocoa

class ImageViewerController: NSViewController {

  @IBOutlet
  weak var imageView: NSImageView? = nil
  
  weak var doc: ImageDocument? = nil

  // override func loadView() {
  //   super.loadView()

  //   let path = "/Users/shem/Downloads/skype/RenderSVG/src/test.jpg"
  //   let fileURL = URL( fileURLWithPath: path)
  //   let image = NSImage(contentsOf: fileURL)

  //   print(image)

  //   imageView?.image = image
      

  //   print(imageView?.image)
  // }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    imageView?.image = doc?.image

    // imageView?.image = 
    //   NSImage(byReferencingFile: "/Users/shem/workspace/scade/WeatherApp/res/mapwidget/btn_minus.png")

    // print(imageView?.image)

    // if let test = imageView {
    //   //imageView.isEditable = true
    //   test.imageScaling = .scaleNone
    //   //imageView.canDrawSubviewsIntoLayer = true
    //   //imageView.image = doc?.image

    //   //imageView.image = NSImage(byReferencingFile: "/Users/shem/Documents/image/1.jpg")
    //   test.image =
    //     NSImage(byReferencingFile: "/Users/shem/workspace/scade/WeatherApp/res/mapwidget/btn_minus.png")

    //   if let test = test.image {
    //     print(test)
    //   } else {
    //     print("####################")
    //   }
    // }
  }
}
