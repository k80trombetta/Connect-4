//
//  SwiftUIView.swift
//  Connect4ProjectB
//
//  Created by Samantha Mazo on 4/28/21.
//

import SwiftUI

struct BackgroundImage: View {
    var body: some View {
        VStack{
            GeometryReader { geo in
                Image("Connect4_50")
                    .resizable()
                    .frame(width: geo.size.width, height: geo.size.height)
            
                
            }
        }
        
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundImage()
    }
}
