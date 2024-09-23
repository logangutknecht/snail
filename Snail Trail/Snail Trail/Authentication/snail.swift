import Foundation
import CoreLocation
import SwiftUI

class Snail: Identifiable, ObservableObject, Codable {
    let id: UUID
    @Published var name: String
    @Published var location: CLLocationCoordinate2D
    @Published var color: Color
    let speed: Double
    
    enum CodingKeys: String, CodingKey {
        case id, name, location, color, speed
    }
    
    init(id: UUID = UUID(), name: String, location: CLLocationCoordinate2D, color: Color = .red, speed: Double) {
        self.id = id
        self.name = name
        self.location = location
        self.color = color
        self.speed = speed
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        location = try container.decode(CLLocationCoordinate2D.self, forKey: .location)
        color = try container.decode(Color.self, forKey: .color)
        speed = try container.decode(Double.self, forKey: .speed)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(location, forKey: .location)
        try container.encode(color, forKey: .color)
        try container.encode(speed, forKey: .speed)
    }
    
    func move(elapsedTime: TimeInterval, targetLocation: CLLocationCoordinate2D) {
        let distance = speed * elapsedTime
        let bearing = calculateBearing(from: location, to: targetLocation)
        
        let earthRadius = 6371000.0 // Earth's radius in meters
        let angularDistance = distance / earthRadius
        
        let startLat = location.latitude * .pi / 180
        let startLon = location.longitude * .pi / 180
        
        let endLat = asin(sin(startLat) * cos(angularDistance) +
                          cos(startLat) * sin(angularDistance) * cos(bearing))
        
        let endLon = startLon + atan2(sin(bearing) * sin(angularDistance) * cos(startLat),
                                      cos(angularDistance) - sin(startLat) * sin(endLat))
        
        location = CLLocationCoordinate2D(latitude: endLat * 180 / .pi,
                                          longitude: endLon * 180 / .pi)
    }
    
    func calculateETA(to targetLocation: CLLocationCoordinate2D) -> TimeInterval {
        let distance = Snail.calculateDistance(from: location, to: targetLocation)
        return distance / speed
    }
    
    static func calculateDistance(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> Double {
        let earthRadius = 6371000.0 // Earth's radius in meters
        let dLat = (end.latitude - start.latitude) * .pi / 180
        let dLon = (end.longitude - start.longitude) * .pi / 180
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(start.latitude * .pi / 180) * cos(end.latitude * .pi / 180) *
                sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return earthRadius * c
    }
    
    private func calculateBearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> Double {
        let startLat = start.latitude * .pi / 180
        let startLon = start.longitude * .pi / 180
        let endLat = end.latitude * .pi / 180
        let endLon = end.longitude * .pi / 180
        
        let dLon = endLon - startLon
        
        let y = sin(dLon) * cos(endLat)
        let x = cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(dLon)
        
        return atan2(y, x)
    }
}

extension CLLocationCoordinate2D: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)
        let a = try container.decode(Double.self, forKey: .alpha)
        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        try container.encode(r, forKey: .red)
        try container.encode(g, forKey: .green)
        try container.encode(b, forKey: .blue)
        try container.encode(a, forKey: .alpha)
    }
}

