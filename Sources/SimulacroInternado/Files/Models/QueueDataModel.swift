import Vapor

struct QueueDataModel: Content {
    let globalPosition: Int
    let studentsCount: Int
    let actualPosition: Int
    let remaining: Int
    let spots: [QueueSpotModel]
}
