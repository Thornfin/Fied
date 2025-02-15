//
//  ProfileView.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-10-16.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var languageManager: LanguageManager

    @State private var selectedAllergy: Allergy? = nil
    @State private var selectedAccountType: AccountType = .personal
    @State private var showActionSheet: Bool = false
    @State private var actionSheetType: ProfileOption? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var showImageSourceActionSheet = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary

    @Environment(\.dismiss) private var dismiss

    // Flags to control actions
    @State private var shouldAllowActions: Bool = true
    @State private var isActionInProgress: Bool = false

    var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color("DarkGreen")
                    .ignoresSafeArea()

                VStack {
                    // Profile Image and Greeting
                    VStack(alignment: .center, spacing: 30) {
                        Button(action: {
                            debouncedAction {
                                showImageSourceActionSheet = true
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .stroke(Color.gray, lineWidth: 1)
                                    .frame(width: 100, height: 100)

                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    Text(languageManager.translate("Tap to select image"))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 90, height: 90)
                                }
                            }
                        }
                        .confirmationDialog(languageManager.translate("Select Photo"),
                                            isPresented: $showImageSourceActionSheet,
                                            actions: {
                            if isCameraAvailable {
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
                            ImagePicker(sourceType: imageSource, selectedImage: $selectedImage)
                        }

                        Text(languageManager.translate("Welcome !"))
                            .foregroundColor(.white)
                    }
                    .padding(.top)
                    .padding(.bottom, 50)

                    // Profile Options
                    VStack(spacing: 15) {
                        ForEach(ProfileOption.allCases.filter { $0 != .reportBug }, id: \.id) { option in
                            ProfileOptionButton(
                                option: option,
                                action: {
                                    if shouldAllowActions && actionSheetType != option {
                                        print("Profile option selected: \(option.id)")
                                        actionSheetType = option
                                        showActionSheet = true
                                    } else {
                                        print("Action blocked or repeated for option: \(option.id)")
                                    }
                                },
                                language: languageManager.selectedLanguage
                            )
                            .disabled(!shouldAllowActions)
                        }
                    }
                    .padding()

                    Spacer()

                    // "Contact Us" button
                    NavigationLink(destination: ContactIssueSelectionView()) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                            Text(languageManager.translate("Contact Us"))
                                .foregroundColor(.black)
                                .font(.headline)
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding([.horizontal, .bottom])
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .bold()
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
        .actionSheet(isPresented: $showActionSheet) {
            actionSheet(for: actionSheetType)
        }
        .onAppear {
            shouldAllowActions = true
            loadImage()
            loadPreferences()
        }
    }

    // MARK: - Debounced Action
    func debouncedAction(_ action: @escaping () -> Void) {
        guard !isActionInProgress else { return }
        isActionInProgress = true
        action()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isActionInProgress = false
        }
    }

    // MARK: - Action Sheet Logic
    func actionSheet(for option: ProfileOption?) -> ActionSheet {
        switch option {
        case .language:
            return ActionSheet(
                title: Text(languageManager.translate("Select Language")),
                buttons: Language.allCases.map { lang in
                    .default(Text(lang.rawValue)) {
                        languageManager.selectedLanguage = lang
                        // (No location fetch needed here!)
                    }
                } + [.cancel(Text(languageManager.translate("Cancel")))]
            )
//        case .allergies:
//            return ActionSheet(
//                title: Text(languageManager.translate("Select Allergy")),
//                buttons: Allergy.allCases.map { allergy in
//                    .default(Text(allergy.rawValue)) {
//                        selectedAllergy = allergy
//                        saveAllergy(allergy)
//                    }
//                } + [.cancel(Text(languageManager.translate("Cancel")))]
//            )
//        case .accountType:
//            return ActionSheet(
//                title: Text(languageManager.translate("Select Account Type")),
//                buttons: AccountType.allCases.map { acctType in
//                    .default(Text(acctType.rawValue)) {
//                        selectedAccountType = acctType
//                        saveAccountType(acctType)
//                    }
//                } + [.cancel(Text(languageManager.translate("Cancel")))]
//            )
        case .mapPreference:
            return ActionSheet(
                title: Text(languageManager.translate("Select Map App")),
                buttons: MapChoice.allCases.map { choice in
                    .default(Text(choice.rawValue)) {
                        saveMapChoice(choice)
                    }
                } + [.cancel(Text(languageManager.translate("Cancel")))]
            )
        default:
            return ActionSheet(
                title: Text(languageManager.translate("Error")),
                message: nil,
                buttons: [.cancel(Text(languageManager.translate("Cancel")))]
            )
        }
    }

    // MARK: - Save/Load Preferences
    func saveMapChoice(_ choice: MapChoice) {
        UserDefaults.standard.set(choice.rawValue, forKey: "MapChoice")
    }

    func loadImage() {
        let filename = getDocumentsDirectory().appendingPathComponent("profile.jpg")
        if let image = UIImage(contentsOfFile: filename.path) {
            selectedImage = image
        }
    }

    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func saveAllergy(_ allergy: Allergy?) {
        UserDefaults.standard.set(allergy?.rawValue, forKey: "selectedAllergy")
    }

    func saveAccountType(_ accountType: AccountType) {
        UserDefaults.standard.set(accountType.rawValue, forKey: "selectedAccountType")
    }

    func loadPreferences() {
        if let allergyString = UserDefaults.standard.string(forKey: "selectedAllergy"),
           let allergy = Allergy(rawValue: allergyString) {
            selectedAllergy = allergy
        }

        if let acctString = UserDefaults.standard.string(forKey: "selectedAccountType"),
           let accountType = AccountType(rawValue: acctString) {
            selectedAccountType = accountType
        }
    }
}
// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(LanguageManager())
    }
}
