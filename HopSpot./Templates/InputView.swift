//
//  input_view.swift
//  HopSpot.
//
//  Created by Mina on 2024-07-11.
//



import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundColor(.primary)
                .fontWeight(.semibold)
                .font(.footnote)
                .autocorrectionDisabled()
            
            if isSecureField {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 14))
                    .textContentType(.oneTimeCode)
                    .autocorrectionDisabled()
                    
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
                    .textContentType(.none)
                    .autocorrectionDisabled()
            }
            Divider()
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView(text:.constant(""), title: "Email Address", placeholder: "name@example.com")
    }
}
