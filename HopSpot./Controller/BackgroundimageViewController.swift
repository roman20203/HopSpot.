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
                                .foregroundColor(.white)
                                .font(.headline)
                        )
                        .onTapGesture {
                            showImagePicker()
                        }
                }

                if isUploading {
                    ProgressView("Uploading...")
                        .padding()
                }

                Spacer()
            }
        }
        .sheet(isPresented: .constant(selectedImage == nil)) {
            ImagePicker(sourceType: .photoLibrary) { image in
                self.selectedImage = image
                uploadBackgroundImageToStorage(image: image)
            }
        }
    }

    private func showImagePicker() {
        // Present the image picker
        selectedImage = nil // Reset selected image
    }

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
                presentationMode.wrappedValue.dismiss() // Dismiss after saving
            }
        }
    }
}

// Image Picker using UIKit
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

