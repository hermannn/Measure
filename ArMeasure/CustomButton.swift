//
//  CustomButton.swift
//  ArMeasure
//
//  Created by Hermann Dorio on 05/04/2018.
//  Copyright © 2018 Hermann Dorio. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = .white
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10)
        self.setTitleColor(tintColor, for: .normal)
        self.layer.cornerRadius = 5
    }

}
