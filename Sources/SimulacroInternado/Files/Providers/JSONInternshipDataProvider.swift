import Foundation
import Vapor

struct JSONInternshipDataProvider: InternshipDataSource {
    let app: Application

    func fetchSpots() async throws -> [QueueSpotModel] {
        let url = URL(fileURLWithPath: app.directory.workingDirectory)
            .appendingPathComponent("Resources")
            .appendingPathComponent("Data")
            .appendingPathComponent("spots.json")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([QueueSpotModel].self, from: data)
    }

    func fetchStudents() async throws -> [StudentModel] {
        let url = URL(fileURLWithPath: app.directory.workingDirectory)
            .appendingPathComponent("Resources")
            .appendingPathComponent("Data")
            .appendingPathComponent("students.json")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([StudentModel].self, from: data)
    }
}
