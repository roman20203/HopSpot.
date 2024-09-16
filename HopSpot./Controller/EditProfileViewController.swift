import UIKit
import FirebaseFirestore
import FirebaseStorage

final class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var user: User?
    var onSave: ((User) -> Void)?
    private var isSaving = false
    private var isChangingBackgroundImage = false

    // UI Elements
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: "person.circle")
        return imageView
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    private let addImageOverlay: UILabel = {
        let label = UILabel()
        label.text = "+"
        label.font = UIFont.systemFont(ofSize: 36)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.layer.cornerRadius = 25
        label.clipsToBounds = true
        return label
    }()
    
    private let changeBackgroundButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Background Image", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(didTapChangeBackgroundPicture), for: .touchUpInside)
        return button
    }()
    
    private let snapchatTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Snapchat Username"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let instagramTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Instagram Username"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let schoolTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "School"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.54, alpha: 1.0)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        return button
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupViews()
        setupActions()
        setupConstraints()
        loadUserData()
        addKeyboardObservers()
    }
    
    private func setupViews() {
        view.addSubview(profileImageView)
        view.addSubview(backgroundImageView)
        view.addSubview(changeBackgroundButton)
        view.addSubview(addImageOverlay)
        view.addSubview(snapchatTextField)
        view.addSubview(instagramTextField)
        view.addSubview(schoolTextField)
        view.addSubview(saveButton)
        view.addSubview(backButton)
        view.addSubview(loadingIndicator) // Add the loading indicator
    }
    
    private func setupActions() {
        // Button and gesture actions
        changeBackgroundButton.addTarget(self, action: #selector(didTapChangeBackgroundPicture), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        
        // Tap gesture to change profile picture
        let profileTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePicture))
        profileImageView.addGestureRecognizer(profileTapGesture)
        
        // Tap gesture to dismiss the keyboard
        let dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissTapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTapGesture)
    }
    
    private func setupConstraints() {
        profileImageView.frame = CGRect(x: (view.frame.size.width - 100) / 2, y: 100, width: 100, height: 100)
        addImageOverlay.frame = CGRect(x: (view.frame.size.width - 50) / 2, y: 120, width: 50, height: 50)
        backgroundImageView.frame = CGRect(x: 20, y: profileImageView.frame.maxY + 20, width: view.frame.size.width - 40, height: 100)
        changeBackgroundButton.frame = CGRect(x: 20, y: backgroundImageView.frame.maxY + 10, width: view.frame.size.width - 40, height: 40)
        snapchatTextField.frame = CGRect(x: 20, y: changeBackgroundButton.frame.maxY + 20, width: view.frame.size.width - 40, height: 40)
        instagramTextField.frame = CGRect(x: 20, y: snapchatTextField.frame.maxY + 20, width: view.frame.size.width - 40, height: 40)
        schoolTextField.frame = CGRect(x: 20, y: instagramTextField.frame.maxY + 20, width: view.frame.size.width - 40, height: 40)
        saveButton.frame = CGRect(x: 20, y: schoolTextField.frame.maxY + 40, width: view.frame.size.width - 40, height: 50)
        backButton.frame = CGRect(x: 20, y: 50, width: 60, height: 30)
        loadingIndicator.center = view.center
    }

    private func loadUserData() {
        snapchatTextField.text = user?.snapchatUsername
        instagramTextField.text = user?.instagramUsername
        schoolTextField.text = user?.school
        
        if let imageUrl = user?.profileImageUrl, !imageUrl.isEmpty {
            loadImage(from: imageUrl, into: profileImageView)
        }
        if let backgroundImageUrl = user?.backgroundImageUrl, !backgroundImageUrl.isEmpty {
            loadImage(from: backgroundImageUrl, into: backgroundImageView)
        }
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
        saveButton.isEnabled = false // Disable save button during saving
        loadingIndicator.startAnimating() // Show loading indicator

        user.snapchatUsername = snapchatTextField.text
        user.instagramUsername = instagramTextField.text
        user.school = schoolTextField.text

        let db = Firestore.firestore()

        db.collection("users").document(user.id).updateData([
            "snapchatUsername": user.snapchatUsername ?? "",
            "instagramUsername": user.instagramUsername ?? "",
            "school": user.school ?? "",
            "profileImageUrl": user.profileImageUrl ?? "",
            "backgroundImageUrl": user.backgroundImageUrl ?? ""
        ]) { [weak self] error in
            self?.isSaving = false
            self?.loadingIndicator.stopAnimating() // Hide loading indicator
            self?.saveButton.isEnabled = true // Re-enable save button

            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
                self?.onSave?(user)
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }

    @objc private func didTapChangeProfilePicture() {
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a new picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    
    @objc private func didTapChangeBackgroundPicture() {
        isChangingBackgroundImage = true
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }

    private func presentCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    private func presentPhotoPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.editedImage] as? UIImage else { return }

        if isChangingBackgroundImage {
            backgroundImageView.image = selectedImage
            uploadImageToStorage(image: selectedImage, isBackground: true) { [weak self] url in
                guard let self = self else { return }
                self.user?.backgroundImageUrl = url
                self.saveImageUrlToFirestore(url: url, isBackground: true)
            }
            isChangingBackgroundImage = false
        } else {
            profileImageView.image = selectedImage
            addImageOverlay.isHidden = true
            uploadImageToStorage(image: selectedImage, isBackground: false) { [weak self] url in
                guard let self = self else { return }
                self.user?.profileImageUrl = url
                self.saveImageUrlToFirestore(url: url, isBackground: false)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        isChangingBackgroundImage = false
    }
    
    private func uploadImageToStorage(image: UIImage, isBackground: Bool, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let storagePath = isBackground ? "background_images" : "profile_images"
        let storageRef = Storage.storage().reference().child("\(storagePath)/\(user?.id ?? UUID().uuidString).jpg")
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Failed to upload image: \(error)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error)")
                    completion(nil)
                    return
                }
                
                completion(url?.absoluteString)
            }
        }
    }

    private func saveImageUrlToFirestore(url: String?, isBackground: Bool) {
        guard let userId = user?.id, let url = url else { return }
        let field = isBackground ? "backgroundImageUrl" : "profileImageUrl"
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).updateData([
            field: url
        ]) { error in
            if let error = error {
                print("Error updating \(field): \(error)")
            } else {
                print("\(field) successfully updated")
            }
        }
    }
    
    private func loadImage(from url: String, into imageView: UIImageView) {
        guard let imageURL = URL(string: url) else { return }
        URLSession.shared.dataTask(with: imageURL) { data, _, error in
            if let error = error {
                print("Failed to load image: \(error)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }

    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            view.frame.origin.y = -keyboardFrame.height / 3
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
}

