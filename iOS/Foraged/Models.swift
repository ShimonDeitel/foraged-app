import Foundation

struct FindEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var location: String
    var quantity: String
    var season: String
    var idNotes: String
    var dateCreated: Date = Date()
}
