import Foundation

struct Spot: Codable, Equatable, Identifiable {
    var id: String
    var name: String
    var location: String
    var isTaken: Bool
}
