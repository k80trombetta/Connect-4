
import Foundation

struct Model {
    var gameBoard: [GameRow] = []                                   // Game Board Circles
    var gameCircleColors: [String] = []                             // 2 colors, 1 for P1, the other for P2 or AI
    var numGameRows: Int                                            // Num rows in game board
    var numGameCols: Int                                            // Num cols in game board
    var gameBoardColor: String                                      // Black for now
    var numPlayerPieces: [Int] = []
    var highlightedCol: Int
    
    
    // Initializes the gameBoard with an array of 6 Game Rows, each that contains 7 GameCircles. The GameCircles are initialized to "white"
    init(gameCircleColors: [String], blankCircleColor: String, numGameRows: Int, numGameCols: Int, initCircleFilledState: Bool, gameBoardColor: String, numPlayerPieces: Int, highlightedCol: Int){
        self.numGameRows = numGameRows
        self.numGameCols = numGameCols
        self.gameBoardColor = gameBoardColor
        self.numPlayerPieces.append(numPlayerPieces)                // Each player starts with 21 pieces
        self.numPlayerPieces.append(numPlayerPieces)
        self.highlightedCol = highlightedCol
        
        
        for color in 0..<gameCircleColors.count{                     // Create local variable to hold the 2 colors of game pieces
            self.gameCircleColors.append(gameCircleColors[color])
        }
        
        
        for r in 0..<numGameRows{
            var newGameRow = GameRow(id:r, gameRowCircles: [])
            for c in 0..<numGameCols{
                newGameRow.gameRowCircles.append(GameCircle(id: r*7+c, pos: (r,c), color: blankCircleColor, filled: initCircleFilledState, highlighted: initCircleFilledState))
            }
            gameBoard.append(newGameRow)
        }
    }
    
    
    
    // Tells us if the user selected a column that has room to drop a piece in or if it is full
    mutating func roomInCol(col: Int) -> Bool{
        if col >= 0{
            return !gameBoard[0].gameRowCircles[col].filled
        }
        return false
    }
    
    
    
    // Tells us the lowest row idx in the given column that a piece can be dropped in
    mutating func lowestSpotToDrop(col: Int) -> Int{
        if (roomInCol(col: col)){
            var r = 0
            while r < numGameRows && !gameBoard[r].gameRowCircles[col].filled{
                r += 1
            }
            return r-1;
        }
        return -1
    }
    
    
    
    // Updates the given GameCircle to reflect it has been placed. The corresponding circle color is changed to the current player's color
    // from blank/"white" color and the "filled" variable is changed to true to reflect this circle has a piece in it.
    mutating func placePiece(row: Int, col: Int, color: String){
        gameBoard[row].gameRowCircles[col].color = color
        gameBoard[row].gameRowCircles[col].filled = true
        gameBoard[row].gameRowCircles[col].highlighted = false
        numPlayerPieces[color == gameCircleColors[0] ? 0 : 1] -= 1 // decrement num pieces available to cur player
    }
    
    
    
    //Added functions for game logic
    
    //Takes 4 GameCircle objects and checks if they are all the same color to check for a win
    func checkColorPieces(one: GameCircle, two: GameCircle, three: GameCircle, four: GameCircle) -> Bool {
        if(one.filled && two.filled && three.filled && four.filled) {
            if(one.color == two.color && two.color == three.color && three.color == four.color) {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    
    
    //Checks for a win in every row going from top to bottom and left to right
    func checkHorizontal() -> Bool {
        for row in 0..<numGameRows {
            //Stops at column 4 to not go out of range
            for column in 0..<4 {
                if checkColorPieces(one: gameBoard[row].gameRowCircles[column], two: gameBoard[row].gameRowCircles[column+1], three: gameBoard[row].gameRowCircles[column+2], four: gameBoard[row].gameRowCircles[column+3]) {
                    return true
                }
            }
        }
        return false
    }
    
    
    
    //Checks for a win in every column going from left to right and top to bottom
    func checkVertical() -> Bool {
        for column in 0..<numGameCols {
            //Stops at row 3 to not go out of range
            for row in 0..<3 {
                if checkColorPieces(one: gameBoard[row].gameRowCircles[column], two: gameBoard[row+1].gameRowCircles[column],  three: gameBoard[row+2].gameRowCircles[column],  four: gameBoard[row+3].gameRowCircles[column]) {
                    return true
                }
            }
        }
        return false
    }
    
    
    
    //Checks for wins in positive diagonal slopes
    func checkPosDiagonal() -> Bool {
        for row in 3..<numGameRows {
            for column in 0..<4 {
                if checkColorPieces(one: gameBoard[row].gameRowCircles[column], two: gameBoard[row-1].gameRowCircles[column+1], three: gameBoard[row-2].gameRowCircles[column+2], four: gameBoard[row-3].gameRowCircles[column+3]) {
                    return true
                }
            }
        }
        return false
    }
    
    
    
    //Checks for wins in negative diagonal slopes
    func checkNegDiagonal() -> Bool {
        for row in 0..<3 {
            for column in 0..<4 {
                if checkColorPieces(one: gameBoard[row].gameRowCircles[column], two: gameBoard[row+1].gameRowCircles[column+1], three: gameBoard[row+2].gameRowCircles[column+2], four: gameBoard[row+3].gameRowCircles[column+3]) {
                    return true
                }
            }
        }
        return false
    }
    
    
    
    //Checks for a win by examining the board horizontally, vertically, and diagonally
    
    func checkForWin() -> Bool {
        return (checkHorizontal() || checkVertical() || checkPosDiagonal() || checkNegDiagonal())
    }
    
    
    
    //Checks for a draw by scanning the entire board and checking if it's all filled
    func checkForDraw() -> Bool {
        for row in 0..<numGameRows {
            for column in 0..<numGameCols {
                if !gameBoard[row].gameRowCircles[column].filled {
                    return false
                }
            }
        }
        return true
    }
    
    
    
    mutating func swapHighlight(from: Int, to: Int) {
        // unhighlighting
        var spot = lowestSpotToDrop(col: from)
        if from >= 0 && spot >= 0{                                               //unhighlighting
            for rowIdx in 0...lowestSpotToDrop(col: from){
                gameBoard[rowIdx].gameRowCircles[from].highlighted = false
            }
        }
        spot = lowestSpotToDrop(col: to)                                        //rehighlighting
        if to >= 0 && spot >= 0{
            for rowIdx in 0...lowestSpotToDrop(col: to) {
                gameBoard[rowIdx].gameRowCircles[to].highlighted = true
            }
        }
        highlightedCol = to
    }
    
    
    
    //Functions for AI
    
    //This function returns a tuple where the first element is the number of AI pieces and the second element is the number of empty circles in a selected area
    func countPieces(area: [GameCircle], color: String) -> (Int, Int) {
        var count: (Int, Int) = (0, 0)
        
        //Count the amount of AI pieces and empty spots
        for circle in 0..<area.count {
            if(area[circle].color == color) {
                count.0 += 1
            } else if(!area[circle].filled) {
                count.1 += 1
            }
        }
        return count
    }
    
    
    
    //Scores a board state and determines where the AI places the next piece
    func scoreBoardState(board: [GameRow], color: String) -> Int {
        var score: Int = 0
        
        //Score horizontal positions
        for row in 0..<numGameRows{
            for column in 0..<numGameCols - 3{
                var horizArea: [GameCircle] = []
                
                //Append proper game circles to area
                for idx in 0..<4{
                    horizArea.append(board[row].gameRowCircles[column+idx])
                }
                
                score += scoreArea(area: horizArea, color: color)
                horizArea = []
            }
        }
        
        //Score vertical positions
        for column in 0..<numGameCols{
            for row in 0..<numGameRows-3{
                var vertArea: [GameCircle] = []
                
                for idx in 0..<4{
                    vertArea.append(board[row+idx].gameRowCircles[column])
                }
                
                score += scoreArea(area: vertArea, color: color)
                vertArea = []
            }
        }
        
        //Score positively sloped diagonals
        for row in 3..<numGameRows {
            for column in 0..<4 {
                var posDiagArea: [GameCircle] = []
                
                for idx in 0..<4{
                    posDiagArea.append(board[row-idx].gameRowCircles[column+idx])
                }
                
                score += scoreArea(area: posDiagArea, color: color)
                posDiagArea = []
            }
        }
        
        //Score negatively sloped diagonals
        for row in 0..<3 {
            for column in 0..<4 {
                var negDiagArea: [GameCircle] = []
                
                for idx in 0..<4{
                    negDiagArea.append(board[row+idx].gameRowCircles[column+idx])
                }
                
                score += scoreArea(area: negDiagArea, color: color)
                negDiagArea = []
            }
        }
        
        return score
    }
    
    
    
    //Takes an area of 4 game circles and gives a score based on the positioning of AI pieces
    func scoreArea(area: [GameCircle], color: String) -> Int {
        var score: Int = 0
        
        //Four in a row
        if(countPieces(area: area, color: color).0 == 4) {
            score += 20
        } //There are 3 pieces and 1 empty spot
        else if(countPieces(area: area, color: color).0 == 3 && countPieces(area: area, color: color).1 == 1) {
            score += 10
        } //There are 2 pieces and 2 empty spots
        else if(countPieces(area: area, color: color).0 == 2 && countPieces(area: area, color: color).1 == 2) {
            score += 5
        } //Subtracts points if player 1 is about to win to encourage playing defensively
        else if(countPieces(area: area, color: "green").0 == 3 && countPieces(area: area, color: "green").1 == 1) {
            score -= 20
        }
        
        return score
    }
    
    
    
    //Chooses the best move for the AI to make
    mutating func chooseBestMove(color: String) -> Int{
        var highScore: Int = 0
        var bestMove: Int = Int.random(in: 0..<7)
        
        for column in 0..<numGameCols {
            if(roomInCol(col: column)) {
                let rowIdx: Int = lowestSpotToDrop(col: column)
                
                //The AI simulates placing a piece in each column and determines which is the next best move to make based on a score of each simulated board state
                let tempBoard: [GameRow] = gameBoard
                let simBoard: [GameRow] = simPlacePiece(board: tempBoard, row: rowIdx, col: column, color: color)
                let score: Int = scoreBoardState(board: simBoard, color: color)
                
                if score > highScore {
                    highScore = score
                    bestMove = column
                }
                
            }
        }
        return bestMove
    }
    
    
    
    //This function is for the AI simulating placing a piece and returns a board state
    mutating func simPlacePiece(board: [GameRow], row: Int, col: Int, color: String) -> [GameRow]{
        var board: [GameRow] = board
        board[row].gameRowCircles[col].color = color
        board[row].gameRowCircles[col].filled = true
        board[row].gameRowCircles[col].highlighted = false
        
        return board
    }


    
    

    // There will be 6 of these in the gameBoard[]
    struct GameRow: Identifiable {
        var id: Int
        var gameRowCircles: [GameCircle]
    }
    
    
    
    // There will be 7 of these in each gameBoard[GameRow]
    struct GameCircle: Identifiable {
        var id: Int
        var pos: (Int,Int)
        var color: String
        var filled: Bool
        var highlighted: Bool
    }
}
