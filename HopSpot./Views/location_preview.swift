//
//  location_preview.swift
//  HopSpot.
//
//  Created by mina on 2024-07-29.
//

import SwiftUI

struct location_preview: View {
    
    @EnvironmentObject private var vm: club_firebase_handler
    let location: Location
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                imageSection
                titleSection
            }
            
            VStack (spacing: 8){
                learnMoreButton
                nextButton
                
                
            }
            
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
        .offset(y: 65)
    )
        .cornerRadius(10)
    }
}
    


struct LocationPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.green.ignoresSafeArea()
            location_preview(location: LocationsDataService.locations.first!)
                .padding()
        }
        .environmentObject(club_firebase_handler())
    }
}

extension location_preview {
    private var imageSection: some View {
            ZStack {
                image_view(imagePath: location.imageNames)
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                
                //Instead of treating the imageNames, like a [String] type we treat it like a String type, which it now is after changes it in the Location.swift
                /*
                if let imageNames = location.imageNames.first {
                    Image(imageNames)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                }
                 */
            }
            .padding(6)
            .background(Color.white)
            .cornerRadius(10)
        }
        private var titleSection: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(location.cityName)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
    
    private var learnMoreButton: some View {
        Button {
            vm.sheetLocation = location
        } label: {
            Text("learn More")
                .font(.headline)
                .frame(width: 125, height: 35)
        }
        .buttonStyle(.bordered)
        .foregroundColor(.white)
        .background(Color.red)
        .cornerRadius(10)
    }
    
    private var nextButton: some View {
        Button {
            vm.nextButtonPressed()
        } label: {
            Text("Next")
                .font(.headline)
                .frame(width: 125, height: 35)
        }
        .buttonStyle(.bordered)
        .foregroundColor(.red)
        .background(Color.clear)
        .cornerRadius(10)
    }
}
