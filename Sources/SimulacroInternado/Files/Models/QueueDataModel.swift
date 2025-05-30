import Vapor

struct QueueDataModel: Content {
    let studentID: String
    let globalPosition: Int
    let studentsCount: Int
    let actualPosition: Int
    let remaining: Int
    let startTime: Double
    let spots: [QueueSpotModel]
}
