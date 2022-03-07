//
//  Synchronicity.swift
//  AppReviews
//
//  Created by Max Chuquimia on 21/2/19.
//  Copyright © 2019 Chuquimian Productions. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static let background = DispatchQueue(label: "the-background")

    static var isBackground: Bool {
        return OperationQueue.current?.underlyingQueue == DispatchQueue.background
    }

    static var isMain: Bool {
        return OperationQueue.current?.underlyingQueue == DispatchQueue.main
    }
}

protocol AsyncFunctions: class { }

extension AsyncFunctions {

    func async(_ code: @escaping () -> ()) {

        if DispatchQueue.isBackground {
            code()
        } else {
            DispatchQueue.background.async(execute: code)
        }
    }

    func async(_ code: @escaping (Self) -> ()) {
        if DispatchQueue.isBackground {
            code(self)
        } else {
            DispatchQueue.background.async { [weak self] in
                guard let self = self else { return }
                code(self)
            }
        }
    }

    func main(_ code: @escaping () -> ()) {
        if DispatchQueue.isMain {
            code()
        } else {
            DispatchQueue.main.async(execute: code)
        }
    }

    func main(_ code: @escaping (Self) -> ()) {
        if DispatchQueue.isMain {
            code(self)
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                code(self)
            }
        }
    }

}
