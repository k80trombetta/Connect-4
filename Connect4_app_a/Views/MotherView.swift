//
//  EmptyViewFile1.swift
//  Connect4ProjectB
//
//  Created by Katie Trombetta on 5/7/21.
//

import SwiftUI
import CoreData

struct MotherView: View {
    
    @StateObject var viewRouter: ViewRouter
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @FetchRequest(fetchRequest: Player.fetchAll()) var players: FetchedResults<Player>
    @FetchRequest(fetchRequest: Player.fetchSecondPlayer()) var secondPlayer: FetchedResults<Player>
    
    var viewModel = StaticViewModel.globalInstance.globalViewModel
    
    var body: some View {
        switch viewRouter.currentPage {
        case .mainMenu:
            MainMenu(viewRouter: viewRouter, viewModel: viewModel)
        case .opponentSelection:
            OpponentSelection(viewRouter: viewRouter, viewModel: viewModel)
        case .stats:
            Stats(viewRouter: viewRouter, viewModel: viewModel)
        case .gameP2:
            GameArea(viewModel: viewModel, viewRouter: viewRouter, opponent: "P2")
        case .gameAI:
            GameArea(viewModel: viewModel, viewRouter: viewRouter, opponent: "AI")
        case .detailedStatsP1:
            DetailedStats(viewRouter: viewRouter, viewModel: viewModel, playerId: players.first!.id_, player: "Player 1")
        case .detailedStatsP2:
            DetailedStats(viewRouter: viewRouter, viewModel: viewModel, playerId: secondPlayer.first!.id_, player: "Player 2")
        case .detailedStatsAI:
            DetailedStats(viewRouter: viewRouter, viewModel: viewModel, playerId: players.last!.id_, player: "AI")
        }
    }
}

struct MotherView_Previews: PreviewProvider {
    static var previews: some View {
        MotherView(viewRouter: ViewRouter())
    }
}
