//
//  PoPUpLoadingView.swift
//  ArMeasure
//
//  Created by Hermann Dorio on 03/04/2018.
//  Copyright © 2018 Hermann Dorio. All rights reserved.
//

import UIKit

class PoPUpLoadingView: UIView {

    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var contentView: UIView!
    
    var textInfo: String? {
        didSet{
            guard let text = textInfo else {
                return
            }
            titleLabel.text = text
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    private func initView() {
        Bundle.main.loadNibNamed("PopUpLoadingView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.layer.cornerRadius = 3.0
    }
    
    func startLoader() {
        self.isHidden = false
        loader.startAnimating()
    }
    
    func stopLoader() {
        self.isHidden = true
        loader.stopAnimating()
    }

}
