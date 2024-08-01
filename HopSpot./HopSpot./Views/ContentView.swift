//
//  ContentView.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-03.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: log_in_view_model
    var body: some View {
        
        NavigationView{
            reg_or_log()
            
        }
        
    }
} 


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
