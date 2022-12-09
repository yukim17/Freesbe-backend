import Fluent
import Vapor

final class Category: Model, Content {
    
    static let schema = "categories"
    
    enum FieldKeys {
        static let name: FieldKey = "name"
        static let description: FieldKey = "description"
        static let color: FieldKey = "color"
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: FieldKeys.name)
    var name: String
    
    @Field(key: FieldKeys.description)
    var description: String
    
    @Field(key: FieldKeys.color)
    var color: String
    
    @Children(for: \.$category)
    var events: [Event]
    
    init() {}
    
    init(id: UUID? = nil, name: String, description: String, color: String) {
        self.id = id
        self.name = name
        self.description = description
        self.color = color
    }
}
