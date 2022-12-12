//
//  ImperialController.swift
//  
//
//  Created by Ekaterina Grishina on 11/12/22.
//

import Vapor
import Fluent
import ImperialDiscord

struct ImperialController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        guard let discordCallbackURL =
                Environment.get("DISCORD_CALLBACK_URL") else {
            fatalError("Discord callback URL not set")
        }
        try routes.oAuth(
            from: Discord.self,
            authenticate: "login-discord",
            callback: discordCallbackURL,
            scope: ["applications.commands"],
            completion: processDiscordLogin
        )
        
        routes.get("iOS", "login-discord", use: discordLogin)
    }
    
    func processDiscordLogin(req: Request, token: String) throws -> EventLoopFuture<ResponseEncodable> {
        try Discord
            .getUser(on: req)
            .flatMap { userInfo in
                User
                    .query(on: req.db)
                    .filter(\.$username == userInfo.email)
                    .first()
                    .flatMap { foundUser in
                        guard let existingUser = foundUser else {
                            let user = User(
                                name: userInfo.name,
                                surname: "",
                                username: userInfo.email
                            )
                            return user.save(on: req.db).flatMap {
//                                req.session.authenticate(user)
                                return generateRedirect(on: req, for: user)
                            }
                        }
//                        req.session.authenticate(existingUser)
                        return generateRedirect(on: req, for: existingUser)
                    }
            }
    }
    
    func discordLogin(_ req: Request) -> Response {
        req.session.data["oauth_login"] = "iOS"
        return req.redirect(to: "/login-discord")
    }
    
    func generateRedirect(on req: Request, for user: User)
    -> EventLoopFuture<ResponseEncodable> {
        let redirectURL: EventLoopFuture<String>
        // 2
        if req.session.data["oauth_login"] == "iOS" {
            do { // 3
                let token = try Token.generate(for: user)
                // 4
                redirectURL = token.save(on: req.db).map {
                    "freesbe://auth?token=\(token.value)"
                }
                // 5
            } catch {
                return req.eventLoop.future(error: error)
            }
        } else { // 6
            redirectURL = req.eventLoop.future("/")
        }
        // 7
        req.session.data["oauth_login"] = nil
        // 8
        return redirectURL.map { url in
            req.redirect(to: url)
        }
    }
}

struct DiscordUserInfo: Content {
    let email: String
    let name: String
}

extension Discord {
    // 1
    static func getUser(on request: Request) throws -> EventLoopFuture<DiscordUserInfo> {
        // 2
        var headers = HTTPHeaders()
        headers.bearerAuthorization =
        try BearerAuthorization(token: request.accessToken())
        // 3
        let googleAPIURL: URI =
        "https://www.googleapis.com/oauth2/v1/userinfo?alt=json"
        // 4
        return request
            .client
            .get(googleAPIURL, headers: headers)
            .flatMapThrowing { response in
                // 5
                guard response.status == .ok else {
                    // 6
                    if response.status == .unauthorized {
                        throw Abort.redirect(to: "/login-google")
                    } else {
                        throw Abort(.internalServerError)
                    }
                }
                // 7
                return try response.content
                    .decode(DiscordUserInfo.self)
            }
    }
}
