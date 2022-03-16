//
//  Player+CoreDataProperties.swift
//  Connect4_app_a
//
//  Created by Katie Trombetta on 5/12/21.
//
//

import Foundation
import CoreData


extension Player {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }

    @NSManaged public var game_name_: String?
    @NSManaged public var draws_: Int32
    @NSManaged public var games_: Int32
    @NSManaged public var id_: Int32
    @NSManaged public var losses_: Int32
    @NSManaged public var moves_: Int32
    @NSManaged public var wins_: Int32
    @NSManaged public var connect4game_: Game?

}

extension Player : Identifiable {

}
