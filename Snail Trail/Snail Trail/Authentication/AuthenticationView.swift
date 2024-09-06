//
//  AuthenticationView.swift
//  Snail Trail
//
//  Created by Logan Gutknecht on 9/6/24.
//

import SwiftUI

struct AuthenticationView: View {
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack{
            NavigationLink{
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign In with Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth:.infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In")
    }
}



struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(showSignInView: .constant(false))
        }
    }
}
