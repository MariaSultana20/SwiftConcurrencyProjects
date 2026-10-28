import UIKit

enum NetworkError: Error {
    case noData
    case invalidURL
    case decodingError
}
struct Post: Decodable {
    let title: String
}

func getPosts(completion: @escaping (Result<[Post], NetworkError>) -> Void) {
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
        completion(.failure(.invalidURL))
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data , error == nil else {
            completion(.failure(NetworkError.noData))
            return
        }
        guard let posts = try? JSONDecoder().decode([Post].self, from: data) else {
            completion(.failure(.decodingError))
            return
        }
        completion(.success(posts))
    }.resume()
}

getPosts { result in
    switch result {
    case .success(let posts):
        for post in posts {
            print(post.title)
        }
    case .failure(let error):
        print(error)
    }
}

