//
//  WelcomeView.swift
//  Snail Trail
//
//  Created by Logan Gutknecht on 9/13/24.
//

import SwiftUI

struct WelcomeView: View {
    @State private var showSignInView: Bool = false
    
    var body: some View {
        TabView {
            Text("Profile View - To be implemented")
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
            
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            
            Text("Friends View - To be implemented")
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Friends")
                }
            
            SettingsView(showSignInView: $showSignInView)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
