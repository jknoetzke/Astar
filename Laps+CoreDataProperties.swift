//
//  Laps+CoreDataProperties.swift
//  Astar
//
//  Created by Justin Knoetzke on 2020-12-11.
//
//

import Foundation
import CoreData


extension Laps {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Laps> {
        return NSFetchRequest<Laps>(entityName: "Laps")
    }

    @NSManaged public var average_hr: Int16
    @NSManaged public var average_speed: Int16
    @NSManaged public var average_watts: Int16
    @NSManaged public var distance: Int16
    @NSManaged public var elevation: Int16
    @NSManaged public var lap_number: Int16
    @NSManaged public var lap_time: Double
    @NSManaged public var ride_id: UUID?
    @NSManaged public var completedrides: CompletedRide?

}

extension Laps : Identifiable {

}
