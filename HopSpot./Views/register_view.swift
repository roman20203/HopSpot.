import SwiftUI

struct register_view: View {
    @EnvironmentObject var viewModels: log_in_view_model
    
    @State private var email = ""
    @State private var password = ""
    @State private var fullname = ""
    @State private var confirmPassword = ""
    @State private var gender: Gender = .male // Assume male as default
    @State private var joined = Date()
    @State private var birthdate = Date()
    
    @State private var registrationSuccess = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    Text("HopSpot.")
                        .font(.system(size: 45, weight: .black))
                        .tracking(1.35)
                        .foregroundColor(.primary)
                    
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

                        Picker("Select your gender", selection: $gender) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                Text(gender.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)

                        DatePicker("Birthdate", selection: $birthdate, displayedComponents: .date)
                            .datePickerStyle(.compact)

                        Button(action: {
                            Task {
                                do {
                                    try await viewModels.createUser(withEmail: email, password: password, fullname: fullname, joined: joined, birthdate: birthdate, gender: gender)
                                    registrationSuccess = true
                                    print("DEBUG: Registration successful. Redirecting to app.")
                                } catch {
                                    print("DEBUG: Failed to create user with error \(error.localizedDescription)")
                                }
                            }
                        }) {
                            Text("Register")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(formIsValid() ? Color.pink : Color.gray)
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
                                    .foregroundColor(.white)
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
        return !email.isEmpty
            && email.contains("@")
            && !password.isEmpty
            && password.count > 5
            && confirmPassword == password
            && !fullname.isEmpty
            && age >= 19
    }
}

