//
// Copyright © 2018 Smirnov Maxim. All rights reserved. 
//

import Foundation

enum NetworkError: Error, Equatable {
    case unknown
}

protocol NetworkClient {
    func performGet<T: Decodable>(endpoint: URL,
                                  for type: T.Type,
                                  completion: @escaping ((Result<T, NetworkError>) -> Void))
}

struct CurrenciesNetworkClient: NetworkClient {
    func performGet<T: Decodable>(endpoint: URL,
                                  for type: T.Type,
                                  completion: @escaping ((Result<T, NetworkError>) -> Void)) {

        URLSession.shared.dataTask(with: endpoint) { (data, response, error) in
            if error != nil {
                completion(.failure(.unknown))
                return
            }

            guard
                let data = data,
                let response = try? JSONDecoder().decode(T.self, from: data) else {
                    completion(.failure(.unknown))
                    return
            }
            completion(.success(response))
            }
            .resume()
    }
}
