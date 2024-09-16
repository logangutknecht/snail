import SwiftUI

class AppState: ObservableObject {
    @Published var snail: Snail?
    @Published var showSignInView: Bool = false
    
    private let snailKey = "SavedSnail"
    
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
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
