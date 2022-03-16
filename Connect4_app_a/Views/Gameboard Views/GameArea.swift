
import SwiftUI
import CoreData

struct GameArea: View {
    //var viewModel: ViewModel
    @ObservedObject var viewModel = ViewModel()
    @StateObject var viewRouter: ViewRouter

    let opponent: String
    
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @FetchRequest(fetchRequest: Game.fetchAll()) var game: FetchedResults<Game>
    @FetchRequest(fetchRequest: Player.fetchAll()) var players: FetchedResults<Player>
    @FetchRequest(fetchRequest: Player.fetchWinsDescending()) var winsDescending: FetchedResults<Player>
    @FetchRequest(fetchRequest: Player.fetchSecondPlayer()) var secondPlayer: FetchedResults<Player>
    
    var body: some View {
        GeometryReader { geometry in
            body(geometry, opponent: opponent)
        }
    }

    func body(_ geometry: GeometryProxy, opponent: String)  -> some View {
        let width = geometry.size.width
        let height = geometry.size.height
        
        return ZStack{
            BackgroundImage()
            VStack{
                backButtonRow(width: width, height: height)
                    .frame(height: height*0.035).padding()
                Text("You VS \(opponent)")
                    .font(.largeTitle).frame(height:height*0.1).foregroundColor(.white)
                buttonRow(width: width, height: height)
                piecesLeftRow(width: width, height: height)
                gameBoard(width: width, height: height)
            }.padding()
        }
    }
    
    
    
    func buttonRow(width: CGFloat, height: CGFloat) -> some View {
        return HStack(spacing: width*0.1) {
            
            Circle()
                .strokeBorder(Color.black, lineWidth: 3.0).opacity(0.3)
                .background(Circle().fill(Color.green).frame(width: width * 0.5))
//                .frame(width: width * 0.2)
                .overlay(Text("New").font(.caption).foregroundColor(.white).multilineTextAlignment(.center).padding())
                .hoverEffect()
                .onTapGesture {
                    viewModel.didTapReset()
                    viewRouter.currentPage = .opponentSelection
                }
            
            
            Circle()
                .strokeBorder(Color.black, lineWidth: 3.0).opacity(0.3)
                .background(Circle().fill(Color.blue).frame(width: width * 0.5))
//                .frame(width: width * 0.3)
                .hoverEffect()
                .overlay(Text("Reset").font(.caption).foregroundColor(.white)).onTapGesture {
                    viewModel.didTapReset()
                }
            Circle()
                .strokeBorder(Color.black, lineWidth: 3.0).opacity(0.3)
                .background(Circle().fill(Color.red).frame(width: width * 0.5))
//                .frame(width: width * 0.3)
                .hoverEffect()
                .overlay(Text("Quit").font(.caption).foregroundColor(.white).padding())
                .onTapGesture {
                    viewModel.didTapReset()
                    viewRouter.currentPage = .mainMenu
                }
            
        }
        .frame(height: height * 0.1).padding()
    }
    
    
    
    func piecesLeftRow(width: CGFloat, height: CGFloat) -> some View {
        var turnStatus: String = ""
        var whoWon: String = ""
        
        //Handle logic for Pass and Play
        if(opponent == "P2") {
            if(viewModel.getDrawStatus()) {
                whoWon = "Draw!"
            } else {
                turnStatus = viewModel.getTurnStatus() ? "Player 1's Turn" : "Player 2's Turn"
                whoWon = viewModel.getTurnStatus() ? "Player 2 wins!" : "Player 1 wins!"
            }
        }
        //Handle logic for AI
        else if(opponent == "AI") {
            if(viewModel.getDrawStatus()) {
                whoWon = "Draw!"
            } else {
                turnStatus = viewModel.getTurnStatus() ? "Player 1's Turn" : "AI's Turn"
                whoWon = viewModel.getTurnStatus() ? "AI wins!" : "Player 1 wins!"
            }
        }
        
        return HStack{
            Circle()
                .strokeBorder(Color.black, lineWidth: 3.0).opacity(0.3)
                .background(Circle().fill(Color.green))
                .frame(width: width*0.07)
            Text("\(viewModel.getPlayerPiecesLeft(player: 0))").foregroundColor(.white)
            Spacer()
            Text(viewModel.getGameStatus() ? turnStatus : whoWon).font(.headline).foregroundColor(.white)
            Spacer()
            Text("\(viewModel.getPlayerPiecesLeft(player: 1))").foregroundColor(.white)
            Circle()
                .strokeBorder(Color.black, lineWidth: 3.0).opacity(0.3)
                .background(Circle().fill(Color.red))
                .frame(width: width*0.07)
        }
    }
    
    
    
    func gameBoard(width: CGFloat, height: CGFloat) -> some View {
        
        var p1Updates: [String:Any] = populatePlayerUpdate(id: 0)
        var p2Updates: [String:Any] = populatePlayerUpdate(id: 1)
        var aiUpdates: [String:Any] = populatePlayerUpdate(id: 2)
        var gameUpdates: [String:Any] = populateGameUpdateAttributes()

        return ZStack{
            RoundedRectangle(cornerRadius: CGFloat(viewModel.getBoardCornerRadius())).fill(Color.white).opacity(0.95)
                .overlay(RoundedRectangle(cornerRadius: CGFloat(viewModel.getBoardCornerRadius())).stroke(Color.green, lineWidth: 3))
            GameboardRow(items: viewModel.gameBoard()) { row in
                GameboardCol(items: row.gameRowCircles){ circle in
                    GameCircleView(gameCircle: circle, color: stringColorToUiColor(colorId: circle.highlighted ? "blue" : circle.color))
                        .onTapGesture{
                            
                            if(viewModel.getGameStatus()) {
                                if(opponent == "P2"){
                                    let thisTurn = viewModel.getTurnStatus()
                                    viewModel.handleGameCircleTap(row: circle.pos.0, col: circle.pos.1)
                                    
                                    // Increment moves count based on thisTurn switched
                                    if thisTurn != viewModel.getTurnStatus(){
                                        adjustPlayerMoves(turnStatus: !viewModel.getTurnStatus(), p1: &p1Updates, p2: &p2Updates, ai: &aiUpdates, opponent: opponent)
                                    }
                                    //Prints turn status to console for testing purposes
                                    let turnStatus: String = viewModel.getTurnStatus() ? "Player 1" : "Player 2"
                                    let whoWon: String = viewModel.getTurnStatus() ? "Player 2" : "Player 1"
                                    
                                    if(viewModel.didTapCheckForWin()) {
                                        print("\(whoWon) wins!")
                                        adjustWinsLosses(whoWon: whoWon, opponent: opponent, p1: &p1Updates, p2: &p2Updates, ai: &aiUpdates)
                                        adjustPlayerGames(p1: &p1Updates, p2: &p2Updates, ai: &aiUpdates, opponent: opponent)
                                        adjustGameGames(gameUpdates: &gameUpdates)
                                    }
                                    else if(viewModel.getDrawStatus()) {
                                        print("Draw!")
                                        adjustPlayerDraws(opponent: opponent, p1: &p1Updates, p2: &p2Updates, ai: &aiUpdates)
                                        adjustGameDraws(gameUpdates: &gameUpdates)
                                      }
                                    else{
                                        print("No win.")
                                        print("\(turnStatus)'s turn!")
                                    }
                                }
                                
                                //Handle logic for AI
                                if(opponent == "AI") {
                                    let _: Int = Int.random(in: 0..<7)
                                    //Player first chooses a spot
                                    let thisTurn = viewModel.getTurnStatus()
                                    viewModel.handleGameCircleTap(row: circle.pos.0, col: circle.pos.1)
                                    
                                    // Increment moves count based on thisTurn switched
                                    if thisTurn != viewModel.getTurnStatus(){
                                        adjustPlayerMoves(turnStatus: !viewModel.getTurnStatus(), p1: &p1Updates, p2: &p2Updates, ai: &aiUpdates, opponent: opponent)
                                    }
                                    //AI places piece when it is not P1's turn and when the game is still going
                                    if(!viewModel.getTurnStatus() && viewModel.getGameStatus()){
                                        viewModel.placeAIPiece(col: viewModel.handleAI())
                                    }
                                    else if (!viewModel.getGameStatus()){
                                        if(viewModel.getDrawStatus()){
                                            adjustPlayerDraws(opponent: opponent, p1: &p1Updates, p2: &p2Updates, ai: &aiUpdates)
                                            adjustGameDraws(gameUpdates: &gameUpdates)
                                        }else{
                                            adjustWinsLosses(whoWon: viewModel.getTurnStatus() ? "Player 2" : "Player 1", opponent: opponent, p1: &p1Updates, p2: &p2Updates, ai: &aiUpdates)
                                        }
                                        adjustPlayerMoves(turnStatus: viewModel.getTurnStatus(), p1: &p1Updates, p2: &p2Updates, ai: &aiUpdates, opponent: opponent)
                                        adjustPlayerGames(p1: &p1Updates, p2: &p2Updates, ai: &aiUpdates, opponent: opponent)
                                        adjustGameGames(gameUpdates: &gameUpdates)
                                    }
                                }
                            }
                        }
                }
            }
        }
        .frame(height: height * 0.5, alignment: .bottom)
        .padding()
    }
    
    
    
    
    
    // Game Circles defined in Model
    struct GameCircleView: View{
        let gameCircle: Model.GameCircle
        let color: Color
        var body: some View {
            Circle()
                .strokeBorder(Color.black, lineWidth: 3.0).opacity(0.5)
                .background(Circle().fill(color == Color.white ? Color.black : color))
        }
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
    
    
    
    
    
    
    func populateGameUpdateAttributes() -> [String:Any]{
        return [
            "name":"Connect4",
            "games": game.first!.games,
            "draws": game.first!.draws
          ]
    }
    
    
    
    
    
    func populatePlayerUpdate(id: Int) -> [String:Any]{
        if id == 0{
            return ["id":players.first!.id,"wins":players.first!.wins,"losses":players.first!.losses,"draws":players.first!.draws,
                    "moves":players.first!.moves,"games":players.first!.games,"game":players.first!.game_name]
        }
        else if id == 1{
            return ["id":secondPlayer.first!.id,"wins":secondPlayer.first!.wins,"losses":secondPlayer.first!.losses,"draws":secondPlayer.first!.draws,
                    "moves":secondPlayer.first!.moves,"games":secondPlayer.first!.games,"game":players.first!.game_name]
        }
        else{
            return ["id":players.last!.id,"wins":players.last!.wins,"losses":players.last!.losses,"draws":players.last!.draws,
                    "moves":players.last!.moves,"games":players.last!.games,"game":players.first!.game_name]
        }
    }
    
    
    
    

    func adjustWinsLosses(whoWon: String, opponent: String, p1: inout [String:Any], p2: inout [String:Any], ai: inout [String:Any]) {

        if whoWon == "Player 1"{
            players.first!.wins += 1
            p1["wins"] = players.first!.wins
            Player.update(from: p1, in: context)
            if opponent == viewModel.playerNames()[1]{
                secondPlayer.first!.losses += 1
                p2["losses"] = secondPlayer.first!.losses
                Player.update(from: p2, in: context)
            }else{
                players.last!.losses += 1
                ai["losses"] = players.last!.losses
                Player.update(from: ai, in: context)
            }
        }
        else{
            if opponent == viewModel.playerNames()[1]{
                secondPlayer.first!.wins += 1
                p2["wins"] = secondPlayer.first!.wins
                Player.update(from: p2, in: context)
            }else{
                players.last!.wins += 1 // fix
                ai["wins"] = players.last!.wins
                Player.update(from: ai, in: context)
            }
            players.first!.losses += 1
            p1["losses"] = players.first!.losses
            Player.update(from: p1, in: context)
        }
    }
    
    
    
    

    func adjustGameGames(gameUpdates: inout [String:Any]) {
        game.first!.games += 1
        gameUpdates["games"] = game.first!.games
        Game.update(from: gameUpdates, in: context)
    }
    
    
    func adjustGameDraws(gameUpdates: inout [String:Any]){
        game.first!.draws += 1
        gameUpdates["draws"] = game.first!.draws
        Game.update(from: gameUpdates, in: context)
    }
    

    
    
    
    func adjustPlayerDraws(opponent: String, p1: inout [String:Any], p2: inout [String:Any], ai: inout [String:Any]){
        players.first!.draws += 1  // fix
        p1["draws"] = players.first!.draws
        Player.update(from: p1, in: context)
        if opponent == viewModel.playerNames()[1]{
            secondPlayer.first!.draws += 1
            p2["draws"] = secondPlayer.first!.draws
            Player.update(from: p2, in: context)

        }else{
            players.last!.draws += 1
            ai["draws"] = players.last!.draws
            Player.update(from: ai, in: context)
        }
    }
    
    
    
    
    func adjustPlayerMoves(turnStatus: Bool, p1: inout [String:Any], p2: inout [String:Any], ai: inout [String:Any], opponent: String){
        if turnStatus{
            players.first!.moves += 1
            p1["moves"] = players.first!.moves
            Player.update(from: p1, in: context)
        }
        else{
            if opponent == "P2"{
                secondPlayer.first!.moves += 1
                p2["moves"] = secondPlayer.first!.moves
                Player.update(from: p2, in: context)
            }
            else{
                players.last!.moves += 1
                ai["moves"] = players.last!.moves
                Player.update(from: ai, in: context)
            }
        }
    }
    
    
    
    
    
    func adjustPlayerGames(p1: inout [String:Any], p2: inout [String:Any], ai: inout [String:Any], opponent: String){
        players.first!.games += 1
        p1["games"] = players.first!.games
        Player.update(from: p1, in: context)
        if opponent == "P2"{
            secondPlayer.first!.games += 1
            p2["games"] = secondPlayer.first!.games
            Player.update(from: p2, in: context)
        }
        else{
            players.last!.games += 1
            ai["games"] = players.last!.games
            Player.update(from: ai, in: context)
        }
    }
    
    
    
    
    func adjustPlayerDraws(p1: inout [String:Any], p2: inout [String:Any], ai: inout [String:Any], opponent: String){
        players.first!.draws += 1
        p1["draws"] = players.first!.draws
        Player.update(from: p1, in: context)
        if opponent == "P2"{
            secondPlayer.first!.draws += 1
            p2["draws"] = secondPlayer.first!.draws
            Player.update(from: p2, in: context)
        }
        else{
            players.last!.draws += 1
            ai["draws"] = players.last!.draws
            Player.update(from: ai, in: context)
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
                        viewModel.didTapReset()
                    }
                Text("Back").foregroundColor(.white)
                Rectangle().opacity(0.0).frame(width:width*0.5)
            }
        }
    }
    
    
    
    
}





struct GameArea_Previews: PreviewProvider {
    static var previews: some View {
        GameArea(viewModel: ViewModel(), viewRouter: ViewRouter(), opponent: "x")
    }
}
