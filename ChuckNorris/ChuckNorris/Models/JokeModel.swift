//
//  JokeModel.swift
//  ChuckNorris
//
//  Created by Rafael Plinio on 29/06/21.
//

import Foundation

struct JokeModel: Codable {
    let categories: [String]
    let createdAt: String
    let iconURL: String
    let id, updatedAt: String
    let url: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case categories
        case createdAt = "created_at"
        case iconURL = "icon_url"
        case id
        case updatedAt = "updated_at"
        case url, value
    }
}

struct KeywordJokeModel: Codable {
    let total: Int
    let result: [JokeModel]
}

typealias Category = [String]


struct StatusCode: Codable {
    let success: Int
    let failure: Int
}
