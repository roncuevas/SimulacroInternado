import Foundation
import Vapor

struct SpotModel: Content {
    var id: String
    var name: String
    var location: String
    var isTaken: Bool
}
