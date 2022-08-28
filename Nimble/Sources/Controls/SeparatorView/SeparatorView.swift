//
//  SeparatorView.swift
//  Nimble
//
//  Created by Alex Yehorov on 28.08.2022.
//  Copyright © 2022 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class SeparatorView: NSView, WorkbenchStatusBarItem {
    private lazy var separator: NSView = {
        let vvv = NSView()
        vvv.setBackgroundColor(.darkGray.withAlphaComponent(0.4))
        vvv.translatesAutoresizingMaskIntoConstraints = false
        return vvv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(separator)
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 12),
            separator.widthAnchor.constraint(equalToConstant: 1),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            separator.topAnchor.constraint(equalTo: topAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
