//
//  City.swift
//  UnitTestWorkshop
//
//  Created by Bondan Eko Prasetyo on 19/07/19.
//  Copyright © 2019 Tokopedia. All rights reserved.
//

import Foundation

internal struct City: Equatable {
    let id: String
    let name: String
}

extension City {
    internal static let bekasi = City(id: "1", name: "Bekasi")
    internal static let jakarta = City(id: "2", name: "Jakarta")
    internal static let semarang = City(id: "3", name: "Semarang")
}

internal let shopNameTaken: [String] = [
    "supergadgettt",
    "tulusjayashop",
    "mega-persada",
    "tokopedia",
]

internal enum ShopError {
    case containEmoji
    case minCharacter
    case notAvailable
    case startOrEndWithWhitespace
    case textEmpty
    case notValidDomain
    
    public var message: String {
        switch self {
        case .containEmoji:
            return "Should not contain emoji"
        case .minCharacter:
            return "Should not less than 3 characters"
        case .notAvailable:
            return "Shop name not available"
        case .startOrEndWithWhitespace:
            return "Shop name should not end with whitespace"
        case .textEmpty:
            return "This field should not empty"
        case .notValidDomain:
            return "Domain Name is not valid, please change the domain name"
        }
    }
}

