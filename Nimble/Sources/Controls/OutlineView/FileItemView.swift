//
//  FileItemView.swift
//  Nimble

import Cocoa

class FileItemView: NSTableCellView {
  init(fileItem: FileItem) {
    let field = NSTextField(string: fileItem.description)
    field.isEditable = false
    field.isSelectable = false
    field.isBezeled = false
    field.drawsBackground = false
    field.usesSingleLineMode = false
    field.cell?.wraps = true
    field.cell?.isScrollable = false
    
    let img = NSImageView()
    
    
    super.init(frame: .zero)
    let countView = createCountView(fileItem: fileItem)
    addSubview(field)
    //addSubview(img)
    
    img.image = fileItem.image
    img.translatesAutoresizingMaskIntoConstraints = false
    field.translatesAutoresizingMaskIntoConstraints = false
    field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    
    if let countView = countView {
      addSubview(countView)
      addSubview(img)
      NSLayoutConstraint.activate([
        img.widthAnchor.constraint(equalToConstant: 14),
        img.heightAnchor.constraint(equalToConstant: 14),
        img.leadingAnchor.constraint(equalTo: leadingAnchor),
        img.topAnchor.constraint(equalTo: topAnchor, constant: 5),
        img.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
        
        field.leadingAnchor.constraint(equalTo: img.trailingAnchor, constant: 4),
        field.topAnchor.constraint(equalTo: topAnchor, constant: 4),
        field.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        
        countView.leadingAnchor.constraint(equalTo: field.trailingAnchor, constant: 4),
        countView.widthAnchor.constraint(equalToConstant: 16),
        countView.topAnchor.constraint(equalTo: field.topAnchor),
        countView.bottomAnchor.constraint(equalTo: field.bottomAnchor)
      ])
    } else {
      NSLayoutConstraint.activate([
        field.leadingAnchor.constraint(equalTo: leadingAnchor),
        field.trailingAnchor.constraint(equalTo: trailingAnchor),
        field.topAnchor.constraint(equalTo: topAnchor, constant: 4),
        field.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
      ])
    }
  }
  
  private func createCountView(fileItem: FileItem) -> NSTextField? {
    guard let childrens = fileItem.children, !childrens.isEmpty else { return nil }
    let field = NSTextField(string: "\(childrens.count)")
    field.isEditable = false
    field.isSelectable = false
    field.isBezeled = false
    field.translatesAutoresizingMaskIntoConstraints = false
    field.backgroundColor = .red
    field.wantsLayer = true
    field.layer?.cornerRadius = 8
    field.alignment = .center
    field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    return field
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
