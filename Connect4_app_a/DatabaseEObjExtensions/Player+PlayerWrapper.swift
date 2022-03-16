
import Foundation
import CoreData

extension Player {
    @discardableResult
    static func update(from playerAny: Any, in context: NSManagedObjectContext) -> Player {
        guard let playerDict = playerAny as? [String: Any] else {
            return Player()
        }
        
        let playerID = playerDict["id"] as? Int32
        let predicate = NSPredicate(format: "id_ = %d", playerID!)
        let request = fetchRequest(predicate)
       
        let results = (try? context.fetch(request)) ?? []
        let player = results.first ?? Player(context: context)
        player.id = (playerDict["id"] as? Int32)! // need to replace this with a more crash-proof code
        player.wins = (playerDict["wins"] as? Int32)!
        player.losses = (playerDict["losses"] as? Int32)!
        player.draws = (playerDict["draws"] as? Int32)!
        player.moves = (playerDict["moves"] as? Int32)!
        player.games = (playerDict["games"] as? Int32)!
        player.game_name = (playerDict["game"] as? String)!
 

        let aPredicate = NSPredicate(format: "name_ = %s", player.game_name)
        let aRequest = Game.fetchRequest(aPredicate)
        let fetchResult = (try? context.fetch(aRequest)) ?? []
        let game = fetchResult.first ?? Game(context: context)
        
        player.game = game
        try? context.save()
        player.objectWillChange.send()

        return player
    }

    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Player> {
        let request = NSFetchRequest<Player>(entityName: "Player")
        request.sortDescriptors = [NSSortDescriptor(key: "id_", ascending: true)]
        request.predicate = predicate
        return request
    }
    
    static func fetchAll() -> NSFetchRequest<Player> {
        let request = NSFetchRequest<Player>(entityName: "Player")
        request.sortDescriptors = [NSSortDescriptor(key: "id_", ascending: true)]
        return request
    }
    
    static func fetchWinsDescending() -> NSFetchRequest<Player> {
        let request = NSFetchRequest<Player>(entityName: "Player")
        request.sortDescriptors = [NSSortDescriptor(key: "wins_", ascending: false)]
        return request
    }
    
    static func fetchLossesDescending() -> NSFetchRequest<Player> {
        let request = NSFetchRequest<Player>(entityName: "Player")
        request.sortDescriptors = [NSSortDescriptor(key: "losses_", ascending: false)]
        return request
    }
    
    static func fetchSecondPlayer() -> NSFetchRequest<Player> {
        let predicate = NSPredicate(format: "id_ = %d", 1)
        let request = NSFetchRequest<Player>(entityName: "Player")
        request.sortDescriptors = [NSSortDescriptor(key: "id_", ascending: false)]
        request.predicate = predicate
        return request
    }
    

    static func bestWinLossId() -> NSFetchRequest<Player> {
        let predicate = NSPredicate(format: "wins_ / losses_")
        let request = NSFetchRequest<Player>(entityName: "Player")
        request.sortDescriptors = [NSSortDescriptor(key: "id_", ascending: false)]
        request.predicate = predicate
        return request
    }

    
    public var id: Int32 {
        get { id_ }
        set { id_ = newValue }
    }
    var wins: Int32 {
        get { wins_ }
        set { wins_ = newValue }
    }
    var losses: Int32 {
        get { losses_ }
        set { losses_ = newValue }
    }
    var draws: Int32 {
        get { draws_ }
        set { draws_ = newValue }
    }
    var moves: Int32 {
        get { moves_ }
        set { moves_ = newValue }
    }
    var games: Int32 {
        get { games_ }
        set { games_ = newValue }
    }
    var game_name: String {
        get { game_name_ ?? "Unspecified Game Name for Player" }
        set { game_name_ = newValue }
    }
    var game: Game {
        get { connect4game_! }
        set { connect4game_ = newValue }
    }
}
