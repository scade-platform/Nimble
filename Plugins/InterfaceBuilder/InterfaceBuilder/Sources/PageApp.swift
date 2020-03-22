import ScadeKit

class PageApp: SCDApplication {

	let window = SCDLatticeWindow()

	let adapter = SCDLatticePageAdapter()

  func load(_ url: URL) {
    adapter.load(url.path)
  }

	override func onFinishLaunching() {
		adapter.show(window)
	}
}
