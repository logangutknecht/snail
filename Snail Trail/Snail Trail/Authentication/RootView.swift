import SwiftUI

class AppState: ObservableObject {
    @Published var snail: Snail?
    @Published var showSignInView: Bool = false
    @Published var userProfile: UserProfile = UserProfile()
    
    private let snailKey = "SavedSnail"
    private let userProfileKey = "SavedUserProfile"
    
    func saveSnail() {
        if let encodedSnail = try? JSONEncoder().encode(snail) {
            UserDefaults.standard.set(encodedSnail, forKey: snailKey)
        }
    }
    
    func loadSnail() {
        if let savedSnail = UserDefaults.standard.data(forKey: snailKey),
           let decodedSnail = try? JSONDecoder().decode(Snail.self, from: savedSnail) {
            snail = decodedSnail
        }
    }
    
    func saveUserProfile() {
        if let encodedProfile = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encodedProfile, forKey: userProfileKey)
        }
    }
    
    func loadUserProfile() {
        if let savedProfile = UserDefaults.standard.data(forKey: userProfileKey),
           let decodedProfile = try? JSONDecoder().decode(UserProfile.self, from: savedProfile) {
            userProfile = decodedProfile
        }
    }
}

struct UserProfile: Codable {
    var username: String = "User123"
    var bio: String = "I love snails!"
    var profilePicture: Data?
}

struct RootView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        ZStack {
            if appState.showSignInView {
                NavigationStack {
                    AuthenticationView(showSignInView: $appState.showSignInView)
                }
            } else {
                TabView {
                    ProfileView()
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
                    
                    SettingsView(showSignInView: $appState.showSignInView)
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                }
                .environmentObject(appState)
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            appState.showSignInView = authUser == nil
            appState.loadSnail()
            appState.loadUserProfile()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
