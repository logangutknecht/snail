import SwiftUI
import CoreLocation

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var username: String = "User123"
    @State private var isCreatingSnail = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            Text("Welcome, \(username)!")
                .font(.title)
                .padding()
            
            if let snail = appState.snail {
                SnailIconView(color: snail.color)
                    .frame(width: 100, height: 100)
                    .padding()
                
                Text("Your snail: \(snail.name)")
                    .font(.headline)
            } else {
                Button("Create Starter Snail") {
                    createStarterSnail()
                }
                .disabled(isCreatingSnail)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
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
