import Vapor

struct QueueResponseModel: Content {
    let data: QueueDataModel?
    let error: String?
}
