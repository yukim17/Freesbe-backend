import Fluent
import Vapor

struct CategoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let categoriesRoutes = routes.grouped("categories")
        categoriesRoutes.get(use: index)
        categoriesRoutes.post("create", use: create)
    }

    func index(req: Request) async throws -> [Category] {
        try await Category.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> Category {
        let category = try req.content.decode(Category.self)
        try await category.save(on: req.db)
        return category
    }
}
