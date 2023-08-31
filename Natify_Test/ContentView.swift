//
//  ContentView.swift
//  Natify_Test
//
//  Created by Артем Лясковець on 31.08.2023.
//

import SwiftUI

struct PostsResponse: Hashable, Codable {
    let posts: [Post]
}


struct Post: Hashable, Codable {
    let postId: Int
    let timeshamp: Int
    let title: String
    let preview_text: String
    let likes_count: Int
}

struct ContentView: View {
    @State private var isExpanded = false
    @State private var results = [Post]()
    
    let jsonURL = "https://raw.githubusercontent.com/anton-natife/jsons/master/api/main.json"
    
    var body: some View {
        VStack {
            List(results, id: \.postId) {
                item in
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(item.preview_text)
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                        .lineLimit(isExpanded ? nil : 2)
                    
                    Spacer()
                    
                    Text("❤️ \(String(item.likes_count))")
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
                    }
                    .frame(
                        width: UIScreen.main.bounds.width / 1.5,
                        height: 25,
                        alignment: .center
                    )
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                }
                .padding()
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.black, lineWidth: 4)
                )
            }.onAppear(perform: {
                loadData(fromURL: jsonURL)
            })
        }
    }
    
    func loadData(fromURL url: String) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(PostsResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.results = decodedResponse.posts
                    }
                    
                    return
                }
            }
            
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 11")
            
    }
}
