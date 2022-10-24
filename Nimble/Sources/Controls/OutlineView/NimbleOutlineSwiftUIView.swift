//
//  NimbleOutlineSwiftUIView.swift
//  Nimble


import SwiftUI
import Cocoa
import NimbleCore

struct FileItem: Hashable, Identifiable, CustomStringConvertible {
  var id = UUID()
  var name: String
  var children: [FileItem]? = nil
  var severity: DiagnosticSeverity = .warning
  var description: String {
    switch children {
    case nil:
      return name
    case .some(let children):
      return children.isEmpty ? name : name
    }
  }
  var image: NSImage {
    switch severity {
    case .error: return IconsManager.Icons.error.image
    case .warning: return IconsManager.Icons.warning.image
    case .information: return IconsManager.Icons.error.image
    case .hint: return IconsManager.Icons.error.image
    }
  }
}

struct NimbleOutlineSwiftUIView: View {
    @ObservedObject var model: HostedNimbleOutlineViewModel = .init(data: [FileItem]())
    @Environment(\.colorScheme) var colorScheme

    @State var selection: FileItem?
    @State var separatorColor: Color = Color(NSColor.separatorColor)
    @State var separatorEnabled = false

    var body: some View {
        VStack {
            outlineView
            Divider()
        }
        .background(
            colorScheme == .light
                ? Color(NSColor.textBackgroundColor)
                : Color.clear
        )
    }

    var outlineView: some View {
        OutlineView(
            model.data,
            children: \.children,
            selection: $selection,
            separatorInsets: { fileItem in
                NSEdgeInsets(
                    top: 0,
                    left: 23,
                    bottom: 0,
                    right: 0)
            }
        ) { fileItem in
            FileItemView(fileItem: fileItem)
        }
        .outlineViewStyle(.inset)
        .outlineViewIndentation(20)
        .rowSeparator(separatorEnabled ? .visible : .hidden)
        .rowSeparatorColor(NSColor(separatorColor))
    }
}

struct NimbleOutlineSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
      NimbleOutlineSwiftUIView()
    }
}
