//___FILEHEADER___

import NimbleCore

public final class ___PACKAGENAMEASIDENTIFIER___Module: Module {
  public static let plugin: Plugin = ___PACKAGENAME___Plugin()
}

final class ___PACKAGENAMEASIDENTIFIER___Plugin: Plugin {  
  public func load() { 
    // Put setup code here.
    // This method is called once before the Nimble application finished launching.
  }

  public func activate(in workbench: Workbench) {
    // Put activation code here.
    // This method is called for every new Nimble workbench (window).
  }
    
  public func deactivate(in workbench: Workbench) {
    // Put de-activation code here.
    // This method is called when a Nimble workbench (window) is closed.    
  }
}
