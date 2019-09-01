//
//  GenericUITableViewCell.swift
//  openHAB
//
//  Created by Victor Belov on 15/01/14.
//  Copyright (c) 2014 Victor Belov. All rights reserved.
//
//  Converted to Swift 4 by Tim Müller-Seydlitz and Swiftify on 06/01/18
//

import Alamofire
import os.log
import UIKit

protocol GenericCellCacheProtocol: UITableViewCell {
    func invalidateCache()
}

class GenericUITableViewCell: UITableViewCell {

    private var _widget: OpenHABWidget!
    private var icon: UIImage?
    private weak var imageOperation: Alamofire.Request?
    var widget: OpenHABWidget! {
        get {
            return _widget
        }
        set(widget) {
            _widget = widget

            if _widget.linkedPage != nil {
                accessoryType = .disclosureIndicator
                selectionStyle = .blue
                //        self.userInteractionEnabled = YES;
            } else {
                accessoryType = .none
                selectionStyle = .none
                //        self.userInteractionEnabled = NO;
            }

            if _widget.labelcolor != "" {
                if let color = color(fromHexString: self.widget?.labelcolor) {
                    customTextLabel?.textColor = color
                }
            } else {
                customTextLabel?.textColor = UIColor.black
            }
            if _widget.valuecolor != "" {
                if let color = color(fromHexString: self.widget?.valuecolor) {
                    customDetailTextLabel?.textColor = color
                }
            } else {
                customDetailTextLabel?.textColor = UIColor.lightGray
            }
        }
    }

    @IBOutlet weak var customTextLabel: UILabel!
    @IBOutlet weak var customDetailTextLabel: UILabel!
    @IBOutlet weak var customDetailTextLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var customImageView: UIImageView!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    override init (style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }

    func initialize() {
        selectionStyle = .none
        separatorInset = .zero
    }

    // This is to fix possible different sizes of user icons - we fix size and position of UITableViewCell icons
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.frame = CGRect(x: 13, y: 5, width: 32, height: 32)
    }

    @objc
    func displayWidget() {
        customTextLabel?.text = widget?.labelText
        customDetailTextLabel?.text = widget?.labelValue ?? ""
        customDetailTextLabel?.sizeToFit()
        customImageView?.image = icon
//        self?.imageView?.image = image
        //        customImageView?.image = icon

        if customDetailTextLabel != nil, customDetailTextLabelConstraint != nil {
            if accessoryType == .none {
                // If accessory is disabled, set detailTextLabel (widget value) constraint 20px to the right for padding to the right side of table view
                customDetailTextLabelConstraint.constant = 20.0
            } else {
                // If accessory is enabled, set detailTextLabel (widget value) constraint 0px to the right
                customDetailTextLabelConstraint.constant = 0.0
            }
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageOperation?.cancel()
        customImageView?.image = nil
        imageView?.image = nil
        icon = nil
    }

    func setIcon(to urlRequest: URLRequest, iconType: IconType) {
        imageOperation = NetworkConnection.shared.imageTask(for: urlRequest, iconType: iconType) { [weak self] result in
            switch result {
            case .failure(let error):
                os_log("Icon not found %{PUBLIC}@", log: .viewCycle, type: .info, error.localizedDescription)
//                self?.icon = UIImage(named: "blankicon.png")
                self?.customImageView?.image = UIImage(named: "blankicon.png")
            case .success(let image):
                self?.icon = image
                os_log("Icon found", log: .viewCycle, type: .info)
                self?.customImageView?.image = image
//                self?.imageView?.image = image
            }
        }
    }

}
