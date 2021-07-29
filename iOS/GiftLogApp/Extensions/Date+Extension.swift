//
//  Date+Extension.swift
//
//
//  Created by Webs The Word on 10/28/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

enum DateUnit: Int {
    case day = 0
    case week
    case month
}

extension Date {
    
    func timestamp() -> Int64 {
        return Int64(self.timeIntervalSince1970)
    }
    
    func formattedDateAndTimeString() -> String {
        let gbDateFormat = DateFormatter.dateFormat(fromTemplate: "ddMMyyyy hh:mm a", options: 0, locale: Locale(identifier: "en-GB"))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = gbDateFormat
        return dateFormatter.string(from: self) // return format 14/04/2017
    }
    
    func formattedDateString() -> String {
        let gbDateFormat = DateFormatter.dateFormat(fromTemplate: "ddMMyyyy", options: 0, locale: Locale(identifier: "en-GB"))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = gbDateFormat
        return dateFormatter.string(from: self) // return format 14/04/2017
    }
    
    func isLessThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
    
        //Return Result
        return isLess
    }

}
