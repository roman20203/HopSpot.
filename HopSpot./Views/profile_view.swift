import SwiftUI

struct profile_view: View {
    @EnvironmentObject var viewModel: log_in_view_model
    @State private var user: User?
    @State private var showSettings = false
    @State private var showEditProfile = false
    @State private var isLoading = false
    @State private var showBackgroundImagePicker = false // State to show the background image picker
    @State private var isBackgroundImageSet = false // State to track if a background image is already set
    
    // Helper function to set dynamic colors based on color scheme
    private func dynamicColor(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Background color for the entire view including the top section
            
            ScrollView {
                VStack(spacing: 0) {
                    // Top bar with black background and white text
                    ZStack(alignment: .top) {
                        Color.black // Background color for the top bar
                            .edgesIgnoringSafeArea(.all)
                        
                        HStack {
                            Spacer()
                            Text("HopSpot.")
                                .font(.system(size: 30, weight: .black))
                                .tracking(0.9)
                                .foregroundColor(.white) // Static white text color for contrast
                                .padding(.top, 10)
                            Spacer()
                        }
                    }
                    .frame(height: 90)
                    
                    // Background Image using backgroundImageUrl from user
                    ZStack {
                        if let backgroundImageUrl = user?.backgroundImageUrl, !backgroundImageUrl.isEmpty {
                            AsyncImage(url: URL(string: backgroundImageUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width, height: 203)
                                    .clipped()
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray)
                                    .frame(width: UIScreen.main.bounds.width, height: 203)
                                    .overlay(
                                        Text("Loading Image...")
                                            .foregroundColor(.white)
                                            .font(.headline)
                                    )
                            }
                        } else { // Default gray background with tap to add text
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: UIScreen.main.bounds.width, height: 203)
                                .overlay(
                                    Text("Tap to select an image")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                )
                        }
                    }
                    .onTapGesture {
                        if !isBackgroundImageSet { // Allow tapping only if an image has not been set
                            showBackgroundImagePicker = true // Show the image picker when tapped
                        }
                    }
                    .disabled(isBackgroundImageSet) // Disable tap gesture if the background image is set
                    .sheet(isPresented: $showBackgroundImagePicker) {
                        BackgroundImageViewController() // Show BackgroundImageViewController for selecting or capturing an image
                            .environmentObject(viewModel)
                            .onDisappear {
                                if let backgroundImageUrl = viewModel.currentUser?.backgroundImageUrl, !backgroundImageUrl.isEmpty {
                                    isBackgroundImageSet = true // Set the state to true once an image is uploaded
                                }
                            }
                    }


                    VStack(spacing: -30) {
                        ZStack(alignment: .bottom) {
                            // Adaptive background for the user info section
                            Rectangle()
                                .fill(dynamicColor(light: .white, dark: Color(UIColor.systemGray6)))
                                .cornerRadius(50)
                                .shadow(radius: 15)
                                .padding(.top, -25)
                                .frame(height: 735)
                            
                            VStack(alignment: .center) { // Center align the VStack contents
                                // User profile picture and name section
                                VStack { // Changed from HStack to VStack to center align the image and name
                                    ZStack {
                                        if let imageUrl = user?.profileImageUrl, !imageUrl.isEmpty {
                                            AsyncImage(url: URL(string: imageUrl)) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            } placeholder: {
                                                Image(systemName: "person.circle")
                                                    .resizable()
                                                    .foregroundColor(.gray)
                                            }
                                            .frame(width: 90, height: 90) // Profile Image Size and Position
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.pink, lineWidth: 2.5)
                                            )
                                            .offset(x: 0, y: -80) // Adjust the X and Y values to move the image
                                        } else {
                                            Image(systemName: "plus")
                                                .resizable()
                                                .foregroundColor(dynamicColor(light: .black, dark: .white))
                                                .frame(width: 50, height: 50) // Profile Image Placeholder Size and Position
                                                .background(Color.gray)
                                                .clipShape(Circle())
                                                .offset(x: 0, y: -80) // Adjust the X and Y values for the placeholder
                                        }
                                    }
                                    .onTapGesture {
                                        showEditProfile = true
                                    }
                                    
                                    Text(user?.fullname ?? "Username") // Center align the username
                                        .font(.system(size: 20, weight: .black))
                                        .tracking(0.9)
                                        .foregroundColor(dynamicColor(light: .black, dark: .white))
                                        .offset(x: 0, y: -45) // Adjust position of the username text
                                }
                                
                                // Buttons for Edit Profile and Settings
                                HStack(spacing: 10) { // Adjust spacing between buttons here
                                    Button(action: {
                                        showEditProfile = true
                                    }) {
                                        Text("Edit Profile")
                                            .font(Font.custom("Forma DJR Text", size: 12).weight(.bold))
                                            .padding()
                                            .frame(width: 100, height: 30) // Button Size
                                            .background(dynamicColor(light: Color(red: 0.95, green: 0.95, blue: 0.95), dark: Color(UIColor.systemGray5)))
                                            .cornerRadius(26)
                                    }
                                    
                                    Button(action: {
                                        showSettings.toggle()
                                    }) {
                                        HStack {
                                            Image(systemName: "gearshape.fill")
                                            Text("Settings")
                                        }
                                        .font(Font.custom("Forma DJR Text", size: 12).weight(.bold))
                                        .padding()
                                        .frame(width: 120, height: 30) // Button Size
                                        .background(dynamicColor(light: Color(red: 0.95, green: 0.95, blue: 0.95), dark: Color(UIColor.systemGray5)))
                                        .cornerRadius(26)
                                    }
                                }
                                .padding(.top, -20) // Adjust padding above buttons
                                .offset(x: 0, y: -15) // Adjust the X and Y values to move the buttons
                                .padding(.bottom, 20) // Padding below buttons

                                // User information (My Socials Section)
                                VStack(alignment: .leading, spacing: 16) { // Adjust spacing between information fields
                                    Text("My Socials") // Section Title
                                        .font(.system(size: 18, weight: .bold)) // Font size and weight for "My Socials"
                                        .foregroundColor(dynamicColor(light: .black, dark: .white))
                                        .padding(.leading, 20) // Padding for section title

                                    // Instagram Social with background
                                    HStack {
                                        HStack {
                                            Image("Instagram_icon") // Add Instagram icon
                                                .resizable()
                                                .frame(width: 24, height: 24) // Adjust size of the icon
                                            Text(user?.instagramUsername ?? "Not Set") // Display Instagram Username
                                                .font(.system(size: 12, weight: .bold)) // Same font as "My Socials"
                                                .foregroundColor(dynamicColor(light: .black, dark: .white))
                                            Spacer()
                                            Button(action: {
                                                if let username = user?.instagramUsername, !username.isEmpty {
                                                    // Open the user's Instagram profile
                                                    let appURL = URL(string: "instagram://user?username=\(username)")!
                                                    let webURL = URL(string: "https://instagram.com/\(username)")!
                                                    
                                                    if UIApplication.shared.canOpenURL(appURL) {
                                                        UIApplication.shared.open(appURL)
                                                    } else {
                                                        UIApplication.shared.open(webURL)
                                                    }
                                                }
                                            }) {
                                                Image(systemName: "arrow.right.circle.fill") // Arrow icon for Instagram
                                                    .foregroundColor(.pink)
                                            }
                                        }
                                        .padding(.horizontal, 10) // Adjust padding inside the rectangle
                                        .padding(.vertical, 8) // Vertical padding for spacing
                                        .background(dynamicColor(light: Color.gray.opacity(0.2), dark: Color(UIColor.systemGray4))) // Rectangle background color
                                        .cornerRadius(10) // Rounded corners
                                        .frame(width: UIScreen.main.bounds.width - 70) // Adjust the width of the rectangle
                                        .padding(.leading, -0) // Adjust this to move the rectangle to the left
                                    }

                                    // Snapchat Social
                                    HStack {
                                        HStack {
                                            Image("snapchat") // Add Snapchat icon
                                                .resizable()
                                                .frame(width: 24, height: 24) // Adjust size of the icon
                                            Text(user?.snapchatUsername ?? "Not Set") // Display Snapchat Username
                                                .font(.system(size: 12, weight: .bold)) // Same font as "My Socials"
                                                .foregroundColor(dynamicColor(light: .black, dark: .white))
                                            Spacer()
                                            Button(action: {
                                                if let username = user?.snapchatUsername, !username.isEmpty {
                                                    let appURL = URL(string: "snapchat://add/\(username)")!
                                                    if UIApplication.shared.canOpenURL(appURL) {
                                                        UIApplication.shared.open(appURL)
                                                    }
                                                }
                                            }) {
                                                Image(systemName: "arrow.right.circle.fill") // Arrow icon for Snapchat
                                                    .foregroundColor(.pink)
                                            }
                                        }
                                        .padding(.horizontal, 10) // Adjust padding inside the rectangle
                                        .padding(.vertical, 8) // Vertical padding for spacing
                                        .background(dynamicColor(light: Color.gray.opacity(0.2), dark: Color(UIColor.systemGray4))) // Rectangle background color
                                        .cornerRadius(10) // Rounded corners
                                        .frame(width: UIScreen.main.bounds.width - 70) // Adjust the width of the rectangle
                                        .padding(.leading, -0) // Adjust this to move the rectangle to the left
                                    }

                                    // School Information
                                    HStack {
                                        HStack {
                                            Image("gradcap") // Add School icon
                                                .resizable()
                                                .frame(width: 24, height: 24) // Adjust size of the icon
                                            Text(user?.school ?? "Not Set") // Display School
                                                .font(.system(size: 12, weight: .bold)) // Same font as "My Socials"
                                                .foregroundColor(dynamicColor(light: .black, dark: .white))
                                            Spacer()
                                            Button(action: {
                                                showEditProfile = true
                                            }) {
                                                Image(systemName: "arrow.right.circle.fill") // Arrow icon for School
                                                    .foregroundColor(.pink)
                                            }
                                        }
                                        .padding(.horizontal, 10) // Adjust padding inside the rectangle
                                        .padding(.vertical, 8) // Vertical padding for spacing
                                        .background(dynamicColor(light: Color.gray.opacity(0.2), dark: Color(UIColor.systemGray4))) // Rectangle background color
                                        .cornerRadius(10) // Rounded corners
                                        .frame(width: UIScreen.main.bounds.width - 70) // Adjust the width of the rectangle
                                        .padding(.leading, -0) // Adjust this to move the rectangle to the left
                                    }

                                    // Add Socials Button
                                    HStack {
                                        Image(systemName: "plus.circle.fill") // Add icon for "Add Socials"
                                            .foregroundColor(.pink)
                                            .font(.system(size: 18))
                                        Text("Add Socials")
                                            .font(.system(size: 16)) // Font size for "Add Socials"
                                            .foregroundColor(.pink)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                }
                                .font(.system(size: 16)) // Font size for all texts
                                .foregroundColor(dynamicColor(light: .black, dark: .white)) // Text color for all
                                .padding(.leading, 20) // Padding for user information section
                                .offset(x: 0, y: 0) // Adjust the X and Y values to move the user information
                                
                                Spacer()
                            }
                            .padding()
                        }
                        .padding(.top, -20) // Adjust positioning relative to background
                    }
                }
            }
            
            if isLoading {
                ProgressView("Saving...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .background(dynamicColor(light: Color.white.opacity(0.5), dark: Color.black.opacity(0.5)).edgesIgnoringSafeArea(.all))
            }
        }
        .onAppear {
            self.user = viewModel.currentUser
            if let backgroundImageUrl = user?.backgroundImageUrl, !backgroundImageUrl.isEmpty {
                isBackgroundImageSet = true // Initialize state based on whether the background image is already set
            }
        }
        .fullScreenCover(isPresented: $showEditProfile) {
            EditProfileViewControllerWrapper(user: $user, isLoading: $isLoading)
                .environmentObject(viewModel)
        }
        .fullScreenCover(isPresented: $showSettings) {
            seetingsViewControllerWrapper()
                .environmentObject(viewModel)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ProfileUpdated"))) { _ in
            DispatchQueue.main.async {
                Task {
                    await viewModel.fetchUser()
                    self.user = viewModel.currentUser
                }
            }
        }
    }
}

// Wrapper to present EditProfileViewController in SwiftUI
struct EditProfileViewControllerWrapper: UIViewControllerRepresentable {
    @Binding var user: User?
    @Binding var isLoading: Bool

    func makeUIViewController(context: Context) -> EditProfileViewController {
        let vc = EditProfileViewController()
        vc.user = user
        vc.onSave = { updatedUser in
            user = updatedUser
            isLoading = false
            NotificationCenter.default.post(name: NSNotification.Name("ProfileUpdated"), object: nil)
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: EditProfileViewController, context: Context) {}
}

// Wrapper to present seetingsViewController in SwiftUI
struct seetingsViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> seetingsViewController {
        let vc = seetingsViewController()
        return vc
    }

    func updateUIViewController(_ uiViewController: seetingsViewController, context: Context) {}
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        profile_view()
            .environmentObject(log_in_view_model())
    }
}

