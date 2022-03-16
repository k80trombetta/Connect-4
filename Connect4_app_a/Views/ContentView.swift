
import SwiftUI

struct ImageView: View {
    var body: some View {
        VStack {
            Image("fall-leaves")
                .resizable()
                .scaledToFit()
            Spacer()
        }
    }
}

struct ContentView: View {
    //var viewModel = StaticViewModel.globalInstance.globalViewModel
    @StateObject var viewRouter = ViewRouter()

    var body: some View {
        MotherView(viewRouter: viewRouter)
        ///return MainMenu(viewModel: viewModel)
            ///.navigationBarHidden(true)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
