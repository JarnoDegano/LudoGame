import Foundation

@Observable class ViewModel: ObservableObject {
    
    private var model: Model
    
    var currentPlayer: Model.players = .yellow
    var currentRoll: Int?
    var timer: Timer?
    var redrawTrigger = false
    
    init() {
        self.model = ViewModel.createLudoGame()
    }
    
    static func createLudoGame() -> Model {
        return Model()
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(withTimeInterval:1, repeats: true) { [weak self] _ in
            self?.performNextAction()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func triggerRedraw() {
        redrawTrigger.toggle()
    }
    
    func getFieldColors() -> [Model.coloredFields: [(Int, Int)]] {
        return model.fieldColors
    }
    
    func getStartFields() -> [Model.coloredFields: [(Int, Int)]] {
        return model.playerStartPos
    }
    
    func getCurrentPlayer() -> Model.players {
        return currentPlayer
    }
    
    func getPlayerAtStartPosition(row: Int, col: Int) -> Model.players? {
        for (player, coordinates) in model.playerPos {
            if(coordinates.contains(where: {$0 == (row, col) })) {
                return player
            }
        }
        return nil
    }
    
    func getDicePosition() -> (Int, Int) {
        return model.dice
    }
    
    func getDiceNumber () -> Int {
        return model.diceNumber.rawValue
    }
    
    func rollDice(){
        currentRoll = model.rollDice()
    }
    
    func performNextAction() {
        nextPlayer()
        rollDice()
        if currentRoll == 6 {
            movePieceToField(player: currentPlayer)
        }
        else {
            movePieceOnField(player: currentPlayer)
        }
    }
    
    func nextPlayer() {
        switch currentPlayer {
        case .green:
            currentPlayer = .red
        case .red:
            currentPlayer = .blue
        case .blue:
            currentPlayer = .yellow
        case .yellow:
            currentPlayer = .green
        }
    }
    
    func movePieceToField(player: Model.players) {
        let firstField = (model.playAbleFieldsInOrder[player]?.first)!
        
        // Check if there are any players still in the start field
        guard let playerPositions = model.playerPos[player],
              let startFields = model.playerStartPos[getColorForPlayer(player)!],
              let startPosition = playerPositions.first,
              startFields.contains(where: { $0 == startPosition }) else {
            // No players in the start field, call movePieceOnField method
            movePieceOnField(player: player)
            return
        }
        
        // Check if the dice roll is a six
        if model.diceNumber == .six {
            // Move the player to the first playable field or stay in the start field
            moveFigure(player: player, from: startPosition, to: firstField)
        } else {
            movePieceOnField(player: player)
        }
    }
    
    
    func movePieceOnField(player: Model.players) {
        guard let playableFields = model.playAbleFieldsInOrder[player],
              let playerCurrentPos = model.playerPos[player] else {
            return
        }
        
        if let positionToMove = playerCurrentPos.first(where: { currentPos in
            return playableFields.contains { fieldPos in
                return fieldPos.0 == currentPos.0 && fieldPos.1 == currentPos.1
            }
        }) {
            if let currentIndex = playableFields.firstIndex(where: { $0 == positionToMove }) {
                var movesLeft = getDiceNumber()
                var currentMoveIndex = currentIndex
                
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                    let nextIndex = (currentMoveIndex + 1) % playableFields.count
                    let nextPosition = playableFields[nextIndex]
                    self.stopTimer()
                    
                    self.moveFigure(player: player, from: playableFields[currentMoveIndex], to: nextPosition)
                    
                    currentMoveIndex = nextIndex
                    movesLeft -= 1
                    
                    if movesLeft == 0 {
                        timer.invalidate()  // Stop the timer when all moves are done
                        self.startTimer()
                    }
                }
            }
        }
    }

    func moveFigure(player: Model.players, from currentPosition: (Int, Int), to newPosition: (Int, Int)) {
        guard var playerPositions = model.playerPos[player] else {
            return
        }
        
        // Check if the player has a figure at the current position
        guard let indexToRemove = playerPositions.firstIndex(where:{$0 == currentPosition}) else {
            return
        }
        
        // Remove the figure from the current position
        playerPositions.remove(at: indexToRemove)
        
        // Append the figure to the new position
        playerPositions.append(newPosition)
        
        // Update the player's positions in the model
        model.playerPos[player] = playerPositions
    }
    
    
    func getColorForPlayer(_ player: Model.players) -> Model.coloredFields? {
        switch  player {
        case .green:
            return .greenField
        case .yellow:
            return .yellowField
        case .blue:
            return .blueField
        case .red:
            return .redField
        }
    }
}
