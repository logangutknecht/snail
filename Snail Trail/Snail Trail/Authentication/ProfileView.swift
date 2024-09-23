import SwiftUI
import CoreLocation

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingProfileEdit = false
    @State private var showingSnailCreation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    profileHeader
                    snailsList
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarItems(trailing: editButton)
        }
        .sheet(isPresented: $showingProfileEdit) {
            ProfileEditView(profile: $appState.userProfile)
        }
        .sheet(isPresented: $showingSnailCreation) {
            SnailCreationView()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            appState.updateSnailPositions()
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
    
    private var snailsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Your Snails")
                    .font(.headline)
                Spacer()
                Button(action: {
                    showingSnailCreation = true
                }) {
                    Image(systemName: "plus")
                }
            }
            
            ForEach(appState.snails) { snail in
                SnailRowView(snail: snail)
            }
        }
    }
    
    private var editButton: some View {
        Button(action: {
            showingProfileEdit = true
        }) {
            Image(systemName: "pencil")
        }
    }
}

struct SnailRowView: View {
    @ObservedObject var snail: Snail
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            SnailIconView(color: snail.color)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading) {
                Text(snail.name)
                    .font(.headline)
                Text("ETA: \(formatETA())")
                    .font(.subheadline)
                Text("Location: \(formatCoordinate(snail.location))")
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func formatETA() -> String {
        guard let userLocation = appState.userLocation else { return "Unknown" }
        let eta = snail.calculateETA(to: userLocation)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: eta) ?? "Unknown"
    }
    
    private func formatCoordinate(_ coordinate: CLLocationCoordinate2D) -> String {
        return String(format: "%.4f, %.4f", coordinate.latitude, coordinate.longitude)
    }
}


struct SnailCreationView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var snailName = ""
    @State private var snailColor = Color.red
    @State private var snailSpeed = 1.34112 // Default speed (3 mph in m/s)
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Snail Details")) {
                    TextField("Name", text: $snailName)
                    ColorPicker("Color", selection: $snailColor)
                    if !appState.canCreateFirstSnail() {
                        Slider(value: $snailSpeed, in: 0.44704...4.4704) // 1 mph to 10 mph in m/s
                        Text("Speed: \(String(format: "%.2f", snailSpeed * 2.23694)) mph") // Convert m/s to mph for display
                    }
                }
                
                if !appState.canCreateFirstSnail() {
                    Section(header: Text("Purchase Information")) {
                        Text("Cost: $\(String(format: "%.2f", calculateCost()))")
                        Text("Your Balance: $\(String(format: "%.2f", appState.userBalance))")
                    }
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(appState.canCreateFirstSnail() ? "Create First Snail" : "Purchase New Snail")
            .navigationBarItems(leading: cancelButton, trailing: createButton)
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var createButton: some View {
        Button(appState.canCreateFirstSnail() ? "Create" : "Purchase") {
            createOrPurchaseSnail()
        }
        .disabled(snailName.isEmpty)
    }
    
    private func calculateCost() -> Double {
        guard let userLocation = appState.userLocation else { return 0 }
        let snailLocation = generateRandomLocation(near: userLocation)
        let distance = Snail.calculateDistance(from: userLocation, to: snailLocation)
        return appState.calculateSnailCost(speed: snailSpeed, distance: distance)
    }
    
    private func createOrPurchaseSnail() {
        guard let userLocation = appState.userLocation else {
            errorMessage = "Unable to get your location."
            return
        }
        
        let snailLocation = generateRandomLocation(near: userLocation)
        
        if appState.canCreateFirstSnail() {
            let newSnail = Snail(name: snailName, location: snailLocation, color: snailColor, speed: snailSpeed)
            appState.snails.append(newSnail)
            appState.saveSnails()
            presentationMode.wrappedValue.dismiss()
        } else {
            if appState.purchaseSnail(name: snailName, color: snailColor, speed: snailSpeed, location: snailLocation) {
                presentationMode.wrappedValue.dismiss()
            } else {
                errorMessage = "Insufficient funds to purchase this snail."
            }
        }
    }
    
    private func generateRandomLocation(near location: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let latDelta = Double.random(in: -0.1...0.1)
        let lonDelta = Double.random(in: -0.1...0.1)
        return CLLocationCoordinate2D(latitude: location.latitude + latDelta,
                                      longitude: location.longitude + lonDelta)
    }
}

