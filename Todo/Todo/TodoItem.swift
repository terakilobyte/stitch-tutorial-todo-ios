import MongoSwift

/// A todo item from a MongoDB document
struct TodoItem: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id"
        case ownerId = "owner_id"
        case task, checked
    }
    
    let id: ObjectId
    let ownerId: String
    let task: String
    
    var checked: Bool {
        didSet {
            itemsCollection.updateOne(
                filter: ["_id": id],
                update: ["$set": [CodingKeys.checked.rawValue: checked] as Document],
                options: nil) { _ in
                    
            }
        }
    }
}

