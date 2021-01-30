//
//  File.swift
//  
//
//  Created by Joshua Homann on 1/17/21.
//

import Foundation

struct EndPoint {
  enum HTTPMethod: String {
    case post = "POST", get = "GET"
  }
  enum Parameters {
    case url([String: String]), body(Data)
  }
  var path: String
  var method: HTTPMethod
  var parameters: Parameters? = nil
  var requiresAuthentication = true
  var headers: [String: String] = Self.jsonHeaders
}

extension EndPoint {
  static let jsonHeaders = ["Content-Type": "application/json"]

  static func authenticatedHeaders(from token: String) -> [String: String] {
    var headers = Self.jsonHeaders
    headers["Authorization"] = "Bearer \(token)"
    return headers
  }

  static func getToken(email: String, password: String) -> Self {
    .init(
      path: "/oauth/token",
      method: .post,
      parameters: .body(
        (
          [
            "grant_type": "password",
            "client_id": "81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384",
            "client_secret": "c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3",
            "email": email,
            "password": password
          ]  as [String: Any]
        )
        .data
      ),
      requiresAuthentication: false
    )
  }
  
  static func getVehicles() -> Self {
    .init(path: "/api/1/vehicles", method: .get)
  }

  static func getVehicleData(id: Int) -> Self {
    .init(path: "/api/1/vehicles/\(id)/vehicle_data", method: .get)
  }

  static func unlock(id: Int) -> Self {
    .init(path: "/api/1/vehicles/\(id)/command/door_unlock", method: .post)
  }

  static func lock(id: Int) -> Self {
    .init(path: "/api/1/vehicles/\(id)/command/door_lock", method: .post)
  }

  static func honk(id: Int) -> Self {
    .init(path: "/api/1/vehicles/\(id)/command/honk_horn", method: .post)
  }

  static func flash(id: Int) -> Self {
    .init(path: "/api/1/vehicles/\(id)/command/flash_lights", method: .post)
  }

  static func toggleTrunk(id: Int) -> Self {
    .init(
      path: "/api/1/vehicles/\(id)/command/actuate_trunk",
      method: .post,
      parameters: .body(
        (["which_trunk": "rear"] as [String: Any]).data
      )
    )
  }

  static func toggleFrunk(id: Int) -> Self {
    .init(
      path: "/api/1/vehicles/\(id)/command/actuate_trunk",
      method: .post,
      parameters: .body(
        (["which_trunk": "front"] as [String: Any]).data
      )
    )
  }

  static func wake(id: Int) -> Self {
    .init(path: "/api/1/vehicles/(id)/wake_up", method: .post)
  }

}

private extension Dictionary where Key: StringProtocol, Value: Any {
  var data: Data {
    (try? JSONSerialization.data(withJSONObject: self, options: [])) ?? Data()
  }
}
