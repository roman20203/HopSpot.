//
//  image_view.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-24.
//

import FirebaseStorage
import SwiftUI


// Simple image cache
class ImageCache {
    static let shared = NSCache<NSString, UIImage>()

    // Function to preload images
    func preloadImages(imagePaths: [String], completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        for path in imagePaths {
            dispatchGroup.enter()
            let storageRef = Storage.storage().reference().child(path)

            storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let data = data, let uiImage = UIImage(data: data) {
                    // Cache the image
                    ImageCache.shared.setObject(uiImage, forKey: NSString(string: path))
                } else {
                    print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
}

// Track ongoing fetches
var ongoingFetches: [String: StorageReference] = [:]

struct image_view: View {
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
        // Check the cache first
        if let cachedImage = ImageCache.shared.object(forKey: NSString(string: imagePath)) {
            self.image = Image(uiImage: cachedImage)
            isLoading = false
            return
        }

        // Check if a fetch for this image is already ongoing
        if ongoingFetches[imagePath] != nil {
            // Already fetching this URL, return early
            return
        }

        let storage = Storage.storage()
        let storageRef = storage.reference().child(imagePath)

        // Store the ongoing fetch
        ongoingFetches[imagePath] = storageRef

        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            DispatchQueue.main.async { // Ensure UI updates are on the main thread
                // Remove the ongoing fetch reference
                ongoingFetches[imagePath] = nil
                
                if let error = error {
                    print("Error loading image: \(error)")
                    isLoading = false
                    return
                }

                if let data = data, let uiImage = UIImage(data: data) {
                    // Cache the image
                    ImageCache.shared.setObject(uiImage, forKey: NSString(string: imagePath))
                    self.image = Image(uiImage: uiImage)
                }

                isLoading = false
            }
        }
    }
}

/*
import FirebaseStorage
import SwiftUI

// Simple image cache
class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
}

struct image_view: View {
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
        // Check the cache first
        if let cachedImage = ImageCache.shared.object(forKey: NSString(string: imagePath)) {
            self.image = Image(uiImage: cachedImage)
            isLoading = false
            return
        }

        let storage = Storage.storage()
        let storageRef = storage.reference().child(imagePath)

        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error loading image: \(error)")
                isLoading = false
                return
            }

            if let data = data, let uiImage = UIImage(data: data) {
                // Cache the image
                ImageCache.shared.setObject(uiImage, forKey: NSString(string: imagePath))
                self.image = Image(uiImage: uiImage)
            }

            isLoading = false
        }
    }
}





import FirebaseStorage
import SwiftUI

struct image_view: View {
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
*/
