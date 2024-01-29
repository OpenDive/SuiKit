//
//  File.swift
//  
//
//  Created by Marcus Arnett on 1/29/24.
//

import Foundation

extension DateFormatter {
    static func unixTimestamp(from dateString: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = dateFormatter.date(from: dateString) else {
            return nil
        }
        return Int(date.timeIntervalSince1970 * 1_000)
    }
}
