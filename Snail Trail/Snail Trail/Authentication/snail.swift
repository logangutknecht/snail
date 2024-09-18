import Foundation
import CoreLocation
import SwiftUI

class Snail: Identifiable, ObservableObject, Codable {
    let id: UUID
    @Published var name: String
    @Published var location: CLLocationCoordinate2D
    @Published var targetLocation: CLLocationCoordinate2D
    @Published var color: Color
    let speed: Double = 1.34112 // 3 miles per hour in meters per second
    
    enum CodingKeys: String, CodingKey {
        case id, name, location, targetLocation, color
    }
    
    init(id: UUID = UUID(), name: String, location: CLLocationCoordinate2D, targetLocation: CLLocationCoordinate2D, color: Color = .red) {
        self.id = id
        self.name = name
        self.location = location
        self.targetLocation = targetLocation
        self.color = color
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let locationDict = try container.decode([String: Double].self, forKey: .location)
        location = CLLocationCoordinate2D(latitude: locationDict["latitude"] ?? 0, longitude: locationDict["longitude"] ?? 0)
        let targetLocationDict = try container.decode([String: Double].self, forKey: .targetLocation)
        targetLocation = CLLocationCoordinate2D(latitude: targetLocationDict["latitude"] ?? 0, longitude: targetLocationDict["longitude"] ?? 0)
        let colorComponents = try container.decode([CGFloat].self, forKey: .color)
        color = Color(.sRGB, red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], opacity: colorComponents[3])
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(["latitude": location.latitude, "longitude": location.longitude], forKey: .location)
        try container.encode(["latitude": targetLocation.latitude, "longitude": targetLocation.longitude], forKey: .targetLocation)
        let colorComponents = color.components
        try container.encode([colorComponents.red, colorComponents.green, colorComponents.blue, colorComponents.opacity], forKey: .color)
    }
    
    func move(elapsedTime: TimeInterval) {
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

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)
        return (r, g, b, o)
    }
}
