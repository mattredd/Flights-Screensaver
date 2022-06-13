//
//  Flight.swift
//  Flights Screensaver
//
//  Created by Matthew Reddin on 08/06/2022.
//

import Foundation
import UIKit

struct Flight: Identifiable {
    
    enum FlightSize: Double, CaseIterable {
        case small = 40, medium = 60, large = 80
    }
    
    let id = UUID()
    let startTime: Date
    let speed = Double.random(in: 50...200)
    let direction: FlightDirection
    let size: FlightSize
    var position: (x: Double, y: Double)
    var startingPosition: Double
    let shade: Int
}

extension Flight {
    
    // Returns whether the receiver and *otherFlight* will intersect at any point.
    func willOverlap(_ otherFlight: Flight) -> Bool {
        let flightBoundingBox = calculateFlightRect(for: self)
        let otherFlightBoundingBox = calculateFlightRect(for: otherFlight)
        if direction.isHorizontalMovement == otherFlight.direction.isHorizontalMovement {
            let box = otherFlightBoundingBox.insetBy(dx: -otherFlight.size.rawValue * 0.1, dy: -otherFlight.size.rawValue * 0.1)
            let otherBox = flightBoundingBox.insetBy(dx: -size.rawValue * 0.1, dy: -size.rawValue * 0.1)
            return box.intersects(otherBox)
        }
        let potentialOverlapRect = flightBoundingBox.intersection(otherFlightBoundingBox)
        let (flightEntersBoundingBox, flightLeavesBoundingBox) = self.calculateFlightEntryAndExitTimings(for: potentialOverlapRect)
        let (otherFlightEntersBoundingBox, otherFlightLeavesBoundingBox) = otherFlight.calculateFlightEntryAndExitTimings(for: potentialOverlapRect)
        return (flightEntersBoundingBox...flightLeavesBoundingBox).overlaps(otherFlightEntersBoundingBox...otherFlightLeavesBoundingBox)
    }
    
    // Calculates the rectangle space that *self* will travel in
    private func calculateFlightRect(for flight: Flight) -> CGRect {
        let flightRect: CGRect
        if flight.direction.isHorizontalMovement {
            flightRect = CGRect(x: 0, y: flight.position.y - flight.size.rawValue / 2.0, width: .infinity, height: flight.size.rawValue)
        } else {
            flightRect = CGRect(x: flight.position.x - flight.size.rawValue / 2.0, y: 0, width: flight.size.rawValue, height: .infinity)
        }
        return flightRect
    }
    
    // Calculates
    private func calculateFlightEntryAndExitTimings(for rect: CGRect) -> (entry: Date, exit: Date) {
        let distance: Double
        if direction.isHorizontalMovement {
            distance = direction == .leadingToTrailing ? rect.minX : (startingPosition - rect.maxX)
        } else {
            distance = direction == .topToBottom ? rect.minY : (startingPosition - rect.maxY)
        }
        let flightEntersBoundingBox = startTime.addingTimeInterval((distance - (size.rawValue / 2)) / speed)
        let flightDistance = (direction.isHorizontalMovement ? rect.size.width : rect.size.height) + size.rawValue
        return (flightEntersBoundingBox, flightEntersBoundingBox.addingTimeInterval(flightDistance / speed))
    }
}
