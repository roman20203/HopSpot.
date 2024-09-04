//
//  LocationsListView.swift
//  HopSpot.
//
//  Created by mina on 2024-07-28.
//

import SwiftUI

struct LocationsListView: View {
    
    @EnvironmentObject private var vm: club_firebase_handler
    
    var body: some View {
        List {
            ForEach(vm.locations) { location in
                Button {
                    vm.showNextLocation(location: location)
                } label: {
                    listRowView(location: location)
                }
                .padding(.vertical, 4)
                .listRowBackground(Color.clear)
                    
                }
            }
        .listStyle(PlainListStyle())
        }
    }


struct LocationsListView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsListView()
            .environmentObject(club_firebase_handler())
    }
    
}

extension LocationsListView {
    private func listRowView(location: Location) -> some View  {
        HStack {
            image_view(imagePath: location.imageNames)
                .frame(width: 45, height: 45)
                .cornerRadius(10)
            
            //Instead of treating the imageNames, like a [String] type we treat it like a String type, which it now is after changes it in the Location.swift
            /*
            if let imageName = location.imageNames.first {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .cornerRadius(10)
            }
            */
            
            VStack(alignment: .leading) {
                Text(location.name)
                    .font(.headline)
                Text(location.cityName)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity,  alignment: .leading)
        }
    }
}
