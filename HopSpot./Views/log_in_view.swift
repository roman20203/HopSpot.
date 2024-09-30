import SwiftUI

struct log_in_view: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModels: log_in_view_model
    @State private var loginSuccess = false
    @State private var isManager = false
    @State private var errorMessage: String?
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("HopSpot.")
                        .font(.system(size: 45, weight: .black))
                        .tracking(1.35)
                        .foregroundColor(.primary)
                    
                    VStack {
                        Image("rabbit_logo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 250, height: 90)
                            .padding(.vertical, 32)

                        VStack(spacing: 24) {
                            InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                                .autocapitalization(.none)
                                .autocorrectionDisabled()

                            InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                            
                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.footnote)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 10)
                            }
                            
                            Button {
                                Task {
                                    do {
                                        try await viewModels.signIn(withEmail: email, password: password)
                                        loginSuccess = viewModels.userSession != nil
                                        isManager = viewModels.currentManager != nil
                                        errorMessage = nil
                                    } catch {
                                        print("DEBUG: Failed to sign in with error \(error.localizedDescription)")
                                        errorMessage = "Invalid Email And/Or Password"
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("SIGN IN")
                                        .fontWeight(.semibold)
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundColor(.black)
                                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                            }
                            .background(AppColor.color)
                            .cornerRadius(10)
                            .padding(.top, 24)
                        }
                        .padding(.horizontal)
                        .padding(.top, 30)

                        
                    }
                }
                .padding(.bottom, 50) // Add padding to avoid being covered by the keyboard
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .padding(.bottom, 30) // Extra padding to adjust for the keyboard
            .onTapGesture {
                hideKeyboard()  // Utility function to dismiss the keyboard
            }
        }
    }
    
    // Helper function to hide keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
