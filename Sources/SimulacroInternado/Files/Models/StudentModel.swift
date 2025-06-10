import Vapor

struct StudentModel: Content {
    let id: String
    let position: Int
    let name: String
    let average: Double
    var spot: String? = nil
}
