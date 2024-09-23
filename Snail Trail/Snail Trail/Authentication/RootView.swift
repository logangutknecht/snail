import SwiftUI
import CoreLocation

class AppState: ObservableObject {
    @Published var snails: [Snail] = []
    @Published var showSignInView: Bool = false
    @Published var userProfile: UserProfile = UserProfile()
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var userBalance: Double = 100.0 // Starting balance
    
    private let snailsKey = "SavedSnails"
    private let userProfileKey = "SavedUserProfile"
    private let userBalanceKey = "UserBalance"
    
    func saveSnails() {
        if let encodedSnails = try? JSONEncoder().encode(snails) {
            UserDefaults.standard.set(encodedSnails, forKey: snailsKey)
        }
    }
    
    func loadSnails() {
        if let savedSnails = UserDefaults.standard.data(forKey: snailsKey),
           let decodedSnails = try? JSONDecoder().decode([Snail].self, from: savedSnails) {
            snails = decodedSnails
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
    
    func saveUserBalance() {
        UserDefaults.standard.set(userBalance, forKey: userBalanceKey)
    }
    
    func loadUserBalance() {
        userBalance = UserDefaults.standard.double(forKey: userBalanceKey)
    }
    
    func updateSnailPositions() {
        guard let userLocation = userLocation else { return }
        for index in snails.indices {
            snails[index].move(elapsedTime: 1, targetLocation: userLocation)
        }
        saveSnails()
    }
    
    func canCreateFirstSnail() -> Bool {
        return snails.isEmpty
    }
    
    func calculateSnailCost(speed: Double, distance: Double) -> Double {
        // This is a simple cost calculation. Adjust as needed.
        return speed * distance * 0.1
    }
    
    func purchaseSnail(name: String, color: Color, speed: Double, location: CLLocationCoordinate2D) -> Bool {
        guard let userLocation = userLocation else { return false }
        let distance = Snail.calculateDistance(from: location, to: userLocation)
        let cost = calculateSnailCost(speed: speed, distance: distance)
        
        if userBalance >= cost {
            let newSnail = Snail(name: name, location: location, color: color, speed: speed)
            snails.append(newSnail)
            userBalance -= cost
            saveSnails()
            saveUserBalance()
            return true
        }
        return false
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
        .environmentObject(appState)  // Add this line to ensure AppState is available everywhere
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            appState.showSignInView = authUser == nil
            appState.loadSnails()
            appState.loadUserProfile()
            appState.loadUserBalance()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
