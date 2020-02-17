//
//  AppConstants.swift
//  eCommerce

import Foundation
import UIKit

class AppConstants {
    static let phoneScreenWidth = UIScreen.main.bounds.width
    static let phoneScreenHeight = UIScreen.main.bounds.height
}

enum ApiResponseCase: Int {
    case success = 200
    case not_found = 404
    case validation_errors = 422
    case internal_server_error = 500
}

enum ApiName: String {
    case getAllCategories = "https://stark-spire-93433.herokuapp.com/json"
}
