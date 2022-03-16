
import Foundation
import SwiftUI

class ViewModel: ObservableObject {
    
    @Published var model = Model(gameCircleColors: gameCircleColors, blankCircleColor: blankCircleColor, numGameRows: numGameRows, numGameCols: numGameCols, initCircleFilledState: initCircleFilledState, gameBoardColor: gameBoardColor, numPlayerPieces: numPlayerPieces, highlightedCol: highlightedCol)
    
    
    func getPlayerPiecesLeft(player: Int) -> Int {
        model.numPlayerPieces[player]
    }
    
    
    
    func gameBoard() -> [Model.GameRow] {
        return model.gameBoard
    }
    
    
    
    func handleGameCircleTap(row: Int, col: Int){
        let pieceColor = p1Turn ? ViewModel.gameCircleColors[0] : ViewModel.gameCircleColors[1]
        if model.roomInCol(col: col){
            if (model.highlightedCol == col){
                model.placePiece(row: model.lowestSpotToDrop(col: col), col: col, color: pieceColor)
                model.swapHighlight(from: col, to: -1) // unhilite this column and set highlightedCol to -1
                p1Turn = p1Turn ? false : true
            }
            else{
                model.swapHighlight(from: model.highlightedCol, to: col)
            }
        }
        if(model.checkForWin() || model.checkForDraw()) {
            gameInProgress = false
        }
    }
    
    
    
    //Function for AI to place piece
    func placeAIPiece(col: Int){
        let pieceColor = p1Turn ? ViewModel.gameCircleColors[0] : ViewModel.gameCircleColors[1]
        if model.roomInCol(col: col){
            model.placePiece(row: model.lowestSpotToDrop(col: col), col: col, color: pieceColor)
            p1Turn = p1Turn ? false : true
        }
        if(model.checkForWin() || model.checkForDraw()) {
            gameInProgress = false
        }
    }
    
    
    
    //Handles AI logic
    func handleAI() -> Int {
        return model.chooseBestMove(color: ViewModel.gameCircleColors[1])
    }
    
    

    func getBoardCornerRadius() -> Double {
        return boardCornerRadius
    }
    
    //added game logic functions
    func getTurnStatus() -> Bool {
        return p1Turn
    }
    
    func getGameStatus() -> Bool {
        return gameInProgress
    }
    
    func didTapCheckForWin() -> Bool{
        return model.checkForWin()
    }
    
    func getDrawStatus() -> Bool {
        return model.checkForDraw()
    }
    
    func playerNames() -> [String] {
        return ViewModel.playerNames
    }
    
    
    func didTapReset() {
        model = Model(gameCircleColors: ViewModel.gameCircleColors, blankCircleColor: ViewModel.blankCircleColor, numGameRows: ViewModel.numGameRows, numGameCols: ViewModel.numGameCols, initCircleFilledState: ViewModel.initCircleFilledState, gameBoardColor: ViewModel.gameBoardColor, numPlayerPieces: ViewModel.numPlayerPieces, highlightedCol: ViewModel.highlightedCol)
        p1Turn = true
        gameInProgress = true
    }
    
    
    func setOpponent(opponent: String){
        curOpponent = opponent == ViewModel.playerNames[1] ? (ViewModel.playerNames[1], ViewModel.aiCircleColor) : (ViewModel.playerNames[2], ViewModel.gameCircleColors[1])
    }
    
    
    func getStatsColors() -> [String] {
        return ViewModel.statsColors
    }
    


    
    var p1Turn = true
    var gameInProgress = true
    let boardCornerRadius = 5.0
    var curOpponent = ("", "")
    static let gameCircleColors = ["green", "red"]
    static let statsColors = ["green", "red", "gray", "white"]
    static let playerNames = ["P1", "P2", "AI"]
    static let blankCircleColor = "white"
    static let aiCircleColor = "gray"
    static let numGameRows = 6
    static let numGameCols = 7
    static let initCircleFilledState = false
    static let gameBoardColor = "gray"
    static let numPlayerPieces = 21
    static let highlightedCol = -1
}

