//
//  MPButton.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 3/28/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class MPButton: UIButton {

    var actionLink : String?
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        if (self.titleLabel != nil){
            if (self.titleLabel!.font != nil){
                self.titleLabel!.font = UIFont(name: "ProximaNova-Light", size: (self.titleLabel!.font.pointSize))
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        MercadoPagoUIViewController.loadFont("ProximaNova-Light")
        if (self.titleLabel != nil){
            if (self.titleLabel!.font != nil){
                                self.titleLabel!.font = UIFont(name: "ProximaNova-Light", size: (self.titleLabel!.font.pointSize))
            }
        }
    }


}