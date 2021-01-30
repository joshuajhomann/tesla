//
//  File.swift
//  
//
//  Created by Joshua Homann on 1/17/21.
//

import Foundation

public struct ErrorMessage: Codable {
  public var message: String
  public enum CodingKeys: String, CodingKey {
    case message = "error"
  }
}

// MARK: - Token

public struct Token: Codable {
  public var accessToken, tokenType: String
  public var expiresIn: Int
  public var refreshToken: String
  public var createdAt: Int

  public enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case tokenType = "token_type"
    case expiresIn = "expires_in"
    case refreshToken = "refresh_token"
    case createdAt = "created_at"
  }
}

// MARK: - VehiclesResponse
public struct VehiclesResponse: Codable {
  public var vehicles: [Vehicle]
  public var count: Int

  enum CodingKeys: String, CodingKey {
    case vehicles = "response", count
  }

  // MARK: - Vehicle
  public struct Vehicle: Codable, Identifiable {
    public var id, vehicleId: Int
    public var vin: String
    public var displayName: String?
    public var optionCodes: String
    public var accessType: String
    public var tokens: [String]
    public var state: String
    public var inService: Bool
    public var idS: String
    public var calendarEnabled: Bool
    public var apiVersion: Int
    enum CodingKeys: String, CodingKey {
      case id
      case vehicleId = "vehicle_id"
      case vin
      case displayName = "display_name"
      case optionCodes = "option_codes"
      case accessType = "access_type"
      case tokens, state
      case inService = "in_service"
      case idS = "id_s"
      case calendarEnabled = "calendar_enabled"
      case apiVersion = "api_version"
    }
  }
}


// MARK: - VehicleData

public struct VehicleDataContainer: Codable {
  public var response: Response
  // MARK: - Response
  public struct Response: Codable, Identifiable {
    public var id, userId, vehicleId: Int
    public var vin: String
    public var displayName: String?
    public var optionCodes: String
    public var accessType: String
    public var tokens: [String]
    public var state: String
    public var inService: Bool
    public var idS: String
    public var calendarEnabled: Bool
    public var apiVersion: Int
    public var vehicleState: VehicleState

    enum CodingKeys: String, CodingKey {
      case id
      case userId = "user_id"
      case vehicleId = "vehicle_id"
      case vin
      case displayName = "display_name"
      case optionCodes = "option_codes"
      case accessType = "access_type"
      case tokens, state
      case inService = "in_service"
      case idS = "id_s"
      case calendarEnabled = "calendar_enabled"
      case apiVersion = "api_version"
      case vehicleState = "vehicle_state"
    }
    // MARK: - VehicleState
    public struct VehicleState: Codable {
      public var apiVersion: Int
      public var autoparkStateV3, autoparkStyle: String
      public var calendarSupported: Bool
      public var carVersion: String
      public var centerDisplayState, df, dr, fdWindow: Int
      public var fpWindow, ft: Int
      public var isUserPresent: Bool
      public var lastAutoparkError: String
      public var locked: Bool
      public var notificationsSupported: Bool
      public var odometer: Double
      public var parsedCalendarSupported: Bool
      public var pf, pr, rdWindow: Int
      public var remoteStart, remoteStartEnabled, remoteStartSupported: Bool
      public var rpWindow, rt: Int
      public var sentryMode, sentryModeAvailable, smartSummonAvailable: Bool
      public var summonStandbyModeEnabled: Bool
      public var timestamp: Int
      public var valetMode, valetPinNeeded: Bool
      public var vehicleName: String?

      enum CodingKeys: String, CodingKey {
        case apiVersion = "api_version"
        case autoparkStateV3 = "autopark_state_v3"
        case autoparkStyle = "autopark_style"
        case calendarSupported = "calendar_supported"
        case carVersion = "car_version"
        case centerDisplayState = "center_display_state"
        case df, dr
        case fdWindow = "fd_window"
        case fpWindow = "fp_window"
        case ft
        case isUserPresent = "is_user_present"
        case lastAutoparkError = "last_autopark_error"
        case locked
        case notificationsSupported = "notifications_supported"
        case odometer
        case parsedCalendarSupported = "parsed_calendar_supported"
        case pf, pr
        case rdWindow = "rd_window"
        case remoteStart = "remote_start"
        case remoteStartEnabled = "remote_start_enabled"
        case remoteStartSupported = "remote_start_supported"
        case rpWindow = "rp_window"
        case rt
        case sentryMode = "sentry_mode"
        case sentryModeAvailable = "sentry_mode_available"
        case smartSummonAvailable = "smart_summon_available"
        case summonStandbyModeEnabled = "summon_standby_mode_enabled"
        case timestamp
        case valetMode = "valet_mode"
        case valetPinNeeded = "valet_pin_needed"
        case vehicleName = "vehicle_name"
      }
    }
  }
}


// MARK: - Command
public struct CommandContainer: Codable {
  public var response: Response

  // MARK: - Response
  public struct Response: Codable {
    public var result: Bool
    public var reason: String
  }
}
