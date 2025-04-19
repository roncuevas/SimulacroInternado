import Foundation

protocol InternshipDataSource {
    func fetchSpots() async throws -> [SpotModel]
    func fetchStudents() async throws -> [StudentModel]
}
