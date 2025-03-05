import Foundation
import FirebaseAuth
import CoreLocation
import FirebaseFirestore

enum LocationError: Error {
    case locationServicesDisabled
    case authorizationDenied
    case failedToStartUpdating
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .locationServicesDisabled:
            return "Location services are disabled"
        case .authorizationDenied:
            return "Location access was denied"
        case .failedToStartUpdating:
            return "Failed to start location updates"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

protocol LocationServiceProtocol {
    var isTracking: Bool { get }
    var currentLocation: CLLocation? { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    
    func requestAuthorization() async throws
    func startTracking() async throws
    func stopTracking()
    func getDailyLocations(for userId: String) async throws -> [LocationData]
}

final class LocationService: NSObject, LocationServiceProtocol {
    private let locationManager = CLLocationManager()
    private let db = Firestore.firestore()
    var locationUpdateHandler: ((Result<CLLocation, Error>) -> Void)?
    
    private(set) var isTracking = false
    private(set) var currentLocation: CLLocation?
    
    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    func requestAuthorization() async throws {
        guard CLLocationManager.locationServicesEnabled() else {
            throw LocationError.locationServicesDisabled
        }
        
        locationManager.requestAlwaysAuthorization()

        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                switch self.locationManager.authorizationStatus {
                case .authorizedAlways, .authorizedWhenInUse:
                    continuation.resume()
                case .denied, .restricted:
                    continuation.resume(throwing: LocationError.authorizationDenied)
                case .notDetermined:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if self.locationManager.authorizationStatus == .notDetermined {
                            continuation.resume(throwing: LocationError.authorizationDenied)
                        } else {
                            continuation.resume()
                        }
                    }
                @unknown default:
                    continuation.resume(throwing: LocationError.unknown(NSError(domain: "", code: -1)))
                }
            }
        }
    }
    
    func startTracking() async throws {
        guard CLLocationManager.locationServicesEnabled() else {
            throw LocationError.locationServicesDisabled
        }
        
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            isTracking = true
        case .denied, .restricted:
            throw LocationError.authorizationDenied
        case .notDetermined:
            try await requestAuthorization()
            locationManager.startUpdatingLocation()
            isTracking = true
        @unknown default:
            throw LocationError.unknown(NSError(domain: "", code: -1))
        }
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        isTracking = false
    }
    
    func getDailyLocations(for userId: String) async throws -> [LocationData] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let snapshot = try await db.collection("locations")
            .whereField("user_id", isEqualTo: userId)
            .whereField("timestamp", isGreaterThanOrEqualTo: startOfDay)
            .whereField("timestamp", isLessThan: endOfDay)
            .order(by: "timestamp")
            .getDocuments()
        
        return try snapshot.documents.map { document in
            let data = document.data()
            return try LocationData(
                id: document.documentID,
                userId: data["user_id"] as! String,
                latitude: data["latitude"] as! Double,
                longitude: data["longitude"] as! Double,
                timestamp: (data["timestamp"] as! Timestamp).dateValue(),
                accuracy: data["accuracy"] as! Double
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10 // Update every 10 meters
    }
    
    private func saveLocation(_ location: CLLocation, for userId: String) async throws {
        let locationData = LocationData.create(userId: userId, location: location)
        try await db.collection("locations").document(locationData.id).setData([
            "user_id": locationData.userId,
            "latitude": locationData.latitude,
            "longitude": locationData.longitude,
            "timestamp": locationData.timestamp,
            "accuracy": locationData.accuracy
        ])
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        
        // Save location if accuracy is good enough
        if location.horizontalAccuracy <= 20 {
            if let userId = Auth.auth().currentUser?.uid {
                Task {
                    try? await saveLocation(location, for: userId)
                }
            }
        }

        locationUpdateHandler?(.success(location))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationUpdateHandler?(.failure(error))
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            if isTracking {
                manager.startUpdatingLocation()
            }
        case .denied, .restricted:
            stopTracking()
            locationUpdateHandler?(.failure(LocationError.authorizationDenied))
        default:
            break
        }
    }
} 
