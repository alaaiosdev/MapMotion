import Foundation
import CoreLocation
import GoogleMaps
import Combine

@MainActor
final class MapViewModel: ObservableObject {
    @Published var isTrackingEnabled = false
    @Published var showMovementPath = false
    @Published var showPreviousLogins = false
    @Published var previousLogins: [String] = []
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var dailyLocations: [LocationData] = []
    @Published var errorMessage: String?
    
    private let locationService: LocationServiceProtocol
    private let authService: AuthenticationServiceProtocol
    private var currentUser: User?
    
    init(
        locationService: LocationServiceProtocol = LocationService(),
        authService: AuthenticationServiceProtocol = AuthenticationService()
    ) {
        self.locationService = locationService
        self.authService = authService
        self.currentUser = authService.getCurrentUser()

        if let locationService = locationService as? LocationService {
            locationService.locationUpdateHandler = { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let location):
                    print("Received location update: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    self.currentLocation = location.coordinate
                case .failure(let error):
                    print("Location update failed: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
        
        Task {
            await loadPreviousLogins()
        }
    }
    
    func toggleTracking() async {
        isTrackingEnabled.toggle()
        
        if isTrackingEnabled {
            do {
                print("Starting location tracking")
                try await locationService.startTracking()
            } catch {
                print("Failed to start tracking: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
                isTrackingEnabled = false
            }
        } else {
            print("Stopping location tracking")
            locationService.stopTracking()
        }
    }
    
    func toggleMovementPath() async {
        showMovementPath.toggle()
        
        if showMovementPath {
            await loadDailyLocations()
        }
    }
    
    func logout() async throws {
        locationService.stopTracking()
        try authService.signOut()
    }
    
    func loadPreviousLogins() async {
        do {
            previousLogins = try await authService.getPreviousLogins()
        } catch {
            errorMessage = "Failed to load previous logins"
        }
    }
    
    private func loadDailyLocations() async {
        guard let userId = currentUser?.id else { return }
        
        do {
            dailyLocations = try await locationService.getDailyLocations(for: userId)
        } catch {
            errorMessage = "Failed to load location history"
        }
    }
    
    // MARK: - Map Helper Methods
    
    func getMapPath() -> GMSPath? {
        guard !dailyLocations.isEmpty else { return nil }
        
        let path = GMSMutablePath()
        dailyLocations.forEach { location in
            path.add(location.coordinate)
        }
        return path
    }
    
    func getInitialMapRegion() -> GMSCameraPosition {
        if let location = currentLocation {
            return GMSCameraPosition(
                latitude: location.latitude,
                longitude: location.longitude,
                zoom: 15
            )
        } else {
            // Default to a reasonable location
            return GMSCameraPosition(
                latitude: 37.7749,
                longitude: -122.4194,
                zoom: 12
            )
        }
    }
    
    func updateCurrentLocation(_ location: CLLocationCoordinate2D) {
        currentLocation = location
    }
}
