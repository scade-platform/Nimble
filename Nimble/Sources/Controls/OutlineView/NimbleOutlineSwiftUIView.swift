//
//  NimbleOutlineSwiftUIView.swift
//  Nimble


import SwiftUI
import Cocoa

struct FileItem: Hashable, Identifiable, CustomStringConvertible {
    var id = UUID()
    var name: String
    var children: [FileItem]? = nil
    var description: String {
        switch children {
        case nil:
            return "📄 \(name)"
        case .some(let children):
            return children.isEmpty ? "📂 \(name)" : "📁 \(name)"
        }
    }
}

let data = [
    FileItem(name: "doc001.txt"),
    FileItem(
        name: "users",
        children: [
            FileItem(
                name: "user1234",
                children: [
                    FileItem(
                        name: "Photos",
                        children: [
                            FileItem(name: "photo001.jpg"),
                            FileItem(name: "photo002.jpg")]),
                    FileItem(
                        name: "Movies",
                        children: [FileItem(name: "movie001.mp4")]),
                    FileItem(name: "Documents", children: [])]),
            FileItem(
                name: "newuser",
                children: [FileItem(name: "Documents", children: [])])
        ]
    )
]

@available(macOS 11.0, *)
struct NimbleOutlineSwiftUIView: View {
    @Environment(\.colorScheme) var colorScheme

    @State var selection: FileItem?
    @State var separatorColor: Color = Color(NSColor.separatorColor)
    @State var separatorEnabled = false

    var body: some View {
        VStack {
            outlineView
            Divider()
            configBar
        }
        .background(
            colorScheme == .light
                ? Color(NSColor.textBackgroundColor)
                : Color.clear
        )
    }

    var outlineView: some View {
        OutlineView(
            data,
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

    var configBar: some View {
        HStack {
            Spacer()
            ColorPicker(
                "Set separator color:",
                selection: $separatorColor)
            Button(
                "Toggle separator",
                action: { separatorEnabled.toggle() })
        }
        .padding([.leading, .bottom, .trailing], 8)
    }
}

@available(macOS 11.0, *)
struct NimbleOutlineSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
      NimbleOutlineSwiftUIView()
    }
}
