//
//  home_view.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-10.
//

import SwiftUI

struct test_view: View {
    @StateObject private var clubHandler = club_firebase_handler()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    if clubHandler.clubs.isEmpty {
                        Text("No clubs available")
                            .padding()
                    } else {
                        ForEach(clubHandler.clubs) { club in
                            club_view_template(club: club)
                        }
                    }
                }
            }
            .navigationTitle("Test")
            .onAppear {
                clubHandler.fetchClubs()
            }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        test_view()
    }
}
