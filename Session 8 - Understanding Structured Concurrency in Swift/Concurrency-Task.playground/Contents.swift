import UIKit

enum NetworkError: Error {
    case badUrl
    case noData
    case decodingError
    case invalidId
}

struct CreditScore: Decodable {
    let score: Int
}

struct Constants {
    struct Urls {
        static func equifax(userId: Int) -> URL? {
            return URL(string: "https://ember-sparkly-rule.glitch.me/equifax/credit-score/\(userId)")
        }
        
        static func experian(userId: Int) -> URL? {
            return URL(string: "https://ember-sparkly-rule.glitch.me/experian/credit-score/\(userId)")
        }
        
    }
}
func calculateAPR(creditScores: [CreditScore]) -> Double {
    let sum = creditScores.reduce(0) { prev, creditScore in
        prev + creditScore.score
    }
    return Double((sum/creditScores.count)/100)
}

func getAPR(userId: Int) async throws -> Double {
    if userId%2 == 0 {
        throw NetworkError.invalidId
    }
    guard let equifaxUrl = Constants.Urls.equifax(userId: userId),
          let experianUrl = Constants.Urls.experian(userId: userId) else {
              throw NetworkError.badUrl
          }

    async let (equifaxData, _) = URLSession.shared.data(from: equifaxUrl)
    async let (experianData, _) = URLSession.shared.data(from: experianUrl)
    
    guard let equifaxScore = try? JSONDecoder().decode(CreditScore.self, from: try await equifaxData),
          let experianScore = try? JSONDecoder().decode(CreditScore.self, from: try await experianData) else {
        throw NetworkError.decodingError
    }
    
    return calculateAPR(creditScores: [equifaxScore, experianScore])
}

let ids = [1,2,3,4,5]
var invalidIds: [Int] = []

Task {
    for id in ids {
        do {
            try Task.checkCancellation()
            let apr = try await getAPR(userId: id)
            print("User \(id): \(apr)")
        } catch {
            print("Failed to fetch APR for user \(id): \(error)")
            if error as! NetworkError == NetworkError.invalidId {
                invalidIds.append(id)
            }
        }
    }
    print(invalidIds)
}
