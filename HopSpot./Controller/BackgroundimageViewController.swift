import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

struct BackgroundImageViewController: View {
    @EnvironmentObject var viewModel: log_in_view_model
    @State private var isUploading = false
    @State private var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode // To dismiss the view

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack {
                // Display selected image or a placeholder
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: 203)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: UIScreen.main.bounds.width, height: 203)
                        .overlay(
                            Text("Select an image from your library")
                                .foregroundStyle(.white)
                                .font(.headline)
                        )
                        .onTapGesture {
                            showImagePicker()
                        }
                }

                if isUploading {
                    ProgressView("Uploading...") // Progress indicator during upload
                        .padding()
                }

                Spacer() // Push content to the top of the screen
            }
        }
        // Sheet for image picker
        .sheet(isPresented: .constant(selectedImage == nil)) {
            ImagePicker(sourceType: .photoLibrary) { image in
                self.selectedImage = image
                uploadBackgroundImageToStorage(image: image)
            }
        }
    }

    // Function to trigger image picker
    private func showImagePicker() {
        selectedImage = nil // Reset the selected image to trigger the image picker
    }

    // Upload image to Firebase Storage
    private func uploadBackgroundImageToStorage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.75), let userId = viewModel.currentUser?.id else { return }
        isUploading = true

        let storageRef = Storage.storage().reference().child("background_images/\(userId).jpg")

        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Failed to upload image: \(error)")
                isUploading = false
                return
            }

            // Fetch download URL after upload
            storageRef.downloadURL { url, error in
                isUploading = false
                if let error = error {
                    print("Failed to get download URL: \(error)")
                    return
                }

                guard let downloadURL = url?.absoluteString else { return }
                saveBackgroundImageUrlToFirestore(url: downloadURL)
            }
        }
    }

    // Save the image URL to Firestore
    private func saveBackgroundImageUrlToFirestore(url: String) {
        guard let userId = viewModel.currentUser?.id else { return }
        let db = Firestore.firestore()

        db.collection("users").document(userId).updateData([
            "backgroundImageUrl": url
        ]) { error in
            if let error = error {
                print("Error saving background image URL: \(error)")
            } else {
                print("Background image URL successfully saved")
                viewModel.currentUser?.backgroundImageUrl = url
                presentationMode.wrappedValue.dismiss() // Dismiss the view after saving
            }
        }
    }
}

// UIKit Image Picker integration with SwiftUI
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var completion: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Coordinator to handle the delegate methods
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.completion(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

