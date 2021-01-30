import Combine
import Foundation
import Security

public final class TeslaOwnerAPI {
  public var token: Token?

  public enum Command {
    case wake, flash, honk, lock, unlock, trunk, frunk
  }
  
  public enum Error: Swift.Error {
    case invalidURL, networkError(Swift.Error), decodingError(Swift.Error), unauthenticated, server(message: String)
    public var message: String {
      switch self {
      case let .server(message): return message
      case let .networkError(error): return error.localizedDescription
      case let .decodingError(error): return error.localizedDescription
      case .invalidURL: return "Invalid URL"
      case .unauthenticated: return "Unauthenticated"
      }
    }
    public var isVehicleUnavailableError: Bool {
      if case let .server(message) = self {
        return message.starts(with: "vehicle unavailable")
      }
      return false
    }
  }

  private enum Constant {
    static let scheme = "https"
    static let host = "owner-api.teslamotors.com"
  }

  private static let jsonDecoder = JSONDecoder()

  public init() { }

  public func getVehicles() -> AnyPublisher<[VehiclesResponse.Vehicle], Error> {
    request(
      VehiclesResponse.self,
      from: .getVehicles(),
      transform: \.vehicles
    )
  }

  public func getVehicle(id: Int) -> AnyPublisher<VehicleDataContainer.Response, Error> {
    request(
      VehicleDataContainer.self,
      from: .getVehicleData(id: id),
      transform: \.response
    )
  }

  public func execute(command: Command, for vehicleID: Int) -> AnyPublisher<Bool, Error> {
    switch command {
    case .flash:
      return request(CommandContainer.self, from: .flash(id: vehicleID), transform: \.response.result)
    case .honk:
      return request(CommandContainer.self, from: .honk(id: vehicleID), transform: \.response.result)
    case .wake:
      return request(CommandContainer.self, from: .wake(id: vehicleID), transform: \.response.result)
    case .lock:
      return request(CommandContainer.self, from: .lock(id: vehicleID), transform: \.response.result)
    case .unlock:
      return request(CommandContainer.self, from: .unlock(id: vehicleID), transform: \.response.result)
    case .trunk:
      return request(CommandContainer.self, from: .toggleTrunk(id: vehicleID), transform: \.response.result)
    case .frunk:
      return request(CommandContainer.self, from: .toggleFrunk(id: vehicleID), transform: \.response.result)
    }
  }

  public func getToken(for email: String, password: String) -> AnyPublisher<Token, Error> {
    request(Token.self, from: .getToken(email: email, password: password))
  }

  private func makeRequest(from endPoint: EndPoint) throws -> URLRequest {
    var components = URLComponents()
    components.scheme = Constant.scheme
    components.host = Constant.host
    components.path = endPoint.path
    if case let .url(parameters) = endPoint.parameters {
      components.queryItems = parameters.map { key, value in
        .init(name: key, value: value)
      }
    }
    guard let url = components.url else {
      throw Error.invalidURL
    }
    var request = URLRequest(url: url)
    request.httpMethod = endPoint.method.rawValue
    endPoint.headers.forEach { key, value in
      request.setValue(value, forHTTPHeaderField: key)
    }
    if case let .body(data) = endPoint.parameters {
      print(String(data: data, encoding: .utf8))
      request.httpBody = data
    }
    return request
  }

  private func request<SomeDecodable: Decodable>(
    _ decoded: SomeDecodable.Type,
    from endPoint: EndPoint
  ) -> AnyPublisher<SomeDecodable, Error> {
    request(decoded.self, from: endPoint, transform: { $0 })
  }

  private func request<SomeDecodable: Decodable, Output>(
    _ decoded: SomeDecodable.Type,
    from endPoint: EndPoint,
    transform: @escaping (SomeDecodable) -> Output
  ) -> AnyPublisher<Output, Error> {
    guard var request = try? makeRequest(from: endPoint) else {
      return Fail(error: .invalidURL).eraseToAnyPublisher()
    }
    if endPoint.requiresAuthentication {
      guard let token = token?.accessToken else {
        return Fail(error: .unauthenticated).eraseToAnyPublisher()
      }
      EndPoint.authenticatedHeaders(from: token).forEach { key, value in
        request.addValue(value, forHTTPHeaderField: key)
      }
    }
    return URLSession
      .shared
      .dataTaskPublisher(for: request)
      .mapError(Error.networkError(_:))
      .map(\.data)
      .handleEvents(receiveOutput: { data in
        print(endPoint.path)
        print(String(data: data, encoding: .utf8) ?? "")
      }, receiveCompletion: { completion in
        switch completion {
        case .finished: return
        case let .failure(error):
          print(endPoint.path)
          print("ERROR:\(error.localizedDescription)")
        }
      })
      .decode(type: Either<SomeDecodable, ErrorMessage>.self, decoder: Self.jsonDecoder)
      .mapError(Error.decodingError(_:))
      .map { either -> AnyPublisher<SomeDecodable, Error> in
        switch either {
        case let .left(someDecodable): return Just(someDecodable).setFailureType(to: Error.self).eraseToAnyPublisher()
        case let .right(errorMessage): return Fail(error: Error.server(message: errorMessage.message)).eraseToAnyPublisher()
        }
      }
      .switchToLatest()
      .map(transform)
      .eraseToAnyPublisher()
  }
}

enum Either<Left, Right> {
  case left(Left), right(Right)
}

extension Either: Decodable where Left: Decodable, Right: Decodable {
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(Left.self) {
      self = .left(value)
    } else if let value = try? container.decode(Right.self) {
      self = .right(value)
    } else {
      throw DecodingError.typeMismatch(Self.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for \(String(describing:Self.self))"))
    }
  }
}
