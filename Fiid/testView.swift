//
//  testView.swift
//  Fiid
//
//  Created by on 2024-12-15.
//


import SwiftUI

struct testView: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            VStack(alignment: .center) {
                
                Spacer()
                
                Text(languageManager.translate("No restaurants are available..."))
                    .foregroundStyle(Color(.gray))
                
            }
        }
    }
}


struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        testView()
            .environmentObject(LanguageManager())
    }
}
