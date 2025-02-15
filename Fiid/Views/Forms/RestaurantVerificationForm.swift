//
//  RestaurantVerificationForm.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-11-30.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct RestaurantVerificationForm: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    @Binding var showForm: Bool
    @State private var restaurantName: String = ""
    @State private var restaurantAddress: String = ""
    @State private var contactNumber: String = ""
    @State private var email: String = ""
    @State private var ownershipProofImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showImageSourceActionSheet = false
    @State private var submissionStatus: SubmissionStatus = .idle

    enum SubmissionStatus: Equatable {
        case idle
        case submitting
        case success
        case failure(String)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    hideKeyboard()
                }

            VStack(spacing: 15) {
                Text(languageManager.translate("Restaurant Verification"))
                    .font(.headline)
                    .padding()
                    .foregroundColor(.black)

                // Custom Text Fields
                Group {
                    CustomTextField(
                        text: $restaurantName,
                        placeholder: languageManager.translate("Restaurant Name")
                    )
                    .frame(height: 40)

                    CustomTextField(
                        text: $restaurantAddress,
                        placeholder: languageManager.translate("Restaurant Address")
                    )
                    .frame(height: 40)

                    CustomTextField(
                        text: $contactNumber,
                        placeholder: languageManager.translate("Contact Number")
                    )
                    .frame(height: 40)

                    CustomTextField(
                        text: $email,
                        placeholder: languageManager.translate("Email")
                    )
                    .frame(height: 40)
                }
                .padding(.horizontal)

                // Proof of Ownership
                VStack {
                    Text(languageManager.translate("Upload Proof of Ownership"))
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                            .frame(width: 200, height: 200)

                        if let image = ownershipProofImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200)
                                .clipped()
                                .cornerRadius(10)
                        } else {
                            Text(languageManager.translate("Tap to select image"))
                                .foregroundColor(.gray)
                        }
                    }
                    .onTapGesture {
                        showImageSourceActionSheet = true
                    }
                    .confirmationDialog(languageManager.translate("Select Photo"),
                                        isPresented: $showImageSourceActionSheet,
                                        actions: {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            Button(languageManager.translate("Camera")) {
                                imageSource = .camera
                                isShowingImagePicker = true
                            }
                        }
                        Button(languageManager.translate("Photo Library")) {
                            imageSource = .photoLibrary
                            isShowingImagePicker = true
                        }
                        Button(languageManager.translate("Cancel"), role: .cancel) { }
                    })
                    .sheet(isPresented: $isShowingImagePicker) {
                        ImagePicker(sourceType: imageSource, selectedImage: $ownershipProofImage)
                    }
                }

                // Submission Status
                if case .failure(let errorMessage) = submissionStatus {
                    Text("\(languageManager.translate("Error")): \(errorMessage)")
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                // Submit and Cancel Buttons
                HStack(spacing: 20) {
                    Button(action: submitVerificationRequest) {
                        Text(languageManager.translate("Submit"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid() ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!isFormValid() || submissionStatus == .submitting)

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

    // MARK: - Functions
    func isFormValid() -> Bool {
        return  isValidName(restaurantName) &&
                !restaurantAddress.isEmpty &&
                !contactNumber.isEmpty &&
                isValidEmail(email) &&
                ownershipProofImage != nil
    }

    func isValidName(_ text: String) -> Bool {
        let nameFormat = "^[^0-9]+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameFormat)
        return !text.isEmpty && namePredicate.evaluate(with: text)
    }

    func isValidEmail(_ text: String) -> Bool {
        let emailFormat  = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: text)
    }

    func submitVerificationRequest() {
        submissionStatus = .submitting
        
        // Fake a slight delay to simulate a network call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // e.g., upload the data to Firebase, check for errors
            // For success:
            submissionStatus = .success
            // Reset fields
            restaurantName = ""
            restaurantAddress = ""
            contactNumber = ""
            email = ""
            ownershipProofImage = nil
            withAnimation {
                showForm = false
            }
            // If error, do:
            // submissionStatus = .failure("some error message")
        }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

struct RestaurantVerificationForm_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantVerificationForm(showForm: .constant(true))
            .environmentObject(LanguageManager()) // Provide environment object
    }
}
