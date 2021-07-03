//
//  AlamofireService.swift
//  Reciplease
//
//  Created by Raphaël Payet on 26/06/2021.
//

import Foundation
import Alamofire

public enum NetworkRequestError: Error {
    case invalidURL
    case incorrectData
    case incorrectResponse
    case serializationError(Error)
}

public protocol NetworkRequest {
//    func get(from url: URL?, completion: @escaping ((Result<[String: Any], NetworkRequestError>?) -> Void) )
    func getResponse(from url: URL?, completion: @escaping (_ dictionnary: [String: Any]?, _ error : NetworkRequestError?) -> Void)
}

extension NetworkRequest {
    func getResponse(from url: URL?, completion: @escaping ([String: Any]?, NetworkRequestError?) -> Void) {
        guard let url = url else {
            completion(nil, .invalidURL)
            return
        }
        
        AF.request(url).validate().responseJSON { response in
            guard let value = response.value as? [String: Any] else {
                completion(nil, .incorrectResponse)
                return
            }
            print(value)
            completion(value, nil)
        }
    }
}

class AlamofireNetworkRequest: NetworkRequest {
    
    
    static let shared = AlamofireNetworkRequest()
    private init() {}
    
    private let baseURL         = "https://api.edamam.com/search?"
    private let APP_ID          = "08b5ed9a"
    private let APP_KEY         = "ad5b86fa2c4478bfc7c55184d216b14a"
    #warning("Always let max recipes to 10")
    private let maxRecipes      = 10
    
    
    
    func createURL(with ingredients: [String]) -> URL? {
        guard !ingredients.isEmpty else {
            return nil
        }
        
        
        var ingredientString = ""
        for ingredient in ingredients {
            ingredientString += "\(ingredient),"
        }
        
        let urlString = "\(baseURL)&app_id=\(APP_ID)&app_key=\(APP_KEY)&to=\(maxRecipes)&q=\(ingredientString)"
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        return url
    }
    
    
    
    func getRecipeObjects(from response: [String: Any]?) -> [RecipeObject]? {
        guard let response = response,
              let hits = response["hits"] as? [AnyObject],
                          !hits.isEmpty else {
                        return nil
                    }
                    
        var totalRecipes: [RecipeObject] = []
        
        for hit in hits {
            guard let dict = hit["recipe"] as? [String: Any],
                  let recipe = RecipeObjectService.shared.transformFromDict(dict)
            else {
                return nil
            }

            totalRecipes.append(recipe)
        }
        
        return totalRecipes
    }
    
}
