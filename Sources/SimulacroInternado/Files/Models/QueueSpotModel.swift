import Vapor

struct QueueSpotModel: Content {
    var id: String
    var name: String
    var location: String
    var institution: String
    var scholarship: String
    var seats: Int
}
