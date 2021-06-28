//
//  CompletedRide+CoreDataProperties.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-12-11.
//
//

import Foundation
import CoreData


extension CompletedRide {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CompletedRide> {
        return NSFetchRequest<CompletedRide>(entityName: "CompletedRide")
    }

    @NSManaged public var average_watts: Int16
    @NSManaged public var calories: Int16
    @NSManaged public var distance: Int16
    @NSManaged public var elevation: Int16
    @NSManaged public var initial_elevation: Int16
    @NSManaged public var map_image: Data?
    @NSManaged public var ride_date: Date?
    @NSManaged public var ride_id: UUID?
    @NSManaged public var ride_time: Double
    @NSManaged public var laps: NSSet?

    public var lapsArray: [Laps] {
        let set = laps as? Set<Laps> ?? []
        
        return set.sorted {
            $0.lap_number < $1.lap_number
        }
    }

}

// MARK: Generated accessors for laps
extension CompletedRide {

    @objc(addLapsObject:)
    @NSManaged public func addToLaps(_ value: Laps)

    @objc(removeLapsObject:)
    @NSManaged public func removeFromLaps(_ value: Laps)

    @objc(addLaps:)
    @NSManaged public func addToLaps(_ values: NSSet)

    @objc(removeLaps:)
    @NSManaged public func removeFromLaps(_ values: NSSet)

}

extension CompletedRide : Identifiable {

}
