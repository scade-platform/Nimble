import ScadeKit

class PageApp {

	let window = SCDLatticeWindow()

	let adapter = SCDLatticePageAdapter()
  
  func show() {
    adapter.show(window)
  }

  func load(_ url: URL) {
    adapter.load(url.path)
  }
}
