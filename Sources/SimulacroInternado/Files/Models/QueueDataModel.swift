import Vapor

struct QueueDataModel: Content {
    let studentID: String
    let position: Int
    let globalPosition: Int
    let studentsCount: Int
    let remaining: Int
    let seatsRemaining: Int
    let startTime: Double
    let spots: [QueueSpotModel]
}
