import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = MapViewModel()
    @State private var showingSnailEdit = false
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: [appState.snail].compactMap { $0 }) { snail in
                MapAnnotation(coordinate: snail.location) {
                    SnailIconView(color: snail.color)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(Color.white))
                        .onTapGesture {
                            showingSnailEdit = true
                        }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .accentColor(Color(.systemPink))
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.centerMapOnAllSnailsAndUser(snails: [appState.snail].compactMap { $0 })
                    }) {
                        Image(systemName: "map")
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .padding([.top, .trailing])
                }
                Spacer()
            }
        }
        .onAppear {
            viewModel.checkIfLocationServicesIsEnabled()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            viewModel.updateSnailPosition(snail: $appState.snail)
        }
        .onChange(of: viewModel.userLocation) { newLocation in
            if let newLocation = newLocation, var snail = appState.snail {
                snail.targetLocation = newLocation
                appState.snail = snail
                appState.saveSnail()
            }
        }
        .sheet(isPresented: $showingSnailEdit) {
            if let snail = appState.snail {
                SnailEditView(snail: snail, isPresented: $showingSnailEdit)
            }
        }
    }
}

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516, longitude: -121.891054),
                                               span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @Published var userLocation: CLLocationCoordinate2D?
    
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
        case .restricted:
            print("Your location is restricted likely due to parental controls.")
        case .denied:
            print("You have denied this app location permission. Go into settings to change it.")
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
        
        DispatchQueue.main.async {
            self.userLocation = latestLocation.coordinate
            self.region = MKCoordinateRegion(center: latestLocation.coordinate,
                                             span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
    }
    
    func updateSnailPosition(snail: Binding<Snail?>) {
        guard var snailUnwrapped = snail.wrappedValue else { return }
        snailUnwrapped.move(elapsedTime: 1)
        snail.wrappedValue = snailUnwrapped
    }
    
    func centerMapOnAllSnailsAndUser(snails: [Snail]) {
        var coordinates = snails.map { $0.location }
        if let userLocation = userLocation {
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

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView().environmentObject(AppState())
    }
}
