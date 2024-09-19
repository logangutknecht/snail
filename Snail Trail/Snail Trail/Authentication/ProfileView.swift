import CoreLocation
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var isCreatingSnail = false
    @State private var errorMessage = ""
    @State private var showingProfileEdit = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    profileHeader
                    
                    if let snail = appState.snail {
                        snailInfo(snail)
                    } else {
                        createSnailButton
                    }
                    
                    if isCreatingSnail {
                        ProgressView()
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarItems(trailing: editButton)
        }
        .sheet(isPresented: $showingProfileEdit) {
            ProfileEditView(profile: $appState.userProfile)
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 10) {
            if let imageData = appState.userProfile.profilePicture,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
            }
            
            Text(appState.userProfile.username)
                .font(.title)
            
            Text(appState.userProfile.bio)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private func snailInfo(_ snail: Snail) -> some View {
        VStack(spacing: 10) {
            SnailIconView(color: snail.color)
                .frame(width: 100, height: 100)
            
            Text("Your snail: \(snail.name)")
                .font(.headline)
        }
    }
    
    private var createSnailButton: some View {
        Button("Create Starter Snail") {
            createStarterSnail()
        }
        .disabled(isCreatingSnail)
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
    }
    
    private var editButton: some View {
        Button(action: {
            showingProfileEdit = true
        }) {
            Image(systemName: "pencil")
        }
    }
    
    private func createStarterSnail() {
        guard appState.snail == nil else { return }
        
        isCreatingSnail = true
        errorMessage = ""
        
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        guard let userLocation = locationManager.location?.coordinate else {
            isCreatingSnail = false
            errorMessage = "Unable to get your location. Please enable location services."
            return
        }
        
        // Generate a random location within 1000 miles
        let snailLocation = generateRandomLocationOnLand(within: 1609344, of: userLocation) // 1609344 meters = 1000 miles
        
        appState.snail = Snail(name: "Speedy", location: snailLocation, targetLocation: userLocation)
        
        isCreatingSnail = false
    }
    
    private func generateRandomLocationOnLand(within radius: Double, of center: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        // This is a simplified version. In a real app, you'd need to check if the location is on land.
        let radiusInDegrees = radius / 111000 // rough approximation
        
        let randomLatitude = center.latitude + .random(in: -radiusInDegrees...radiusInDegrees)
        let randomLongitude = center.longitude + .random(in: -radiusInDegrees...radiusInDegrees)
        
        return CLLocationCoordinate2D(latitude: randomLatitude, longitude: randomLongitude)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(AppState())
    }
}
