//
//  FlightDirection.swift
//  Flights Screensaver
//
//  Created by Matthew Reddin on 08/06/2022.
//

import Foundation

enum FlightDirection: Int, CaseIterable {
    
    case leadingToTrailing, trailingToLeading, topToBottom, bottomToTop
    
    var isHorizontalMovement: Bool {
        switch self {
        case .leadingToTrailing, .trailingToLeading:
            return true
        case .topToBottom, .bottomToTop:
            return false
        }
    }
    
    func opposingTrafficDirection() -> FlightDirection {
        switch self {
        case .leadingToTrailing:
            return .trailingToLeading
        case .trailingToLeading:
            return .leadingToTrailing
        case .topToBottom:
            return .bottomToTop
        case .bottomToTop:
            return .topToBottom
        }
    }
}
