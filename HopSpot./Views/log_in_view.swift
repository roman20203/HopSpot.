import SwiftUI

struct log_in_view: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModels: log_in_view_model
    @State private var loginSuccess = false
    @State private var isManager = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("HopSpot.")
                    .font(.system(size: 45, weight: .black))
                    .tracking(1.35)
                    .foregroundColor(.primary)

                ScrollView {
                    VStack {
                        Image("rabbit_logo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 250, height: 90)
                            .padding(.vertical, 32)

                        VStack(spacing: 24) {
                            InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                                .autocapitalization(.none)

                            InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                                .autocapitalization(.none)
                        }
                        .padding(.horizontal)
                        .padding(.top, 30)

                        Button {
                            Task {
                                do {
                                    try await viewModels.signIn(withEmail: email, password: password)
                                    loginSuccess = viewModels.userSession != nil
                                    isManager = viewModels.currentManager != nil
                                } catch {
                                    print("DEBUG: Failed to sign in with error \(error.localizedDescription)")
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
                        .background(Color(.systemBlue))
                        .disabled(!formIsValid)
                        .opacity(formIsValid ? 1.0 : 0.8)
                        .cornerRadius(10)
                        .padding(.top, 24)

                        if loginSuccess {
                            if isManager {
                                NavigationLink(destination: ClubSelectionView()) {
                                    EmptyView()
                                }
                                .hidden() // Hide the NavigationLink as it's only for navigation purposes
                            } else {
                                NavigationLink(destination: main_view()) {
                                    EmptyView()
                                }
                                .hidden() // Hide the NavigationLink as it's only for navigation purposes
                            }
                        }
                    }
                    .padding(.bottom, 50) // Add padding to avoid cutting off elements with the keyboard
                }
                Spacer() // Spacer helps to avoid layout conflicts with the keyboard
            }
        }
    }

    private var formIsValid: Bool {
        return !email.isEmpty
            && email.contains("@")
            && !password.isEmpty
            && password.count > 5
    }
}

#Preview {
    log_in_view()
        .environmentObject(log_in_view_model())
}

