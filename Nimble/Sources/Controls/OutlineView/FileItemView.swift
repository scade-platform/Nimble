//
//  FileItemView.swift
//  Nimble

import Cocoa
import NimbleCore

class FileItemView: NSTableCellView {
  let stackErrors = NSStackView()
  
  init(fileItem: FileItem) {
    let field = NSTextField(string: fileItem.description)
    field.isEditable = false
    field.isSelectable = false
    field.isBezeled = false
    field.drawsBackground = false
    field.usesSingleLineMode = false
    field.cell?.wraps = true
    field.cell?.isScrollable = false
    field.font = .systemFont(ofSize: 11)
    
    let img = NSImageView()
    
    super.init(frame: .zero)
    addSubview(field)
    addSubview(stackErrors)
    stackErrors.spacing = 4

    stackErrors.translatesAutoresizingMaskIntoConstraints = false
    field.translatesAutoresizingMaskIntoConstraints = false
    field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    
    if let childrens = fileItem.children, !childrens.isEmpty {
      createErrors(fileItem: fileItem)
      NSLayoutConstraint.activate([
        
        field.heightAnchor.constraint(equalToConstant: 14),
        field.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
        field.topAnchor.constraint(equalTo: topAnchor, constant: 4),
        field.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        
        stackErrors.leadingAnchor.constraint(equalTo: field.trailingAnchor, constant: 4),
        stackErrors.widthAnchor.constraint(equalToConstant: 100),
        stackErrors.heightAnchor.constraint(equalToConstant: 14),
        stackErrors.centerYAnchor.constraint(equalTo: field.centerYAnchor)
      ])
    } else {
      addSubview(img)
      img.image = fileItem.image
      img.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        img.widthAnchor.constraint(equalToConstant: 14),
        img.heightAnchor.constraint(equalToConstant: 14),
        img.leadingAnchor.constraint(equalTo: leadingAnchor),
        img.topAnchor.constraint(equalTo: topAnchor, constant: 5),
        img.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
        
        field.leadingAnchor.constraint(equalTo: img.trailingAnchor, constant: 4),
        field.trailingAnchor.constraint(equalTo: trailingAnchor),
        field.topAnchor.constraint(equalTo: topAnchor, constant: 4),
        field.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
      ])
    }
  }
  
  private func createErrors(fileItem: FileItem) {
    let errors = fileItem.children?.filter({ $0.severity == .error })
    let warnings = fileItem.children?.filter({ $0.severity == .warning })
    
    if let errors = errors, !errors.isEmpty {
      let img = createImage()
      img.image = IconsManager.Icons.error.image
      let countView = createCountView(count: errors.count)
      countView.translatesAutoresizingMaskIntoConstraints = false
      
      stackErrors.addArrangedSubview(img)
      stackErrors.addArrangedSubview(countView)
    }
    
    if let warnings = warnings, !warnings.isEmpty {
      let img = createImage()
      img.image = IconsManager.Icons.warning.image
      let countView = createCountView(count: warnings.count)
      countView.translatesAutoresizingMaskIntoConstraints = false
      stackErrors.addArrangedSubview(img)
      stackErrors.addArrangedSubview(countView)
    }
  }
  
  private func createImage() -> NSImageView {
    let img = NSImageView()
    img.widthAnchor.constraint(equalToConstant: 14).isActive = true
    img.heightAnchor.constraint(equalToConstant: 14).isActive = true
    img.translatesAutoresizingMaskIntoConstraints = false
    return img
  }
  
  private func createCountView(count: Int) -> NSTextField {
    let field = NSTextField(string: "\(count)")
    field.isEditable = false
    field.isSelectable = false
    field.isBezeled = false
    field.translatesAutoresizingMaskIntoConstraints = false
    field.font = .systemFont(ofSize: 11)
    field.alignment = .left
    field.backgroundColor = .clear
    field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    return field
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
