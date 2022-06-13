//
//  FlightStore.swift
//  Flights Screensaver
//
//  Created by Matthew Reddin on 08/06/2022.
//

import SwiftUI

class FlightStore: ObservableObject {
    
    @Published var flights: [Flight] = []
    var lastUpdate: Date?
    
    func updateModel(skySize: CGSize, for date: Date ) {
        updateFlights(skySize: skySize, for: date)
        if lastUpdate != nil && date.timeIntervalSince(lastUpdate!) < 0.25  {
            return
        }
        lastUpdate = date
        addFlight(skySize: skySize, for: date)
    }
    
    func updateFlights(skySize: CGSize, for date: Date) {
        // Update the position of the flight with regards to the date
        for i in flights.indices {
            let timeInterval = -flights[i].startTime.timeIntervalSince(date)
            let distanceTravelled = flights[i].speed * timeInterval
            switch flights[i].direction {
            case .topToBottom:
                flights[i].position.y = distanceTravelled
            case .bottomToTop:
                flights[i].position.y = flights[i].startingPosition - distanceTravelled
            case .leadingToTrailing:
                flights[i].position.x = distanceTravelled
            case .trailingToLeading:
                flights[i].position.x = flights[i].startingPosition - distanceTravelled
            }
        }
        // Remove flight if it is not on screen
        flights.removeAll { flight in
            let isFlightStillWithinHorizotonalSkyBounds = (-flight.size.rawValue / 2)..<(skySize.width + flight.size.rawValue) ~= flight.position.x
            let isFlightStillWithinVerticalSkyBounds = (-flight.size.rawValue / 2)..<(skySize.height + flight.size.rawValue) ~= flight.position.y
            return !(isFlightStillWithinHorizotonalSkyBounds && isFlightStillWithinVerticalSkyBounds)
        }
    }
    
    func addFlight(skySize: CGSize, for date: Date) {
        // Attempt to add a flight to the screen. Only make 10 attempts
        for _ in 0..<10 {
            let direction = FlightDirection.allCases.randomElement()!
            let position: (Double, Double)
            let startingPoint: Double
            let flightSize = Flight.FlightSize.allCases.randomElement()!
            switch direction {
            case .leadingToTrailing:
                startingPoint = -flightSize.rawValue / 2
                position = (startingPoint, Double.random(in: (flightSize.rawValue / 2)..<(skySize.height - flightSize.rawValue / 2)))
            case .trailingToLeading:
                startingPoint = Double(skySize.width) + flightSize.rawValue / 2
                position = (startingPoint, Double.random(in: (flightSize.rawValue / 2)..<(skySize.height - flightSize.rawValue / 2)))
            case .topToBottom:
                startingPoint = -flightSize.rawValue / 2
                position = (Double.random(in: (flightSize.rawValue / 2)..<(skySize.width - flightSize.rawValue / 2)), startingPoint)
            case .bottomToTop:
                startingPoint = Double(skySize.height) + flightSize.rawValue / 2
                position = (Double.random(in: (flightSize.rawValue / 2)..<(skySize.width - flightSize.rawValue / 2)), startingPoint)
            }
            let newFlight = Flight(startTime: date, direction: direction, size: flightSize , position: position, startingPosition: startingPoint, shade: Int.random(in: 0..<5))
            guard !flights.isEmpty else {
                flights.append(newFlight)
                return
            }
            // Calculate if flight overlaps another flight
            let flightOverlaps = flights.reduce(false) { partialResult, flight in
                partialResult || flight.willOverlap(newFlight)
            }
            if !flightOverlaps {
                flights.append(newFlight)
                return
            }
        }
    }
}
