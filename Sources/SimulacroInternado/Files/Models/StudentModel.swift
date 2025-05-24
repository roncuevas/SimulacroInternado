import Vapor

struct StudentModel: Content {
    let id: String
    let average: Double
    var spot: String? = nil
}
