
import SwiftUI

struct GameboardRow<Item, ItemView>: View where Item: Identifiable, ItemView: View{

    let items: [Item]
    let viewForItem: (Item) -> ItemView
    
    init(items: [Item], content: @escaping (Item) -> ItemView) {
        self.items = items
        viewForItem = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            body(items: items, size: geometry.size)
        }
    }
    
    func body(items: [Item], size: CGSize) -> some View {
        let width = size.width
        
        return
            VStack{
                ForEach(items) { item in
                    viewForItem(item)
                }
            }.padding()
    }
}
