//
//  URLSession+Synced.swift
//  AppReviews
//
//  Created by Max Chuquimia on 22/2/19.
//  Copyright © 2019 Chuquimian Productions. All rights reserved.
//

import Foundation

extension URLSession {

    func synchronousDataTask(with request: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?) {
        let semaphore = DispatchSemaphore(value: 0)

        var data: Data?
        var response: URLResponse?
        var error: Error?

        let task = URLSession.shared.dataTask(with: request) {
            data = $0
            response = $1
            error = $2
            semaphore.signal()
        }

        task.resume()

        semaphore.wait()

        return (data, response, error)
    }
}
