
import Foundation
import CoreData

extension Game {
    @discardableResult
    static func update(from gameAny: Any, in context: NSManagedObjectContext) -> Game {
        guard let gameDict = gameAny as? [String: Any] else {
            return Game()
        }
        
        let gameName = gameDict["name"] as? String
        let predicate = NSPredicate(format: "name_ = %s", gameName!)
        let request = fetchRequest(predicate)
       
        let results = (try? context.fetch(request)) ?? []
        let game = results.first ?? Game(context: context)
        game.name = (gameDict["name"] as? String)! // need to replace this with a more crash-proof code
        game.draws = (gameDict["draws"] as? Int32)!
        game.games = (gameDict["games"] as? Int32)!
        try? context.save()
        game.objectWillChange.send()

        return game
    }
    
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Game> {
        let request = NSFetchRequest<Game>(entityName: "Game")
        request.sortDescriptors = [NSSortDescriptor(key: "name_", ascending: true)]
        request.predicate = predicate
        return request
    }
    
    static func fetchAll() -> NSFetchRequest<Game> {
        let request = NSFetchRequest<Game>(entityName: "Game")
        request.sortDescriptors = [NSSortDescriptor(key: "name_", ascending: true)]
        return request
    }
    
    var name: String {
        get { name_ ?? "Unspecified Game Name for Game"}
        set { name_ = newValue }
    }
    var draws: Int32 {
        get { draws_ }
        set { draws_ = newValue }
    }
    var games: Int32 {
        get { games_ }
        set { games_ = newValue }
    }
    var players: Set<Player> {
        get { players_ as? Set<Player> ?? [] }
        set { players_ = newValue as NSSet }
    }
}
