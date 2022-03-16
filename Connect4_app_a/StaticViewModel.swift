//
//  StaticViewModel.swift
//  Connect4ProjectB
//
//  Created by Katie Trombetta on 4/30/21.
//

import Foundation
class StaticViewModel : ObservableObject {
    
    static let globalInstance = StaticViewModel()
    
    init(){}
    
    var globalViewModel = ViewModel()
}
