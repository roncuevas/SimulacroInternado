import Foundation
import Vapor

final class InternshipQueueManager: @unchecked Sendable {
    private(set) var students: [StudentModel] = []
    private(set) var queue: [StudentModel] = []
    private(set) var spots: [QueueSpotModel] = []
    private(set) var selectedStudents: [StudentModel] = []
    private(set) var selectedSpots: [QueueSpotModel] = []
    private var connections: [String: WebSocket] = [:]
    private let dataProvider: any InternshipDataSource

    init(dataProvider: any InternshipDataSource) async throws {
        self.dataProvider = dataProvider
        self.spots = try await dataProvider.fetchSpots()
        self.students = try await dataProvider.fetchStudents()

        self.spots.sort { $0.name > $1.name }
        self.students.sort { $0.position < $1.position }
        self.queue = students
    }

    func addToQueue(studentID: String, ws: WebSocket) {
        connections[studentID] = ws
    }

    func canJoin(studentID: String) -> Bool {
        return students.contains(where: { $0.id == studentID })
    }

    func canPick(studentID: String) -> Bool {
        return queue.contains(where: { $0.id == studentID })
    }

    func getStudent(studentID: String) -> StudentModel? {
        return queue.first(where: { $0.id == studentID })
    }

    func getSelectedStudent(studentID: String) -> StudentModel? {
        return selectedStudents.first(where: { $0.id == studentID })
    }

    func getGeneralPosition(studentID: String) -> Int {
        return (students.firstIndex(where: { $0.id == studentID }) ?? 9999) + 1
    }

    func register(studentID: String, position: Int, name: String, average: Double) {
        if !queue.contains(where: { $0.id == studentID }) {
            let student = StudentModel(
                id: studentID,
                position: position,
                name: name,
                average: average
            )
            queue.append(student)
        }
    }

    func removeFromQueue(studentID: String) throws {
        let student = getStudent(studentID: studentID)
        selectedStudents.append(student!)
        queue.removeAll { $0.id == studentID }
    }

    func removeFromConnections(studentID: String) {
        connections[studentID]?.close(promise: nil)
        connections.removeValue(forKey: studentID)
    }

    func selectSpot(for studentID: String, spotID: String) throws {
        guard queue.first?.id == studentID
        else { throw NSError(domain: "selectSpot", code: 404, userInfo: ["error": "Student not found"]) }
        guard let spotIndex = spots.firstIndex(where: { $0.id == spotID && $0.seats != 0 })
        else { throw NSError(domain: "selectSpot", code: 404, userInfo: ["error": "Spot not found"]) }

        spots[spotIndex].seats -= 1
        queue[0].spot = spots[spotIndex].name
        try removeFromQueue(studentID: studentID)
        removeFromConnections(studentID: studentID)
        updateAll()
    }

    func sendError(_ text: String, ws: WebSocket) {
        let response = QueueResponseModel(data: nil, error: text)
        encodeAndSend(response: response, ws: ws)
    }

    func getSpots(index: Int, removeSelected: Bool) -> [QueueSpotModel] {
        if removeSelected {
            return spots.filter { $0.seats > 0 }
        }
        return spots
    }

    func updateAll() {
        for (id, ws) in connections {
            if let index = queue.firstIndex(where: { $0.id == id }) {
                let data = QueueDataModel(
                    studentID: id,
                    position: index + 1,
                    globalPosition: getGeneralPosition(studentID: id),
                    studentsCount: students.count,
                    remaining: index,
                    seatsRemaining: spots.reduce(0) { $0 + $1.seats },
                    startTime: Date.now.timeIntervalSince1970,
                    spots: getSpots(index: index, removeSelected: index == 0))
                let response = QueueResponseModel(data: data, error: nil)
                encodeAndSend(response: response, ws: ws)
            }
        }
    }

    func encodeAndSend(response: QueueResponseModel, ws: WebSocket) {
        if let encoded = try? JSONEncoder().encode(response),
           let json = String(data: encoded, encoding: .utf8) {
            ws.send(json)
        }
    }
}
