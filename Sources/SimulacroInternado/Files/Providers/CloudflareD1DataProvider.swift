import Foundation
import Vapor

struct CloudflareD1DataProvider: InternshipDataSource {
    let client: any Client
    let baseURL: String
    let databaseID: String
    let authToken: String

    func fetchSpots() async throws -> [QueueSpotModel] {
        try await query(sql: "SELECT * FROM spots;", params: [], type: [QueueSpotModel].self)
    }

    func fetchStudents() async throws -> [StudentModel] {
        try await query(sql: "SELECT * FROM students ORDER BY average DESC;", params: [], type: [StudentModel].self)
    }

    private func query<T: Content>(sql: String,
                                   params: [String]? = nil,
                                   type: T.Type) async throws -> T {
        let payload = QueryPayload(sql: sql, params: params ?? [])

        let response = try await client.post("\(baseURL)/database/\(databaseID)/query") { req in
            try req.content.encode(payload)
            req.headers.contentType = .json
            req.headers.bearerAuthorization = BearerAuthorization(token: authToken)
        }

        guard response.status == .ok else {
            throw Abort(.badRequest, reason: "Query failed: \(response.status)")
        }
        return try response.content.decode(QueryResponse<T>.self).result.first!.results!
    }

    struct QueryResponse<T: Content>: Codable {
        let result: [QueryResponseResult<T>]
        let success: Bool
    }

    struct QueryResponseResult<T: Content>: Codable {
        let results: T?
        let success: Bool
    }

    struct QueryPayload: Content {
        let sql: String
        let params: [String]
    }
}

