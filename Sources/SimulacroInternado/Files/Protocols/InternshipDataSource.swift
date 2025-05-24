import Foundation

protocol InternshipDataSource {
    func fetchSpots() async throws -> [QueueSpotModel]
    func fetchStudents() async throws -> [StudentModel]
}
