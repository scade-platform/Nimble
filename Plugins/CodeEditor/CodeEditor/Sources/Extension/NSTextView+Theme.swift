//
//  NSTextView+Theme.swift
//  CodeEditor
//
//  Created by Mark Goldin on 20/06/2019.
//  Copyright © 2019 SCADE. All rights reserved.
//

import Foundation
import AppKit

extension NSTextView {
    
    
    func applyTheme(theme: Theme) {
        
        assert(Thread.isMainThread)
        
        //guard let theme = self.theme else { return }
        
        //(self.window as? DocumentWindow)?.contentBackgroundColor = theme.background.color
        
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = theme.lineSpacing
//        self.defaultParagraphStyle = paragraphStyle
        
        self.backgroundColor = theme.background.color
        self.enclosingScrollView?.backgroundColor = theme.background.color
      //  self.textColor = NSColor.re //theme.text.color
        //self.lineHighLightColor = theme.lineHighlight.color
        //self.insertionPointColor = theme.insertionPoint.color.withAlphaComponent(self.cursorType == .block ? 0.5 : 1)
        self.selectedTextAttributes = [.backgroundColor: theme.selection.usesSystemSetting ? .selectedTextBackgroundColor : theme.selection.color]
        
        //(self.layoutManager as? LayoutManager)?.invisiblesColor = theme.invisibles.color
        
//        if !self.isOpaque {
//            self.lineHighLightColor = self.lineHighLightColor?.withAlphaComponent(0.7)
//        }
        
        // set scroller color considering background color
        self.enclosingScrollView?.scrollerKnobStyle = theme.isDarkTheme ? .light : .default
        
        self.setNeedsDisplay(self.visibleRect, avoidAdditionalLayout: true)
    }
}
