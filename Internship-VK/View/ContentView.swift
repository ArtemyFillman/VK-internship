//
//  ContentView.swift
//  Internship-VK
//
//  Created by Artemy Fillman on 03/12/2024.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RepositoryViewModel()
    @State private var editingRepositoryIndex: Int? = nil
    @State private var newRepositoryName: String = ""

    var body: some View {
        NavigationView {
            VStack {
                // Выбор варианта сортировки
                Picker("Sort by", selection: $viewModel.sortOption) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: viewModel.sortOption) { _ in
                    viewModel.sortRepositories()
                }

                if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }

                List {
                    ForEach(viewModel.repositories.indices, id: \.self) { index in
                        HStack {
                            if editingRepositoryIndex == index {
                                TextField("New repository name", text: $newRepositoryName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal)
                                    .onSubmit {
                                        viewModel.editRepository(at: index, newName: newRepositoryName)
                                        editingRepositoryIndex = nil
                                    }
                            } else {
                                RepositoryRow(repository: viewModel.repositories[index])
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .padding([.top, .horizontal])
                                    .onAppear {
                                        // Проверяем, достиг ли пользователь конца списка
                                        if index == viewModel.repositories.count - 1 {
                                            Task {
                                                await viewModel.fetchRepositories()
                                            }
                                        }
                                    }
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            viewModel.deleteRepository(at: index)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }

                                        Button {
                                            editingRepositoryIndex = index
                                            newRepositoryName = viewModel.repositories[index].name
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                    }
                            }
                        }
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                .listStyle(PlainListStyle())
                .onAppear {
                    Task {
                        await viewModel.fetchRepositories()
                    }
                }
            }
            .navigationTitle("Repositories")
        }
    }
}

struct RepositoryRow: View {
    let repository: Repository

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: repository.owner.avatarUrl)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .padding()

            VStack(alignment: .leading, spacing: 5) {
                Text(repository.name)
                    .font(.headline)
                if let description = repository.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Text("⭐ \(repository.stargazersCount)")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(RepositoryViewModel())
    }
}
