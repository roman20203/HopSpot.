import SwiftUI

struct register_view: View {
    @EnvironmentObject var viewModels: log_in_view_model
    
    @State private var email = ""
    @State private var password = ""
    @State private var fullname = ""
    @State private var confirmPassword = ""
    @State private var joined = Date()
    @State private var birthdate = Date()
    
    @State private var errorMessage: String?
    @State private var registrationSuccess = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    Text("HopSpot.")
                        .font(.system(size: 45, weight: .black))
                        .tracking(1.35)
                        .foregroundStyle(.primary)
                    
                    VStack(spacing: 24) {
                        Image("rabbit_logo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 250, height: 90)
                            .padding(.vertical, 3)

                        InputView(text: $fullname, title: "Full Name", placeholder: "Full Name")
                            .autocapitalization(.none)
                            .autocorrectionDisabled()

                        InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                            .autocapitalization(.none)
                            .autocorrectionDisabled()

                        InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                            .autocorrectionDisabled()

                        InputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Re-enter your password", isSecureField: true)
                            .autocorrectionDisabled()

                                            
                        // Error message display
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                        }

                        DatePicker("Birthdate", selection: $birthdate, displayedComponents: .date)
                            .datePickerStyle(.compact)

                        // Registration standards text
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Registration Standards:")
                                .font(.headline)
                            Text("- Password must be at least 6 characters long.")
                            Text("- Confirm Password must match the Password.")
                            Text("- You must be at least 17 years old.")
                            Text("- Email address must be valid.")
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.vertical, 16)

                        Button(action: {
                            Task {
                                do {
                                    try await viewModels.createUser(withEmail: email, password: password, fullname: fullname, joined: joined, birthdate: birthdate)
                                    registrationSuccess = true
                                    //print("DEBUG: Registration successful. Redirecting to app.")
                                    errorMessage = nil
                                } catch {
                                    errorMessage = error.localizedDescription
                                    //print("DEBUG: Failed to create user with error \(error.localizedDescription)")
                                }
                            }
                        }) {
                            Text("Register")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(formIsValid() ? AppColor.color : Color.gray)
                                .foregroundStyle(.white)
                                .cornerRadius(8)
                        }
                        .disabled(!formIsValid())
                        .opacity(formIsValid() ? 1.0 : 0.8)
                        .cornerRadius(10)
                        .padding(.top, 24)

                        if registrationSuccess {
                            NavigationLink(destination: main_view()) {
                                Text("Proceed to App")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundStyle(.white)
                                    .cornerRadius(8)
                            }
                            .padding()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 50) // Add padding to avoid the keyboard overlapping the content
                }
                Spacer() // Add spacer to manage the layout when the keyboard is visible
            }
        }
    }
    
    func formIsValid() -> Bool {
        let age = Calendar.current.dateComponents([.year], from: birthdate, to: Date()).year ?? 0
        
        // Regular expression for email validation
        let emailPattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)

        return !email.isEmpty
            && emailPredicate.evaluate(with: email) // Use regex for email validation
            && !password.isEmpty
            && password.count >= 6 // Changed to match the standard text
            && confirmPassword == password
            && !fullname.isEmpty
            && age >= 17
    }

}

