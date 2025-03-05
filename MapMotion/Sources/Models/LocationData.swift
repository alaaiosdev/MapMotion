import Foundation
import CoreLocation

struct LocationData: Codable, Identifiable {
    let id: String
    let userId: String
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let accuracy: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case latitude
        case longitude
        case timestamp
        case accuracy
    }
}

// MARK: - LocationData Creation
extension LocationData {
    static func create(userId: String, location: CLLocation) -> LocationData {
        LocationData(
            id: UUID().uuidString,
            userId: userId,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: location.timestamp,
            accuracy: location.horizontalAccuracy
        )
    }
}

// MARK: - CLLocationCoordinate2D Conversion
extension LocationData {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
