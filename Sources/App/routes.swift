import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: CategoryController())
    try app.register(collection: EventController())
    try app.register(collection: UserController())
    try app.register(collection: ImperialController())
}
