import SwiftUI
import GoogleMaps

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @Binding var isLoggedIn: Bool
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        ZStack {
            // Map Container
            GoogleMapViewContainer(
                viewModel: viewModel,
                showPath: viewModel.showMovementPath
            )
            .ignoresSafeArea()
            
            // Overlay Controls
            VStack {
                // Top Bar
                HStack {
                    // Previous Logins Button
                    Button(action: { viewModel.showPreviousLogins.toggle() }) {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Logout Button
                    Button(action: { showLogoutConfirmation = true }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                // Bottom Controls
                VStack(spacing: 20) {
                    // Movement Path Toggle
                    Toggle("Show Movement Path", isOn: Binding(
                        get: { viewModel.showMovementPath },
                        set: { newValue in
                            Task {
                                await viewModel.toggleMovementPath()
                            }
                        }
                    ))
                    .tint(.blue)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(Color.black)
                    .cornerRadius(12)
                    
                    // Tracking Button
                    Button(action: {
                        Task {
                            await viewModel.toggleTracking()
                        }
                    }) {
                        Text(viewModel.isTrackingEnabled ? "Stop Tracking" : "Start Tracking")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(viewModel.isTrackingEnabled ? Color.red : Color.green)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .padding(.bottom, 70)
            }
            
            // Previous Logins Sheet
            .sheet(isPresented: $viewModel.showPreviousLogins) {
                PreviousLoginsView(logins: viewModel.previousLogins)
            }
        }
        // Logout Confirmation
        .alert("Logout", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                Task {
                    do {
                        try await viewModel.logout()
                        isLoggedIn = false
                    } catch {
                        // Handle error
                    }
                }
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        // Error Alert
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}

// MARK: - Google Maps View Container
struct GoogleMapViewContainer: UIViewRepresentable {
    let viewModel: MapViewModel
    let showPath: Bool
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = viewModel.getInitialMapRegion()
        let mapView = GMSMapView(frame: .zero, camera: camera)
        mapView.delegate = context.coordinator
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.mapType = .normal
        mapView.settings.compassButton = true
        mapView.settings.rotateGestures = true
        mapView.settings.tiltGestures = true
        mapView.settings.zoomGestures = true
        mapView.settings.scrollGestures = true
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        // Update current location marker
        if let location = viewModel.currentLocation {
            print("Updating location marker at: \(location.latitude), \(location.longitude)")
            
            // Update camera position
            mapView.animate(to: GMSCameraPosition(
                latitude: location.latitude,
                longitude: location.longitude,
                zoom: mapView.camera.zoom
            ))
            
            // Update custom marker
            context.coordinator.updateLocationMarker(at: location, on: mapView)
        } else {
            print("No current location available")
        }
        
        // Update path
        context.coordinator.updatePath(on: mapView, showPath: showPath, path: viewModel.getMapPath())
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    class Coordinator: NSObject, GMSMapViewDelegate {
        let viewModel: MapViewModel
        private var pathPolyline: GMSPolyline?
        private var locationMarker: GMSMarker?
        
        init(viewModel: MapViewModel) {
            self.viewModel = viewModel
            super.init()
        }
        
        func updateLocationMarker(at location: CLLocationCoordinate2D, on mapView: GMSMapView) {
            print("Creating new marker at location: \(location.latitude), \(location.longitude)")
            
            locationMarker?.map = nil
            
            let marker = GMSMarker(position: location)
            marker.icon = UIImage(named: "pin-icon")
            marker.map = mapView
            locationMarker = marker
        }
        
        // Add delegate method to handle location updates
        @MainActor func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
            if let location = viewModel.currentLocation {
                updateLocationMarker(at: location, on: mapView)
            }
        }
        
        // Add delegate method to handle location button taps
        @MainActor func didTapMyLocationButton(forMapView mapView: GMSMapView) -> Bool {
            if let location = viewModel.currentLocation {
                updateLocationMarker(at: location, on: mapView)
                return true
            }
            return false
        }
        
        func updatePath(on mapView: GMSMapView, showPath: Bool, path: GMSPath?) {
            // Remove existing path
            pathPolyline?.map = nil
            
            // Add new path if needed
            if showPath, let path = path {
                let polyline = GMSPolyline(path: path)
                polyline.strokeColor = .blue
                polyline.strokeWidth = 3
                polyline.map = mapView
                pathPolyline = polyline
            }
        }
        
        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            // Handle tap if needed
        }
    }
}

// MARK: - Previous Logins View
struct PreviousLoginsView: View {
    let logins: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(logins, id: \.self) { email in
                Text(email)
            }
            .navigationTitle("Previous Logins")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MapView(isLoggedIn: .constant(true))
} 
