import Foundation
import Cocoa

class SnippetsManager {

  private let regex = try? NSRegularExpression(pattern: "\\$\\{[0-9]+:(.*?)\\}")

  private var snippets: [SnippetPlaceholderView] = []

  var isEdited: Bool = false

  weak var textView: NSTextView?

  func createSnippet(in range: NSRange, with text: String) -> SnippetPlaceholderView? {
    guard let textView = self.textView,
          let layoutManager = textView.layoutManager,
          let textContainer = textView.textContainer else { return nil}

    let glyphRange = layoutManager.glyphRange(forCharacterRange: range,
                                              actualCharacterRange: nil)
    let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange,
                                                  in: textContainer)

    let snippet = SnippetPlaceholderView()
    snippet.configure(for: textView, range: range, text: text)
    snippet.frame.origin = boundingRect.origin
    snippet.frame.origin.y -= floor(textView.font?.descender ?? 0)
    snippet.sizeToFit()
    textView.addSubview(snippet)

    let path = NSBezierPath.init(rect: snippet.frame)
    textContainer.exclusionPaths.append(path)

    return snippet
  }

  func addSnippets(_ newSnippets: [SnippetPlaceholderView]) {
    if !newSnippets.isEmpty {
      snippets += newSnippets
      isEdited = true
    }
  }

  func invalidate() {
    if isEdited {
      //TODO
    }
  }

  func containsIndex(_ characterIndex: Int) -> Bool {
    return snippets.contains(where: { $0.range.contains(characterIndex) } )
  }

  func onLoadContent() {
    guard let content = self.textView?.textStorage?.string else { return }

    processEditing(in: NSRange(location: 0, length: content.count))
  }

  func processEditing(in range: NSRange) {
    var locationOffset: Int = 0
    guard let textStorage = textView?.textStorage else { return }

    if let matches = regex?.matches(in: textStorage.string, options: [], range: range) {
      let snippets: [SnippetPlaceholderView]  = matches.compactMap { match in
        if match.numberOfRanges == 2 {
          if let snippetTextRange = Range(match.range(at: 1)) {
            let snippetText = String(textStorage.string[snippetTextRange])
            let matchRange = match.range(at: 0)
            let snippetRange = NSRange(location: matchRange.location + locationOffset,
                                       length: matchRange.length)
            locationOffset += 1 - matchRange.length

            return createSnippet(in: snippetRange, with: snippetText)
          }
        }
        return nil
      }
      addSnippets(snippets)
    }
  }

}


