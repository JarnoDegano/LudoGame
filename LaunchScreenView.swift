//
//  LaunchScreenView.swift
//  LudoGame
//
//  Created by Jarno Degano on 16.11.23.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.4
    
    let game = ViewModel()
    
    
    
    var body: some View {
        if isActive {
            LudoGameView(viewModel: game)
        } else {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                VStack {
                    VStack {
                        Image("AppIcon256")
                        Text("Ludo Game by Jarno Degano")
                            .font(.system(size: 40).bold())
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 2.5)) {
                            self.size = 1
                            self.opacity = 1
                        }
                    }
                }
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
