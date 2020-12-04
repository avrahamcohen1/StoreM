//
//  Orders.swift
//  c9
//
//  Created by Uzi Benoliel on 5/13/20.
//  Copyright © 2020 Uzi Benoliel. All rights reserved.
//

class Orders {
    var orderId: Int64
    var orderDate: Date?
    var orderInfo: String?
    var userNotes: String?
    var vendorStyle: String?
    var orderStatus: String?
    var imageFileName: String?
    var itemID: Int64?
    var qty: Int?
    var orderType:Int?
        
    init(orderId: Int64, orderDate: Date?, orderInfo: String?,  vendorStyle: String?, orderStatus: String?, imageFileName: String?, itemID:Int64?, qty:Int?, orderType:Int?, userNotes:String?) {
        self.orderId = orderId
        self.orderDate = orderDate
        self.orderInfo = orderInfo
        self.vendorStyle = vendorStyle
        self.orderStatus = orderStatus
        self.imageFileName = imageFileName
        self.itemID = itemID
        self.qty = qty
        self.orderType = orderType
        self.userNotes = userNotes
    }
}
