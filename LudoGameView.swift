import SwiftUI

struct LudoGameView: View {
    
    @ObservedObject var viewModel: ViewModel
    let gridSize = 11
    @State private var circleSize: CGFloat = 0
    @State private var redrawTrigger: Bool = false
    let boardPadding: CGFloat = 20 // Adjust as needed
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            Grid {
                ForEach(0..<11) {row in
                    GridRow {
                        ForEach(0..<11) {col in
                            ZStack {
                                Circle().foregroundColor(colorForStartPos(row, col))
                                Circle().foregroundStyle(colorForCoordinate(row, col))
                                    .overlay(
                                        colorForCoordinate(row, col) != .clear ?
                                        Circle().stroke(Color.white, lineWidth: UIScreen.main.bounds.width / CGFloat(gridSize) / 15) : nil)
                                    .overlay(
                                        colorForStartPos(row, col) != .clear ?
                                        Circle().stroke(Color.white, lineWidth: UIScreen.main.bounds.width / CGFloat(gridSize) / 15) : nil)
                                drawPlayers(row: row, col: col)
                                drawDice(row: row, col: col)
                            }
                        }
                    }
                    
                }
            }.padding(UIScreen.main.bounds.width / CGFloat(gridSize) / 2.5)
            .overlay {
                RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: UIScreen.main.bounds.width / CGFloat(gridSize) / 5)
            }
            .padding(boardPadding)
            .background(Color.black)
            .onAppear{
                viewModel.startTimer()
            }
            .onDisappear{
                viewModel.stopTimer()
            }
        }}
    
    private func colorForCoordinate(_ row: Int, _ col: Int) -> Color {
        for (player, coordinate) in viewModel.getFieldColors() {
            if coordinate.contains(where: {$0 == (row,col) }) {
                switch player {
                case .greenField:
                    return .green
                case .yellowField:
                    return .yellow
                case .blueField:
                    return .blue
                case .redField:
                    return .red
                case .whiteField:
                    return .white
                }
            }
        }
        return .clear
    }
    
    private func colorForStartPos(_ row: Int, _ col: Int) -> Color {
        for (player, coordinate) in viewModel.getStartFields() {
            if coordinate.contains(where: {$0 == (row,col) }) {
                switch player {
                case .greenField:
                    return .green
                case .yellowField:
                    return .yellow
                case .blueField:
                    return .blue
                case .redField:
                    return .red
                case .whiteField:
                    return .white
                }
            }
        }
        return .clear
    }
    
    private func drawPlayers(row: Int, col: Int) -> some View {
        Group {
            if let player = viewModel.getPlayerAtStartPosition(row: row, col: col) {
                Circle()
                    .foregroundColor(colorForPlayer(player))
                    .frame(width: UIScreen.main.bounds.width / CGFloat(gridSize) / 2.5, height: UIScreen.main.bounds.width / CGFloat(gridSize) / 2.5)
                    .overlay {
                        Circle().stroke(Color.black, lineWidth: UIScreen.main.bounds.width / CGFloat(gridSize) / 15)
                    }
            } else {
                EmptyView()
            }
        }
    }
    
    private func colorForPlayer(_ player: Model.players) -> Color {
        switch player {
        case .green:
            return .green
        case .yellow:
            return .yellow
        case .blue:
            return .blue
        case .red:
            return .red
        }
    }
    
    private func drawDice(row: Int, col: Int) -> some View {
        let dicePos = viewModel.getDicePosition()
        return Group {
            if dicePos == (row, col) {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(.black)
                    .frame(width: UIScreen.main.bounds.width / CGFloat(gridSize) / 1.5, height: UIScreen.main.bounds.width / CGFloat(gridSize) / 1.5)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5).stroke(colorForPlayer(viewModel.getCurrentPlayer()), lineWidth: UIScreen.main.bounds.width / CGFloat(gridSize) / 13)
                            .frame(width: UIScreen.main.bounds.width / CGFloat(gridSize) / 1.4, height: UIScreen.main.bounds.width / CGFloat(gridSize) / 1.4)
                        
                        let diceNumber = viewModel.getDiceNumber()
                        drawDiceCircles(number: diceNumber).padding(UIScreen.main.bounds.width / CGFloat(gridSize) / 30)
                        
                    }
            }
            else  {
                EmptyView()
            }
        }
    }
    
    private func drawDiceCircles(number: Int) -> some View {
        let spacing: CGFloat = 5
        
        let diceCircle = Circle().foregroundColor(.white).frame(width: UIScreen.main.bounds.width / CGFloat(gridSize) / 9, height: UIScreen.main.bounds.width / CGFloat(gridSize) / 9)
            .offset(x: 0, y: 0)
        
        
        return Group {
            if [1, 3, 5].contains(number) {
                Spacer()
                diceCircle
                Spacer()
            }
            if [2, 3, 4, 5 , 6].contains(number) {
                VStack {
                    HStack {
                        diceCircle
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        diceCircle
                    }
                }
            }
            if [4, 5, 6].contains(number) {
                VStack {
                    HStack {
                        Spacer()
                        diceCircle
                    }
                    Spacer()
                    HStack {
                        diceCircle
                        Spacer()
                    }
                }
            }
            if number == 6 {
                HStack {
                    diceCircle
                    Spacer()
                    diceCircle
                }
            }
        }
        .padding(spacing)
    }
    
    
    
}


#Preview {
    let game = ViewModel()
    return LudoGameView(viewModel: game)
}
