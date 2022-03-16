
import Foundation
import CoreData
import Combine
import SwiftUI

class SeedDatabase {
    private let schemaUrlString = "https://api.jsonbin.io/b/608c6381d64cd16802a58385/1"
    private var schemaDownloadCancellable: AnyCancellable?

    
    @Published private var schema: [String:Any]?
    private var gameSchema: [String:Any] {
        get {
            return schema ?? [String:Any]();
        }
        set {
              schema = newValue
        }
    }

    
      private var gameList: [Game]?
      private var playerList: [Player]?
    
    
    
    func downloadDatabaseSchema(context: NSManagedObjectContext) {
        guard let url = URL(string: schemaUrlString) else {
            print("\(schemaUrlString) is not a valid URL.")
            return
        }
        schemaDownloadCancellable?.cancel()
        schemaDownloadCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { dataReceived, urlResponse -> [String:Any] in
                do {
                    let schemaDict = try JSONSerialization.jsonObject(with: dataReceived, options: []) as? [ [String: Any] ]
                    
                    guard let schema = schemaDict else {
                        print("unabel to unwrap schema")
                        return [String:Any]()
                    }
                    self.processDownloadedSchema(schema: schema, context: context)
                    return [String:Any]()
                } catch {
                    print("failed to download from \(self.schemaUrlString) due to \(error)")
                }
                return [String:Any]()
            }
            .replaceError(with: [String:Any]())
            .receive(on: DispatchQueue.main)
            .assign(to: \.gameSchema, on: self)
    }
    
    
    
    func processDownloadedSchema(schema: [ [String:Any] ], context: NSManagedObjectContext) {
        // This will execute twice, once for the Player dictionary and once for the Game dict
        for idx in 0..<schema.count {
            // player should cast to an array of dictionaries with string keys and any values
            if let player = schema[idx]["Player"] as? [[String: Any]] {
                    processDownloadedPlayerSchema(playerSchema: player, context: context)
            }
            // game should cast to a dictionary with string keys and any values
            else if let game = schema[idx]["Game"] as? [String: Any] {
                for idx in 0..<game.count {
                    print("game attribute idx: \(idx)")
                }
                Game.update(from: game, in: context)
            }
        }
        print("Total schema count (should be 2): \(schema.count)\n")
    }

    
    
    func processDownloadedPlayerSchema(playerSchema: [ [String: Any] ], context: NSManagedObjectContext) {
        print("player has \(playerSchema.count) elements")
        for idx in 0..<playerSchema.count {
            Player.update(from: playerSchema[idx], in: context)
            print("player idx: \(idx)")
        }
    }
}
