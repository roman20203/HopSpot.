//
//  image_view.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-24.
//

import FirebaseStorage
import SwiftUI

struct FirebaseImageView: View {
    @State private var image: Image? = nil
    @State private var isLoading: Bool = true

    let imagePath: String

    var body: some View {
        ZStack {
            if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                ProgressView()
            } else {
                Color.gray // Placeholder if image loading fails
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        let storage = Storage.storage()
        let storageRef = storage.reference().child(imagePath)

        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error loading image: \(error)")
                isLoading = false
                return
            }

            if let data = data, let uiImage = UIImage(data: data) {
                self.image = Image(uiImage: uiImage)
            }

            isLoading = false
        }
    }
}
