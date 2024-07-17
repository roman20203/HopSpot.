//
//  register_view.swift
//  HopSpot.
//
//  Created by Ben Roman on 2024-07-10.
//

import SwiftUI

struct register_view: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}




extension register_view: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        
        && confirmPassword == password
        && !fullname.isEmpty
    }
}

#Preview {
    register_view()
}
