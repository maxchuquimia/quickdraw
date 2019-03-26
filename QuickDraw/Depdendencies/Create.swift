//
//  Create.swift
//  AppReviews
//
//  Created by Max Chuquimia on 27/2/19.
//  Copyright © 2019 Chuquimian Productions. All rights reserved.
//

import Foundation

func create<T>(_ setup: ((T) -> Void)) -> T where T: NSObject {
    let obj = T()
    setup(obj)
    return obj
}
