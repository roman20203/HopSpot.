import UIKit
import FirebaseFirestore
import FirebaseStorage

final class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    var user: User?
    var onSave: ((User) -> Void)?
    private var isSaving = false
    private var isChangingBackgroundImage = false

    // UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let profileImageView: UIImageView = createImageView(radius: 50, image: "person.circle")
    private let backgroundImageView: UIImageView = createImageView()
    private let addImageOverlay: UILabel = createLabel(text: "+", fontSize: 36, bgColor: UIColor.black.withAlphaComponent(0.5))
    private let changeBackgroundButton: UIButton = createButton(title: "Change Background Image", action: #selector(didTapChangeBackgroundPicture))
    private let snapchatTextField: UITextField = createTextField(placeholder: "Snapchat Username")
    private let instagramTextField: UITextField = createTextField(placeholder: "Instagram Username")
    private let schoolTextField: UITextField = createTextField(placeholder: "School")
    private let saveButton: UIButton = createButton(title: "Save", color: UIColor(red: 1.0, green: 0.0, blue: 0.54, alpha: 1.0), action: #selector(didTapSave))
    private let loadingIndicator: UIActivityIndicatorView = createActivityIndicator()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupScrollView()
        setupUIComponents()
        setupConstraints()
        loadUserData()
        addKeyboardObservers()
        setupProfileImageTap() // Enable profile image tap
        setTextFieldDelegates() // Set UITextField delegates to handle return key
        // Add default navigation back button
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(didTapBack))
        
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
    }
    
    private func setupUIComponents() {
        let profileStackView = UIStackView(arrangedSubviews: [profileImageView, addImageOverlay])
        profileStackView.axis = .vertical
        profileStackView.alignment = .center
        profileStackView.spacing = 8
        
        [profileStackView, backgroundImageView, changeBackgroundButton, snapchatTextField, instagramTextField, schoolTextField, saveButton, loadingIndicator]
            .forEach { contentStackView.addArrangedSubview($0) }
        
        loadingIndicator.hidesWhenStopped = true
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // Ensure proper scrolling
        ])
        
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        addImageOverlay.widthAnchor.constraint(equalToConstant: 50).isActive = true
        addImageOverlay.heightAnchor.constraint(equalToConstant: 50).isActive = true

        backgroundImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    private func setupProfileImageTap() {
        let profileTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePicture))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(profileTapGesture)
    }

    private func setTextFieldDelegates() {
        snapchatTextField.delegate = self
        instagramTextField.delegate = self
        schoolTextField.delegate = self
    }

    private func loadUserData() {
        snapchatTextField.text = user?.snapchatUsername
        instagramTextField.text = user?.instagramUsername
        schoolTextField.text = user?.school
        loadImage(from: user?.profileImageUrl, into: profileImageView)
        loadImage(from: user?.backgroundImageUrl, into: backgroundImageView)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func didTapBack() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapSave() {
        guard var user = user, !isSaving else { return }

        isSaving = true
        toggleSaveButton(false)
        user.snapchatUsername = snapchatTextField.text
        user.instagramUsername = instagramTextField.text
        user.school = schoolTextField.text

        Firestore.firestore().collection("users").document(user.id).updateData([
            "snapchatUsername": user.snapchatUsername ?? "",
            "instagramUsername": user.instagramUsername ?? "",
            "school": user.school ?? "",
            "profileImageUrl": user.profileImageUrl ?? "",
            "backgroundImageUrl": user.backgroundImageUrl ?? ""
        ]) { [weak self] error in
            self?.toggleSaveButton(true)
            if let error = error { print("Error updating document: \(error)") }
            else { self?.onSave?(user); self?.dismiss(animated: true, completion: nil) }
        }
    }

    @objc private func didTapChangeProfilePicture() {
        showImagePicker(isChangingBackground: false)
    }

    @objc private func didTapChangeBackgroundPicture() {
        showImagePicker(isChangingBackground: true)
    }

    private func showImagePicker(isChangingBackground: Bool) {
        isChangingBackgroundImage = isChangingBackground
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    // Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        // Fetch the edited image
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        
        // Determine whether it's the background or profile image being changed
        if isChangingBackgroundImage {
            backgroundImageView.image = selectedImage
            uploadImageToStorage(image: selectedImage, isBackground: true)
        } else {
            profileImageView.image = selectedImage
            addImageOverlay.isHidden = true
            uploadImageToStorage(image: selectedImage, isBackground: false)
        }
    }
    // Upload image to Firebase Storage
    private func uploadImageToStorage(image: UIImage, isBackground: Bool) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        let storageRef = Storage.storage().reference().child(isBackground ? "background_images" : "profile_images").child("\(user?.id ?? UUID().uuidString).jpg")
        
        // Upload the image data
        storageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                return
            }
            
            // After successful upload, get the download URL
            storageRef.downloadURL { [weak self] url, error in
                guard let self = self, let url = url else {
                    print("Failed to get download URL: \(error?.localizedDescription ?? "No error description")")
                    return
                }
                
                // Add a cache-busting query parameter to ensure the new image loads and bypasses cache
                let cacheBustingURL = url.absoluteString + "?timestamp=\(Date().timeIntervalSince1970)"
                
                // Save the new image URL to Firestore
                self.saveImageUrlToFirestore(url: cacheBustingURL, isBackground: isBackground)
                
                // Update the UI on the main thread with the newly uploaded image
                DispatchQueue.main.async {
                    if isBackground {
                        self.user?.backgroundImageUrl = cacheBustingURL
                        self.backgroundImageView.image = image
                    } else {
                        self.user?.profileImageUrl = cacheBustingURL
                        self.profileImageView.image = image
                    }
                }
            }
        }
    }

    private func saveImageUrlToFirestore(url: String, isBackground: Bool) {
        Firestore.firestore().collection("users").document(user?.id ?? "").updateData([
            isBackground ? "backgroundImageUrl" : "profileImageUrl": url
        ]) { error in
            if let error = error {
                print("Error updating image URL: \(error)")
            }
        }
    }
    // Load image from URL with cache busting
    private func loadImage(from urlString: String?, into imageView: UIImageView) {
        guard let urlString = urlString, let url = URL(string: "\(urlString)?timestamp=\(Date().timeIntervalSince1970)") else { return }  // Cache busting
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            } else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }

    private func toggleSaveButton(_ enabled: Bool) {
        isSaving = !enabled
        saveButton.isEnabled = enabled
        enabled ? loadingIndicator.stopAnimating() : loadingIndicator.startAnimating()
    }

    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let bottomInset = keyboardFrame.height
            scrollView.contentInset.bottom = bottomInset
            
            if #available(iOS 13.0, *) {
                scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
            } else {
                scrollView.scrollIndicatorInsets.bottom = bottomInset
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        
        if #available(iOS 13.0, *) {
            scrollView.verticalScrollIndicatorInsets.bottom = 0
        } else {
            scrollView.scrollIndicatorInsets.bottom = 0
        }
    }

    // Handle return key to dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss keyboard when return is pressed
        return true
    }
}

// Helper functions for UI elements
private func createImageView(radius: CGFloat = 0, image: String? = nil) -> UIImageView {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    if radius > 0 {
        imageView.layer.cornerRadius = radius
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
    }
    if let imageName = image {
        imageView.image = UIImage(systemName: imageName)
    }
    imageView.isUserInteractionEnabled = true
    return imageView
}

private func createLabel(text: String, fontSize: CGFloat, bgColor: UIColor) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = UIFont.systemFont(ofSize: fontSize)
    label.textColor = .white
    label.textAlignment = .center
    label.backgroundColor = bgColor
    label.layer.cornerRadius = 25
    label.clipsToBounds = true
    return label
}

private func createButton(title: String, color: UIColor = .systemBlue, action: Selector) -> UIButton {
    let button = UIButton(type: .system)
    button.setTitle(title, for: .normal)
    button.backgroundColor = color
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 5
    button.addTarget(nil, action: action, for: .touchUpInside)
    return button
}

private func createTextField(placeholder: String) -> UITextField {
    let textField = UITextField()
    textField.placeholder = placeholder
    textField.borderStyle = .roundedRect
    return textField
}

private func createActivityIndicator() -> UIActivityIndicatorView {
    let indicator = UIActivityIndicatorView(style: .large)
    indicator.hidesWhenStopped = true
    return indicator
}


