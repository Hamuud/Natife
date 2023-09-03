//
//  ContentView.swift
//  Natify_Test
//
//  Created by Артем Лясковець on 31.08.2023.
//

import SwiftUI
import Combine
import Foundation

struct PostsResponse: Codable {
    let posts: [Post]
}

struct Post: Codable, Identifiable {
    let postId: Int
    let timeshamp: Double
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
    @State private var lineLimitStates: [UUID: Bool] = [:]
    
    enum SortingOption: String {
        case likes_count
        case publish_date
        case `default`
    }
    
    let jsonURL = "https://raw.githubusercontent.com/anton-natife/jsons/master/api/main.json"
    
    let secondsInADay: Double = 60 * 60 * 24
    
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
                            .lineLimit(lineLimitStates[post.id] == true ? nil : 2)
                    
                        Spacer()
                        HStack {
                            Text("❤️ \(String(post.likes_count))")
                                .bold()
                            
                            Spacer()
                            /*
                             I didn't understand what time frame this variable is in (Seconds / minutes / milliseconds) so I decided to convert it from milliseconds to days and round to the nearest whole number
                             */
                            Text("\(Int(round((Double(post.timeshamp) / 1000) / secondsInADay))) day ago")
                        }

                        if shouldShowButton(post: post) {
                            Button(action: {
                                toggleLineLimit(for: post)
                            }) {
                                Text(lineLimitStates[post.id] == true
                                     ? "Show Less"
                                     : "Show More"
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
                }
                .padding()
            
            }
            .sheet(item: $selectedPost) { post in
                ScrollView {
                    PostDetailes(post: post)
                }
            }
            .onAppear(perform: {
                fetchPosts(fromURL: jsonURL)
            })
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .navigationTitle("Posts")
            .navigationBarItems(leading: darkModeToggle, trailing: sortButton)
        }
    }
    
    private func toggleLineLimit(for post: Post) {
        if let currentLimitState = lineLimitStates[post.id] {
            lineLimitStates[post.id] = !currentLimitState
        } else {
            lineLimitStates[post.id] = false
        }
    }
    
    func shouldShowButton(post: Post) -> Bool {
        let symbolCount = post.preview_text.split(separator: " ")
        return symbolCount.count > 18
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

struct PostData: Codable {
    let post: PostDetail
}

struct PostDetail: Codable {
    let postId: Int
    let timeshamp: Int
    let title: String
    let text: String
    let postImage: String
    let likes_count: Int
}

struct PostDetailes: View {
    @State private var postData: PostData?
    let post: Post
    
    let secondsInADay: Double = 60 * 60 * 24
    
    var body: some View {
        VStack {
            if let post = postData?.post {
                VStack {
                    Image(systemName: "photo")
                        .data(url: post.postImage)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: UIScreen.main.bounds.width, idealWidth: UIScreen.main.bounds.width, maxWidth: UIScreen.main.bounds.width, minHeight: UIScreen.main.bounds.height / 3, idealHeight: UIScreen.main.bounds.height / 3, maxHeight: UIScreen.main.bounds.height / 3, alignment: .bottom)
                    Text(post.title)
                        .font(.headline)
                    Text(post.text)
                        .padding()
                        .lineLimit(nil)
                    HStack {
                        Text("❤️ \(String(post.likes_count))")
                            .bold()
                        
                        Spacer()
                        
                        Text("\(Int(ceil((Double(post.timeshamp) / 1000) / secondsInADay))) day ago")
                    }
                    .padding()
                }
            } else {
                ProgressView("Loading...")
            }
        }
        .padding(10)
        .onAppear {
            fetchData(id: post.postId)
        }
    }
    
    func fetchData(id: Int) {
        guard let url = URL(string: "https://raw.githubusercontent.com/anton-natife/jsons/master/api/posts/\(id).json") else {
            return
        }

        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(PostData.self, from: data)
                    DispatchQueue.main.async {
                        postData = decodedData
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
