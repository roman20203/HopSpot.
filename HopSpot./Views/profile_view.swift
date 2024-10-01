import SwiftUI

struct profile_view: View {
    @EnvironmentObject var viewModel: log_in_view_model
    @EnvironmentObject var clubHandler: club_firebase_handler
    @State private var user: User?
    
    @State private var showCreateView = false
    
    @State private var showSettings = false
    @State private var showEditProfile = false
    @State private var isLoading = false
    @State private var showBackgroundImagePicker = false
    @State private var isBackgroundImageSet = false

    // Helper function for dynamic colors
    private func dynamicColor(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Background color for the whole view
            
            ScrollView {
                VStack(spacing: 0) {
                    // Top bar with the title
                    ZStack(alignment: .top) {
                        Color.black.edgesIgnoringSafeArea(.all)
                        HStack {
                            Spacer()
                            Text("HopSpot.")
                                .font(.system(size: 30, weight: .black))
                                .tracking(0.9)
                                .foregroundStyle(.white)
                                .padding(.top, 10)
                            Spacer()
                        }
                    }
                    .frame(height: 90)

                    // Background Image section
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
                                            .foregroundStyle(.white)
                                            .font(.headline)
                                    )
                            }
                        } else {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: UIScreen.main.bounds.width, height: 203)
                                .overlay(
                                    Text("Tap to select an image")
                                        .foregroundStyle(.white)
                                        .font(.headline)
                                )
                        }
                    }
                    .onTapGesture {
                        if !isBackgroundImageSet {
                            showBackgroundImagePicker = true
                        }
                    }
                    .disabled(isBackgroundImageSet) // Disable tap if background image is set
                    .sheet(isPresented: $showBackgroundImagePicker) {
                        BackgroundImageViewController()
                            .environmentObject(viewModel)
                            .onDisappear {
                                if let backgroundImageUrl = viewModel.currentUser?.backgroundImageUrl, !backgroundImageUrl.isEmpty {
                                    isBackgroundImageSet = true
                                }
                            }
                    }

                    // User Info Section with Profile Image
                    VStack(spacing: -30) {
                        ZStack(alignment: .bottom) {
                            // Adaptive background for the user info section
                            Rectangle()
                                .fill(dynamicColor(light: .white, dark: Color(UIColor.systemGray6)))
                                .cornerRadius(50)
                                .shadow(radius: 15)
                                .padding(.top, -25) // Match the padding to move up
                                .frame(height: 735)
                            
                            VStack(alignment: .center) {
                                // Profile picture and user name
                                VStack {
                                    ZStack {
                                        if let imageUrl = user?.profileImageUrl, !imageUrl.isEmpty {
                                            AsyncImage(url: URL(string: imageUrl)) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            } placeholder: {
                                                Image(systemName: "person.circle")
                                                    .resizable()
                                                    .foregroundStyle(.gray)
                                            }
                                            .frame(width: 90, height: 90)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.pink, lineWidth: 2.5)
                                            )
                                            .offset(y: -80) // Adjusted to match the previous code
                                        } else {
                                            Image(systemName: "plus")
                                                .resizable()
                                                .foregroundStyle(dynamicColor(light: .black, dark: .white))
                                                .frame(width: 50, height: 50)
                                                .background(Color.gray)
                                                .clipShape(Circle())
                                                .offset(y: -80)
                                        }
                                    }
                                    .onTapGesture {
                                        showEditProfile = true
                                    }
                                    
                                    Text(user?.fullname ?? "Username")
                                        .font(.system(size: 20, weight: .black))
                                        .tracking(0.9)
                                        .foregroundStyle(dynamicColor(light: .black, dark: .white))
                                        .offset(y: -45) // Match the position
                                }
                                
                                // Edit Profile and Settings buttons
                                HStack(spacing: 10) {
                                    Button(action: {
                                        showEditProfile = true
                                    }) {
                                        Text("Edit Profile")
                                            .font(Font.custom("Forma DJR Text", size: 12).weight(.bold))
                                            .padding()
                                            .frame(width: 100, height: 30)
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
                                        .frame(width: 120, height: 30)
                                        .background(dynamicColor(light: Color(red: 0.95, green: 0.95, blue: 0.95), dark: Color(UIColor.systemGray5)))
                                        .cornerRadius(26)
                                    }
                                }
                                .padding(.top, -20)
                                .offset(y: -15) // Match the button position
                                .padding(.bottom, 20)

                                // User Social Info
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("My Socials")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(dynamicColor(light: .black, dark: .white))
                                        .padding(.leading, 20)

                                    // Instagram Social with background
                                    HStack {
                                        HStack {
                                            Image("Instagram_icon")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                            Text(user?.instagramUsername ?? "Not Set")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(dynamicColor(light: .black, dark: .white))
                                            Spacer()
                                            Button(action: {
                                                if let username = user?.instagramUsername, !username.isEmpty {
                                                    let appURL = URL(string: "instagram://user?username=\(username)")!
                                                    let webURL = URL(string: "https://instagram.com/\(username)")!
                                                    UIApplication.shared.open(UIApplication.shared.canOpenURL(appURL) ? appURL : webURL)
                                                }
                                            }) {
                                                Image(systemName: "arrow.right.circle.fill")
                                                    .foregroundStyle(AppColor.color)
                                            }
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .background(dynamicColor(light: Color.gray.opacity(0.2), dark: Color(UIColor.systemGray4)))
                                        .cornerRadius(10)
                                        .frame(width: UIScreen.main.bounds.width - 70)
                                    }

                                    // Snapchat Social
                                    HStack {
                                        HStack {
                                            Image("snapchat")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                            Text(user?.snapchatUsername ?? "Not Set")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(dynamicColor(light: .black, dark: .white))
                                            Spacer()
                                            Button(action: {
                                                if let username = user?.snapchatUsername, !username.isEmpty {
                                                    let appURL = URL(string: "snapchat://add/\(username)")!
                                                    if UIApplication.shared.canOpenURL(appURL) {
                                                        UIApplication.shared.open(appURL)
                                                    }
                                                }
                                            }) {
                                                Image(systemName: "arrow.right.circle.fill")
                                                    .foregroundStyle(AppColor.color)
                                            }
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .background(dynamicColor(light: Color.gray.opacity(0.2), dark: Color(UIColor.systemGray4)))
                                        .cornerRadius(10)
                                        .frame(width: UIScreen.main.bounds.width - 70)
                                    }

                                    // School Information
                                    HStack {
                                        HStack {
                                            Image("gradcap")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                            Text(user?.school ?? "Not Set")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(dynamicColor(light: .black, dark: .white))
                                            Spacer()
                                            Button(action: {
                                                showEditProfile = true
                                            }) {
                                                Image(systemName: "arrow.right.circle.fill")
                                                    .foregroundStyle(AppColor.color)
                                            }
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .background(dynamicColor(light: Color.gray.opacity(0.2), dark: Color(UIColor.systemGray4)))
                                        .cornerRadius(10)
                                        .frame(width: UIScreen.main.bounds.width - 70)
                                    }

                                    // Add Socials Button
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundStyle(AppColor.color)
                                            .font(.system(size: 18))
                                        Text("Add Socials")
                                            .font(.system(size: 16))
                                            .foregroundStyle(AppColor.color)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .onTapGesture{
                                          showEditProfile = true
                                    }
                                    
                                    // Frat User View
                                    // Only appears for frat users, (users
                                    //with a fratId)
                                    
                                    if(user?.isFrat == true){
                                        frat_user_view()
                                            .overlay(
                                                Button(action: {
                                                    showCreateView = true
                                                }) {
                                                    Image(systemName: "plus")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 25, height: 25)
                                                        .background(Color(UIColor.systemBackground).opacity(0.7)) // Adapt to light and dark mode
                                                        .clipShape(Circle())
                                                        .foregroundStyle(AppColor.color) // Custom color
                                                        .padding()
                                                }
                                                .padding(),alignment: .bottomTrailing
                                            )
                                            .sheet(isPresented: $showCreateView) {
                                                frat_event_create_view(clubName: user?.frat?.name ?? "No Frat", clubImageURL: user?.frat?.imageURL ?? "placeholder_image_url",
                                                    onSave:{
                                                        clubHandler.refreshFrats();
                                                })
                                                .environmentObject(viewModel) // Pass your environment objects if needed
                                            }
                                    }
                                }
                                .padding(.leading, 20)
                                .offset(x: 0, y: 0) // Adjust positioning
                                
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
                isBackgroundImageSet = true
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

    // Modify this method to wrap EditProfileViewController in a UINavigationController
    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = EditProfileViewController()
        vc.user = user
        vc.onSave = { updatedUser in
            user = updatedUser
            isLoading = false
            NotificationCenter.default.post(name: NSNotification.Name("ProfileUpdated"), object: nil)
        }

        // Wrap EditProfileViewController in UINavigationController
        let navController = UINavigationController(rootViewController: vc)
        return navController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // You can update the view controller here if needed
    }
}


// Wrapper to present SettingsViewController in SwiftUI
struct seetingsViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> seetingsViewController {
        let vc = seetingsViewController()
        return vc
    }

    func updateUIViewController(_ uiViewController: seetingsViewController, context: Context) {}
}

// Preview for SwiftUI
struct profile_view_Previews: PreviewProvider {
    static var previews: some View {
        profile_view()
            .environmentObject(log_in_view_model())
    }
}

