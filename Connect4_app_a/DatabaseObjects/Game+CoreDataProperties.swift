//
//  Game+CoreDataProperties.swift
//  Connect4_app_a
//
//  Created by Katie Trombetta on 5/12/21.
//
//

import Foundation
import CoreData


extension Game {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Game> {
        return NSFetchRequest<Game>(entityName: "Game")
    }

    @NSManaged public var name_: String?
    @NSManaged public var draws_: Int32
    @NSManaged public var games_: Int32
    @NSManaged public var players_: NSSet?

}

// MARK: Generated accessors for players_
extension Game {

    @objc(addPlayers_Object:)
    @NSManaged public func addToPlayers_(_ value: Player)

    @objc(removePlayers_Object:)
    @NSManaged public func removeFromPlayers_(_ value: Player)

    @objc(addPlayers_:)
    @NSManaged public func addToPlayers_(_ values: NSSet)

    @objc(removePlayers_:)
    @NSManaged public func removeFromPlayers_(_ values: NSSet)

}

extension Game : Identifiable {

}
