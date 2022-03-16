
import SwiftUI
import CoreData

struct DetailedStats: View {
    @StateObject var viewRouter: ViewRouter
    var viewModel: ViewModel
    var playerId: Int32
    let player: String //This will be Player 1, Player 2, or AI
    //let context: NSManagedObjectContext
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @FetchRequest(fetchRequest: Player.fetchAll()) var players: FetchedResults<Player>
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
            VStack() {
                backButtonRow(width: width, height: height)
                    .frame(height: height*0.035).padding()
                Text("Stats for \(player)").font(.largeTitle).padding().foregroundColor(.white)
                playerCircle(width: width, height: height, playerId: Int(playerId))
                overview(width: width, height: height, playerId: playerId)
                Spacer()
            }
            .padding()
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
                        viewRouter.currentPage = .stats
                    }
                Text("Back").foregroundColor(.white)
                Rectangle().opacity(0.0).frame(width:width*0.5)
            }
        }
    }
    
    
    func overview(width: CGFloat, height: CGFloat, playerId: Int32) -> some View {
        let statsLabel = ["Wins", "Losses", "Win/Loss Ratio", "Draws", "Games", "Moves"]
        let statsForPlayer = getStatsForPlayer(pid: playerId)
        
        return VStack(alignment:.leading){
            HStack{
                Text("Overview").font(.title2).foregroundColor(.white)
                Spacer()
            }
            ForEach(0..<statsLabel.count){ statIdx in
                allPlayerStats(statsLabel: statsLabel[statIdx], stat: statsForPlayer[statIdx], width: width, height: height)
            }
        }
        .frame(height:height*0.25)
        .padding(.top)
    }
    
    
    
    func getStatsForPlayer(pid: Int32) -> [Int32]{
        if pid == Int32(0){
            return [players.first!.wins_, players.first!.losses_, players.first!.wins_ == Int32(0) && players.first!.losses_ == Int32(0) ? Int32(0) : Int32((players.first!.wins_ + Int32(1)) / (players.first!.losses_ + Int32(1))),  players.first!.draws_, players.first!.games_, players.first!.moves_]
        }
        else if pid == Int32(1){
            return [secondPlayer.first!.wins_, secondPlayer.first!.losses_, secondPlayer.first!.wins_ == Int32(0) && secondPlayer.first!.losses_ == Int32(0) ? Int32(0) : Int32((secondPlayer.first!.wins_ + Int32(1)) / (secondPlayer.first!.losses_ + Int32(1))),  secondPlayer.first!.draws_, secondPlayer.first!.games_, secondPlayer.first!.moves_]
        }
        else{
            return [players.last!.wins_, players.last!.losses_, players.last!.wins_ == Int32(0) && players.last!.losses_ == Int32(0) ? Int32(0) : Int32((players.last!.wins_ + Int32(1)) / (players.last!.losses_ + Int32(1))),  players.last!.draws_, players.last!.games_, players.last!.moves_]
        }
    }
    
    
    
    
    func allPlayerStats(statsLabel: String, stat: Int32, width: CGFloat, height: CGFloat) -> some View {
        return
            HStack{
                Text("\(statsLabel)").foregroundColor(.white)
                Spacer()
                Text("\(stat)").foregroundColor(.white)
                Rectangle().opacity(0.0).frame(width:width*0.2)
            }
    }
    
    
    
    
    func playerCircle(width: CGFloat, height: CGFloat, playerId: Int) -> some View {
        return VStack {
            Circle()
                .stroke(lineWidth: 1.0)
                .background(Circle().fill(stringColorToUiColor(colorId: viewModel.getStatsColors()[playerId])))
                .frame(width:width*0.1)
            Text("\(viewModel.playerNames()[playerId])").foregroundColor(.white)
        }.frame(height: height*0.1)
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

struct DetailedStats_Previews: PreviewProvider {
    static var previews: some View {
        DetailedStats(viewRouter: ViewRouter(), viewModel: ViewModel(), playerId: Int32(-1), player: "Some Player"/*, context: NSManagedObjectContext()*/)
    }
}
