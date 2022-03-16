
import SwiftUI

struct OpponentSelection: View {
    
    @StateObject var viewRouter: ViewRouter
    var viewModel: ViewModel

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
                VStack{
                    backButtonRow(width: width, height: height)
                        .frame(height: height*0.035).padding()
                    Text("Choose Opponent").font(.largeTitle).padding().foregroundColor(.white)
                    Circle()
                        .strokeBorder(Color.black, lineWidth: 5.0).opacity(0.3)
                        .background(Circle().fill(Color.green))
                        .frame(width: width * 0.45)
                        .overlay(Text("Pass & Play").foregroundColor(.white).font(.title2))
                        .onTapGesture {
                            viewRouter.currentPage = .gameP2
                        }
                    Circle()
                        .strokeBorder(Color.black, lineWidth: 5.0).opacity(0.3)
                        .background(Circle().fill(Color.red))
                        .frame(width: width * 0.45)
                        .overlay(Text(viewModel.playerNames()[2]).foregroundColor(.white).font(.title2))
                        .onTapGesture {
                            viewRouter.currentPage = .gameAI
                        }
                    Rectangle().opacity(0.0).frame(height:height*0.1)
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
                        viewRouter.currentPage = .mainMenu
                    }
                Text("Back").foregroundColor(.white)
                Rectangle().opacity(0.0).frame(width:width*0.5)
            }
        }
    }
}



struct OpponentSelection_Previews: PreviewProvider {
    static var previews: some View {
        OpponentSelection(viewRouter: ViewRouter(), viewModel: ViewModel())
    }
}
