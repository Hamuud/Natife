//
//  ContentView.swift
//  Natify_Test
//
//  Created by Артем Лясковець on 31.08.2023.
//

import SwiftUI
import Combine

struct PostsResponse: Codable {
    let posts: [Post]
}

struct Post: Codable, Identifiable {
    let postId: Int
    let timeshamp: Int
    let title: String
    let preview_text: String
    let likes_count: Int
    let id = UUID()
}

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false

    @State private var posts: [Post] = []
    @State private var selectedPost: Post?
    @State private var isExpanded = false
    @State private var sortingOption: SortingOption = .default
    
    enum SortingOption: String {
        case likes_count
        case publish_date
        case `default`
    }
    
    let jsonURL = "https://raw.githubusercontent.com/anton-natife/jsons/master/api/main.json"
    
    var body: some View {
        NavigationView {
            List(posts.sorted(by: sortingOption.sortingComparator)) { post in
                Button(action: {
                    selectedPost = post
                }) {
                    VStack(alignment: .leading) {
                        Text(post.title)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(post.preview_text)
                            .lineLimit(isExpanded ? nil : 2)
                    
                        Spacer()
                        
                        Text("❤️ \(String(post.likes_count))")
                            .bold()
                        Button(action: {
                            withAnimation{
                                isExpanded.toggle()
                            }
                        }) {
                            Text(isExpanded
                                  ? "Collape"
                                  : "Expand"
                            )
                                .bold()
                        }
                        .frame(
                            width: UIScreen.main.bounds.width / 1.5,
                            height: 25,
                            alignment: .center
                        )
                        .padding()
                        .background(Color.primary)
                        .foregroundColor(Color.gray)
                        .cornerRadius(10)
                    }
                }
                .padding()
            
            }
            .sheet(item: $selectedPost) { post in
                PostDetailView(post: post)
            }
            .onAppear(perform: {
                fetchPosts(fromURL: jsonURL)
            })
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .navigationTitle("Posts")
            .navigationBarItems(leading: darkModeToggle, trailing: sortButton)
        }
    }
    
    var sortButton: some View {
        Menu("Sort By") {
            Button("Likes") {
                sortingOption = .likes_count
            }

            Button("Publish Date") {
                sortingOption = .publish_date
            }

            Button("Default") {
                sortingOption = .default
            }
        }
    }
    
    var darkModeToggle: some View {
        Button(action: {
            isDarkMode.toggle()
        }) {
            Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                .font(.title)
                .foregroundColor(.primary)
        }
    }
    
    func fetchPosts(fromURL url: String) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(PostsResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.posts = decodedResponse.posts
                    }
                    
                    return
                }
            }
            
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}

struct PostDetailView: View {
    let post: Post
    
    var body: some View {
        VStack {
            Text(post.title)
                .font(.title2)
            
            Divider()
            
            Text(post.preview_text)
                .font(.body)
                .bold()
                .foregroundColor(Color.gray)
            
            Text("❤️ \(String(post.likes_count))")
                .bold()
        }
        .padding()
    }
}

extension ContentView.SortingOption {
    var sortingComparator: (Post, Post) -> Bool {
        switch self {
        case .likes_count:
            return { $0.likes_count > $1.likes_count }
        case .publish_date:
            return { $0.timeshamp > $1.timeshamp }
        case .default:
            return { $0.postId < $1.postId }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
