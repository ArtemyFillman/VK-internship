//
//  Repository.swift
//  Internship-VK
//
//  Created by Artemy Fillman on 03/12/2024.
//

import Foundation

struct GitHubSearchResult: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [Repository]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

struct Repository: Codable, Identifiable {
    let id: Int
    var name: String
    let description: String?
    let htmlUrl: String
    let stargazersCount: Int // Количество звёзд
    let updatedAt: String // Дата последнего обновления
    let owner: RepositoryOwner

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case htmlUrl = "html_url"
        case stargazersCount = "stargazers_count"
        case updatedAt = "updated_at"
        case owner
    }
}

struct RepositoryOwner: Codable {
    let login: String
    let avatarUrl: String

    enum CodingKeys: String, CodingKey {
        case login
        case avatarUrl = "avatar_url"
    }
}
