//
//  Token.swift
//  
//
//  Created by Ekaterina Grishina on 11/12/22.
//

import Vapor
import Fluent

final class Token: Model, Content {
    static let schema: String = "tokens"
    
    enum FieldKeys {
        static let userId: FieldKey = "userId"
        static let value: FieldKey = "value"
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: FieldKeys.value)
    var value: String
    
    @Parent(key: FieldKeys.userId)
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, value: String, userId: User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userId
    }
}

extension Token {
    
    static func generate(for user: User) throws -> Token {
        let random = [UInt8].random(count: 16).base64
        return try Token(value: random, userId: user.requireID())
    }
}

