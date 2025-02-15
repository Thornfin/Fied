//
//  ContactFormView.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-12-19.
//

import SwiftUI

struct ContactFormView: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    @Binding var showForm: Bool
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var reason: String = ""

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    hideKeyboard()
                }

            VStack(spacing: 15) {
                Text(languageManager.translate("Contact Us"))
                    .font(.headline)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)

                // Name
                Group {
                    CustomTextField(text: $name,
                                    placeholder: languageManager.translate("Name"))
                        .frame(height: 40)
                        .padding(.horizontal)

                    CustomTextField(text: $email,
                                    placeholder: languageManager.translate("Email"))
                        .frame(height: 40)
                        .padding(.horizontal)

                    CustomTextEditor(
                        text: $reason,
                        placeholder: languageManager.translate("Reason for Contact"),
                        backgroundColor: .white,
                        textColor: .black
                    )
                    .frame(height: 200)
                    .padding(.horizontal)
                }

                // Buttons
                HStack(spacing: 20) {
                    Button(action: submitContactForm) {
                        Text(languageManager.translate("Submit"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid() ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!isFormValid())

                    Button(action: {
                        withAnimation {
                            showForm = false
                        }
                    }) {
                        Text(languageManager.translate("Cancel"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal, 20)
            .shadow(radius: 10)
        }
    }

    // MARK: - Validation
    func isFormValid() -> Bool {
        return isValidName(name) && isValidEmail(email) && !reason.isEmpty
    }

    // Name must be non-empty and contain no digits
    func isValidName(_ text: String) -> Bool {
        let nameFormat = "^[^0-9]+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameFormat)
        return !text.isEmpty && namePredicate.evaluate(with: text)
    }

    // Simple email regex check
    func isValidEmail(_ text: String) -> Bool {
        let emailFormat  = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: text)
    }

    // MARK: - Submit
    func submitContactForm() {
        // Implement your submission logic
        print("Contact Form Submitted: \(name), \(email), \(reason)")

        // Reset fields and close form
        name = ""
        email = ""
        reason = ""
        withAnimation {
            showForm = false
        }
    }

    // Hide keyboard utility
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

struct ContactFormView_Previews: PreviewProvider {
    static var previews: some View {
        ContactFormView(showForm: .constant(true))
            .environmentObject(LanguageManager()) 
    }
}
