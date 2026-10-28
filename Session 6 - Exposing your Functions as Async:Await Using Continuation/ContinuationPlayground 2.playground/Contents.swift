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

func getPost() async throws -> [Post] {
    return try await withCheckedThrowingContinuation { continuation in
        getPosts { result in
            switch result {
            case .success(let posts):
                continuation.resume(returning: posts)
            case .failure(let error):
                //print(error)
                continuation.resume(throwing: error)
            }
        }
    }
}

Task {
    do {
        let posts = try await getPost()
        for post in posts {
            print(post)
        }
    } catch {
        print(error)
    }
}

//getPosts { result in
//    switch result {
//    case .success(let posts):
//        for post in posts {
//            print(post.title)
//        }
//    case .failure(let error):
//        print(error)
//    }
//}

