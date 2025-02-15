//
//  ReportBugForm.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-10-17.
//

import SwiftUI

struct ReportBugForm: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    @Binding var showForm: Bool
    @State private var bugDescription: String = ""
    private let maxCharacters = 500

    var characterCount: Int {
        bugDescription.count
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    hideKeyboard()
                }

            VStack(spacing: 15) {
                Text(languageManager.translate("Report a Bug"))
                    .font(.headline)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)

                // Bug Description Editor
                CustomTextEditor(
                    text: $bugDescription,
                    placeholder: languageManager.translate("Describe the bug here..."),
                    backgroundColor: .white,
                    textColor: .black
                )
                .frame(height: 200)
                .padding(.horizontal)

                // Character count
                Text("\(characterCount) / \(maxCharacters) \(languageManager.translate("characters"))")
                    .font(.subheadline)
                    .foregroundColor(characterCount > maxCharacters ? .red : .gray)
                    .padding(.bottom, 10)

                // Buttons
                HStack(spacing: 20) {
                    Button(action: submitBugReport) {
                        Text(languageManager.translate("Submit"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(characterCount == 0 || characterCount > maxCharacters ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(characterCount == 0 || characterCount > maxCharacters)

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

    func submitBugReport() {
        saveBugReportToFirebase(bugDescription)
        bugDescription = ""
        withAnimation {
            showForm = false
        }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }

    func limitText(_ upper: Int) {
        if bugDescription.count > upper {
            bugDescription = String(bugDescription.prefix(upper))
        }
    }

    // MARK: - Firebase Integration
    func saveBugReportToFirebase(_ description: String) {
        // e.g.,
        // let db = Firestore.firestore()
        // db.collection("bugReports").addDocument(data: [
        //     "description": description,
        //     "timestamp": Timestamp()
        // ])
    }
}

struct ReportBugForm_Previews: PreviewProvider {
    static var previews: some View {
        ReportBugForm(showForm: .constant(true))
            .environmentObject(LanguageManager()) 
    }
}
