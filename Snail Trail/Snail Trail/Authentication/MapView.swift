import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = MapViewModel()
    @State private var showingSnailCreation = false
    @State private var selectedSnail: Snail?
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: appState.snails) { snail in
                MapAnnotation(coordinate: snail.location) {
                    SnailIconView(color: snail.color)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Color.white))
                        .onTapGesture {
                            selectedSnail = snail
                        }
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: viewModel.centerMapOnAllSnailsAndUser) {
                        Image(systemName: "map")
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .padding([.top, .trailing])
                }
                Spacer()
                if appState.canCreateFirstSnail() {
                    Button("Create First Snail") {
                        showingSnailCreation = true
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom)
                }
            }
        }
        .onAppear {
            viewModel.appState = appState  // Ensure viewModel has access to appState
            viewModel.checkIfLocationServicesIsEnabled()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            appState.updateSnailPositions()
        }
        .sheet(isPresented: $showingSnailCreation) {
            SnailCreationView()
        }
        .sheet(item: $selectedSnail) { snail in
            SnailDetailView(snail: snail)
        }
    }
}

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516, longitude: -121.891054),
                                               span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    weak var appState: AppState?
    private var locationManager: CLLocationManager?
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization()
        } else {
            print("Location services are disabled.")
        }
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("Location access is restricted or denied.")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.appState?.userLocation = latestLocation.coordinate
            self?.region = MKCoordinateRegion(center: latestLocation.coordinate,
                                              span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
    }
    
    func centerMapOnAllSnailsAndUser() {
        guard let appState = appState else { return }
        var coordinates = appState.snails.map { $0.location }
        if let userLocation = appState.userLocation {
            coordinates.append(userLocation)
        }
        
        guard !coordinates.isEmpty else { return }
        
        let minLat = coordinates.map { $0.latitude }.min() ?? 0
        let maxLat = coordinates.map { $0.latitude }.max() ?? 0
        let minLon = coordinates.map { $0.longitude }.min() ?? 0
        let maxLon = coordinates.map { $0.longitude }.max() ?? 0
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.5,
                                    longitudeDelta: (maxLon - minLon) * 1.5)
        
        region = MKCoordinateRegion(center: center, span: span)
    }
}

struct SnailDetailView: View {
    let snail: Snail
    
    var body: some View {
        VStack {
            Text(snail.name)
                .font(.title)
            SnailIconView(color: snail.color)
                .frame(width: 100, height: 100)
            Text("Speed: \(String(format: "%.2f", snail.speed * 2.23694)) mph")
            Text("Location: \(String(format: "%.4f", snail.location.latitude)), \(String(format: "%.4f", snail.location.longitude))")
        }
    }
}
