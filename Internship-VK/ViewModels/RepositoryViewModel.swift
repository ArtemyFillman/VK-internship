//
//  RepositoryViewModel.swift
//  Internship-VK
//
//  Created by Artemy Fillman on 03/12/2024.
//

import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case name = "Name"
    case stars = "Stars"
    case updated = "Updated"

    var id: String { self.rawValue }
}

class RepositoryViewModel: ObservableObject {
    @Published var repositories: [Repository] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var sortOption: SortOption = .name
    
    private var currentPage = 1
    private var totalCount = 0
    private var isLastPage = false

    func fetchRepositories() async {
        guard !isLoading, !isLastPage else { return }

        isLoading = true
        let urlString = "https://api.github.com/search/repositories?q=language:swift&page=\(currentPage)&per_page=30"

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode(GitHubSearchResult.self, from: data)

            repositories.append(contentsOf: decodedData.items)
            totalCount = decodedData.totalCount
            isLastPage = repositories.count >= totalCount
            currentPage += 1
            sortRepositories() // Применяем сортировку
            isLoading = false
        } catch {
            errorMessage = "Error loading data: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func sortRepositories() {
        switch sortOption {
        case .name:
            repositories.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .stars:
            repositories.sort { $0.stargazersCount > $1.stargazersCount }
        case .updated:
            repositories.sort { $0.updatedAt > $1.updatedAt }
        }
    }

    func deleteRepository(at index: Int) {
        repositories.remove(at: index)
    }

    func editRepository(at index: Int, newName: String) {
        repositories[index].name = newName
    }
}
