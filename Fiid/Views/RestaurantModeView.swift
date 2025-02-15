//
//  RestaurantModeView.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-11-30.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct RestaurantModeView: View {
    @State private var restaurantLogo: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showImageSourceActionSheet = false
    @State private var filters: [FilterOption] = []
    @State private var locations: [String] = []
    @State private var newLocation: String = ""
    @State private var submissionStatus: SubmissionStatus = .idle

    enum SubmissionStatus: Equatable {
        case idle
        case submitting
        case success
        case failure(String)
    }

    var body: some View {
        ZStack {
            Color("DarkGreen")
                .ignoresSafeArea()
            ScrollView(showsIndicators: false){
                VStack(spacing: 20) {

                    VStack {
                        Text("Restaurant Logo")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                                .frame(width: 200, height: 200)
                            
                            if let image = restaurantLogo {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 200)
                                    .clipped()
                                    .cornerRadius(10)
                            } else {
                                Text("Tap to select image")
                                    .foregroundColor(.gray)
                            }
                        }
                        .onTapGesture {
                            showImageSourceActionSheet = true
                        }
                        .actionSheet(isPresented: $showImageSourceActionSheet) {
                            ActionSheet(title: Text("Select Photo"), buttons: [
                                .default(Text("Camera"), action: {
                                    imageSource = .camera
                                    isShowingImagePicker = true
                                }),
                                .default(Text("Photo Library"), action: {
                                    imageSource = .photoLibrary
                                    isShowingImagePicker = true
                                }),
                                .cancel()
                            ])
                        }
                        .sheet(isPresented: $isShowingImagePicker) {
                            ImagePicker(sourceType: imageSource, selectedImage: $restaurantLogo)
                        }
                    }
                    
                    // Filters
                    VStack(alignment: .leading) {
                        Text("Filters")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ForEach(FilterOption.allCases, id: \.self) { filterOption in
                            Toggle(filterOption.title, isOn: Binding(
                                get: { filters.contains(filterOption) },
                                set: { isOn in
                                    if isOn {
                                        filters.append(filterOption)
                                    } else {
                                        filters.removeAll { $0 == filterOption }
                                    }
                                }
                            ))
                            .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Locations
                    VStack(alignment: .leading) {
                        Text("Locations")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ForEach(locations, id: \.self) { location in
                            Text(location)
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            TextField("Add New Location", text: $newLocation)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: {
                                if !newLocation.isEmpty {
                                    locations.append(newLocation)
                                    newLocation = ""
                                }
                            }) {
                                Image(systemName: "plus")
                                    .padding()
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Submission Status
                    if case .failure(let errorMessage) = submissionStatus {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // Submit Button
                    Button(action: submitChanges) {
                        Text("Submit Changes for Approval")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(submissionStatus == .submitting ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(submissionStatus == .submitting)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                
                .navigationTitle("Restaurant Mode")
                .onAppear {
                    checkSubmissionStatus()
                }
            }
        }
    }

    // MARK: - Functions

    func submitChanges() {
        submissionStatus = .submitting

        guard let userId = Auth.auth().currentUser?.uid else {
            submissionStatus = .failure("User not authenticated.")
            return
        }

        let db = Firestore.firestore()
        let storage = Storage.storage()
        var updateData: [String: Any] = [
            "filters": filters,
            "locations": locations,
            "status": "pending",
            "timestamp": Timestamp()
        ]

        if let logoImage = restaurantLogo, let imageData = logoImage.jpegData(compressionQuality: 0.8) {
            let imageRef = storage.reference().child("restaurantLogos/\(userId).jpg")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            imageRef.putData(imageData, metadata: metadata) { metadata, error in
                if let error = error {
                    submissionStatus = .failure(error.localizedDescription)
                    return
                }

                imageRef.downloadURL { url, error in
                    if let error = error {
                        submissionStatus = .failure(error.localizedDescription)
                        return
                    }

                    guard let downloadURL = url else {
                        submissionStatus = .failure("Failed to retrieve image URL.")
                        return
                    }

                    updateData["logoURL"] = downloadURL.absoluteString

                    // Save the data to Firestore
                    db.collection("restaurantUpdates").document(userId).setData(updateData) { error in
                        if let error = error {
                            submissionStatus = .failure(error.localizedDescription)
                        } else {
                            submissionStatus = .success
                            // Inform the user
                            print("Changes submitted for approval.")
                        }
                    }
                }
            }
        } else {
            db.collection("restaurantUpdates").document(userId).setData(updateData) { error in
                if let error = error {
                    submissionStatus = .failure(error.localizedDescription)
                } else {
                    submissionStatus = .success
                    print("Changes submitted for approval.")
                }
            }
        }
    }

    func checkSubmissionStatus() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }

        let db = Firestore.firestore()
        db.collection("restaurantUpdates").document(userId).addSnapshotListener { documentSnapshot, error in
            if let document = documentSnapshot, document.exists {
                let data = document.data()
                let status = data?["status"] as? String ?? "pending"
                if status == "approved" {
                    // Update local data or inform the user
                    submissionStatus = .success
                } else if status == "rejected" {
                    submissionStatus = .failure("Your changes were rejected.")
                } else {
                    submissionStatus = .idle
                }
            } else {
                // Handle document does not exist
                submissionStatus = .idle
            }
        }
    }
}

struct RestaurantModeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RestaurantModeView()
        }
    }
}
