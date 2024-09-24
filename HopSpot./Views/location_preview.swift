//
//  location_preview.swift
//  HopSpot.
//
//  Created by mina on 2024-07-29.
//

import SwiftUI

struct location_preview: View {
    
    @EnvironmentObject private var vm: club_firebase_handler
    let location: Club
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                imageSection
                titleSection
            }
            
            VStack (spacing: 8){
                learnMoreButton
                //nextButton
                
                
            }
            
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
        .offset(y: 65)
    )
        .cornerRadius(10)
    }

    private var imageSection: some View {
            ZStack {
                image_view(imagePath: location.imageURL)
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
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
                Text(location.city)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
    
    private var learnMoreButton: some View {
        Button {
            DispatchQueue.main.async {
                vm.sheetLocation = location
            }
        } label: {
            Text("Learn More")
                .font(.headline)
                .frame(width: 125, height: 50)
        }
        .buttonStyle(.bordered)
        .foregroundColor(.white)
        .background(AppColor.color)
        .cornerRadius(10)
        .padding(.bottom, 15)
    }

    /*
    private var nextButton: some View {
        Button {
            DispatchQueue.main.async {
                vm.nextButtonPressed()
            }
        } label: {
            Text("Next")
                .font(.headline)
                .frame(width: 125, height: 35)
        }
        .buttonStyle(.bordered)
        .foregroundColor(AppColor.color)
        .background(Color.clear)
        .cornerRadius(10)
    }
     */

}
