//
//  ContactIssueSelectionView.swift
//  Fiid
//
//  Created by ilyass Serghini on 2024-12-19.
//
import SwiftUI

struct ContactIssueSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var languageManager: LanguageManager 
    
    @State private var showRestaurantForm = false
    @State private var showBugReportForm = false
    @State private var showContactForm = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("DarkGreen")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text(languageManager.translate("Select an Issue"))
                        .font(.headline)
                        .padding()
                        .foregroundColor(.white)
                    
                    // Request Restaurant Account
                    Button(action: {
                        withAnimation {
                            showRestaurantForm = true
                        }
                    }) {
                        Text(languageManager.translate("Request Restaurant Account"))
                            .font(.system(size: 18))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Report a Bug
                    Button(action: {
                        withAnimation {
                            showBugReportForm = true
                        }
                    }) {
                        Text(languageManager.translate("Report a Bug"))
                            .font(.system(size: 18))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Contact Form (Other)
                    Button(action: {
                        withAnimation {
                            showContactForm = true
                        }
                    }) {
                        Text(languageManager.translate("Other"))
                            .font(.system(size: 18))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
                
                // Overlays
                if showRestaurantForm {
                    RestaurantVerificationFormOverlay(showForm: $showRestaurantForm)
                }
                
                if showBugReportForm {
                    BugReportFormOverlay(showForm: $showBugReportForm)
                }
                
                if showContactForm {
                    ContactFormOverlay(showForm: $showContactForm)
                }
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
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
    }
}

// MARK: - Overlays
struct RestaurantVerificationFormOverlay: View {
    @Binding var showForm: Bool
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showForm = false
                    }
                }
            
            RestaurantVerificationForm(showForm: $showForm)
                .transition(.move(edge: .bottom))
                .onTapGesture {
                    hideKeyboard()
                }
        }
    }
}

struct BugReportFormOverlay: View {
    @Binding var showForm: Bool
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showForm = false
                    }
                }
            
            ReportBugForm(showForm: $showForm)
                .transition(.move(edge: .bottom))
                .onTapGesture {
                    hideKeyboard()
                }
        }
    }
}

struct ContactFormOverlay: View {
    @Binding var showForm: Bool
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showForm = false
                    }
                }

            ContactFormView(showForm: $showForm)
                .transition(.move(edge: .bottom))
                .onTapGesture {
                    hideKeyboard()
                }
        }
    }
}

// MARK: - Hide Keyboard Helper
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview
struct ContactIssueSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ContactIssueSelectionView()
            .environmentObject(LanguageManager()) // Provide the environment object
    }
}
