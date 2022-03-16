
import SwiftUI
import CoreData

struct Stats: View {
    @StateObject var viewRouter: ViewRouter

    var viewModel: ViewModel

    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @FetchRequest(fetchRequest: Game.fetchAll()) var game: FetchedResults<Game>
    @FetchRequest(fetchRequest: Player.fetchAll()) var players: FetchedResults<Player>
    @FetchRequest(fetchRequest: Player.fetchWinsDescending()) var winsDescending: FetchedResults<Player>
    @FetchRequest(fetchRequest: Player.fetchLossesDescending()) var lossessDescending: FetchedResults<Player>
    @FetchRequest(fetchRequest: Player.fetchSecondPlayer()) var secondPlayer: FetchedResults<Player>
    
    
    var body: some View {
        GeometryReader { geometry in
            body(geometry)
        }
    }
    

    func body(_ geometry: GeometryProxy) -> some View {
        let width = geometry.size.width
        let height = geometry.size.height
        
        return ZStack{
            BackgroundImage()
            VStack(){
                backButtonRow(width: width, height: height)
                    .frame(height: height*0.035).padding()
                Text("Stats").font(.largeTitle).padding().foregroundColor(.white)
                playerRow(width: width, height: height)
                overview(width: width, height: height)
                totals(width: width, height: height)
                playerStats(width: width, height: height)
            }.padding()
        }
    }
    
    
    
    func backButtonRow(width: CGFloat, height: CGFloat) -> some View {
        return VStack(alignment:.leading) {
            HStack{
                Circle()
                    .strokeBorder(Color.black, lineWidth: 3.0).opacity(0.3)
                    .background(Circle().fill(Color.white).opacity(0.9))
                    .overlay(Text("<").font(.title2).foregroundColor(.black))
                    .onTapGesture {
                        viewRouter.currentPage = .opponentSelection
                    }
                Text("Back").foregroundColor(.white)
                Rectangle().opacity(0.0).frame(width:width*0.5)
            }
        }
    }
    
    
    
    
    func playerRow(width: CGFloat, height: CGFloat) -> some View {
        return HStack(spacing:width*0.1){
            VStack{
                Circle()
                    .stroke(lineWidth: 1.0)
                    .background(Circle().fill(Color.green))
                    .frame(width:width*0.1)
                    .overlay(Text("P1").foregroundColor(.white))
//                Text("P1").foregroundColor(.white)
            }

            VStack{
                Circle()
                    .stroke(lineWidth: 1.0)
                    .background(Circle().fill(Color.red))
                    .frame(width:width*0.1)
                    .overlay(Text("P2").foregroundColor(.white))

//                Text("P2").foregroundColor(.white)
            }

            VStack{
                Circle()
                    .stroke(lineWidth: 1.0)
                    .background(Circle().fill(Color.gray))
                    .frame(width:width*0.1)
                    .overlay(Text("AI").foregroundColor(.white))
//                    Text("AI").foregroundColor(.white)
            }
        }
        .frame(height:height*0.07)

    }
    
    
    
    
    
    
    
    func overview(width: CGFloat, height: CGFloat) -> some View {
        let p1WinLoss = (players.first!.wins+1) / (players.first!.losses+1)
        let p2WinLoss = (secondPlayer.first!.wins+1) / (secondPlayer.first!.losses+1)
        let aiWinLoss = (players.last!.wins+1) / (players.last!.losses+1)
        let bestWinLoss = players.first!.wins + players.first!.losses == 0 &&
            players.last!.wins + players.last!.losses == 0 &&
            secondPlayer.first!.wins + secondPlayer.first!.losses == 0 ? 0 : max(p1WinLoss, p2WinLoss, aiWinLoss);
        print("bestWinLoss: \(bestWinLoss)")
        var bestWinLossPlayerId: Int
        switch (bestWinLoss){
        case p1WinLoss:
            bestWinLossPlayerId = 0
        case p2WinLoss:
            bestWinLossPlayerId = 1
        case aiWinLoss:
            bestWinLossPlayerId = 2
        default:
            bestWinLossPlayerId = 3
        }

        return VStack(alignment:.leading){
            HStack{
                Text("Overview").font(.title2).foregroundColor(.white)
                Spacer()
            }
            
            HStack{
                Circle()
                    .stroke(lineWidth: 1.0)
                    .background(Circle().fill(stringColorToUiColor(colorId: viewModel.getStatsColors()[winsDescending.first!.wins == 0 ? 3 : Int(winsDescending.first!.id)])))
                    .frame(width:width*0.05)
                Text("Most Wins").foregroundColor(.white)
                Spacer()
                Text("\(winsDescending.first!.wins_)").foregroundColor(.white)
                Rectangle().opacity(0.0).frame(width:width*0.2)
            }
            
            HStack{
                Circle()
                    .stroke(lineWidth: 1.0)
                    .background(Circle().fill(stringColorToUiColor(colorId: viewModel.getStatsColors()[lossessDescending.first!.losses == 0 ? 3 : Int(lossessDescending.first!.id)])))
                    .frame(width:width*0.05)
                Text("Most Losses").foregroundColor(.white)
                Spacer()
                Text("\(lossessDescending.first!.losses_)").foregroundColor(.white)
                Rectangle().opacity(0.0).frame(width:width*0.2)
            }
            
            HStack{
                Circle()
                    .stroke(lineWidth: 1.0)
                    .background(Circle().fill(stringColorToUiColor(colorId: viewModel.getStatsColors()[bestWinLossPlayerId])))
                    .frame(width:width*0.05)
                Text("Best W/L Ratio").foregroundColor(.white)
                Spacer()
                Text("\(bestWinLoss)").foregroundColor(.white)
                Rectangle().opacity(0.0).frame(width:width*0.2)
            }
        }
        .frame(height:height*0.2)
        .padding(.top)
    }
    
    
    

    func totals(width: CGFloat, height: CGFloat) -> some View{
        VStack(){
            HStack{
                Text("Totals").font(.title3).padding(.top)
                    .foregroundColor(.white)
                Spacer()
            }
            .frame(height:height*0.1)
            HStack(spacing:width*0.1){
                VStack{
                    Text("Games").font(.headline).foregroundColor(.white)
                    Text("\(game.first!.games_)").foregroundColor(.white)
                }
                
                VStack{
                    Text("Draws").font(.headline).foregroundColor(.white)
                    Text("\(game.first!.draws_)").foregroundColor(.white)
                }
            
                VStack{
                    Text("Moves").font(.headline).foregroundColor(.white)
                    Text("\(players.first!.moves_ + secondPlayer.first!.moves_ + players.last!.moves_)").foregroundColor(.white)
                }
            }
            .frame(height:height*0.1)
        }
        .frame(height:height*0.2)
    }
    
    
    
    func playerStats(width: CGFloat, height: CGFloat) -> some View {
        VStack(){
            HStack{
                Text("Player Stats").font(.title2).padding(.top).foregroundColor(.white)
                Spacer()
            }
            HStack(spacing:width*0.1){
                    Circle()
                        .stroke(lineWidth: 1.0)
                        .background(Circle().fill(Color.green))
                        .overlay(Text("...").foregroundColor(.white))
                        .frame(width:width*0.1)
                        .onTapGesture {
                            viewRouter.currentPage = .detailedStatsP1
                        }
                
                Circle()
                    .stroke(lineWidth: 1.0)
                    .background(Circle().fill(Color.red))
                    .overlay(Text("...").foregroundColor(.white))
                    .frame(width:width*0.1)
                    .onTapGesture {
                        viewRouter.currentPage = .detailedStatsP2
                    }
                
                Circle()
                    .stroke(lineWidth: 1.0)
                    .background(Circle().fill(Color.gray))
                    .overlay(Text("...").foregroundColor(.white))
                    .frame(width:width*0.1)
                    .onTapGesture {
                        viewRouter.currentPage = .detailedStatsAI
                    }
                
            }
        }
        .frame(height:height*0.2)
    }
    
    
    
    // Converts a String representation of a color to type Color
    func stringColorToUiColor(colorId: String) -> Color {
        switch (colorId){
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "white": return .white
        case "black": return .black
        case "gray": return .gray
        case "pink": return .pink
        default: return .white
        }
    }
}


struct Stats_Previews: PreviewProvider {
    static var previews: some View {
        Stats(viewRouter: ViewRouter(), viewModel: ViewModel())
    }
}
