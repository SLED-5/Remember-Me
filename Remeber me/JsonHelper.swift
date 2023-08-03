//
//  JsonHelper.swift
//  Remember Me
//
//  Created by Gabriel Zhang on 4/2/23.
//

import Foundation

public func loadProducts() -> [Product] {
    return loadDecodedObjects(file: "products", ofType: Product.self)
}

public func loadDialogueScript(script: String) -> [dialogue] {
    return loadDecodedObjects(file: script, ofType: dialogue.self)
}

public func loadMemoryCard(file: String) -> [MemoryCard] {
    return loadDecodedObjects(file: file, ofType: MemoryCard.self)
}

public func loadDecodedObjects<T: Codable>(file:String, ofType type:T.Type) -> [T] {
    let url = Bundle.main.url(forResource: file, withExtension: "json")!
    let json = try! Data(contentsOf: url)
    let decoder = JSONDecoder()
    let decodedObject = try! decoder.decode([T].self, from: json)
    return decodedObject
}
