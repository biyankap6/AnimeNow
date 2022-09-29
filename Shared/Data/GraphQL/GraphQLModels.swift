//
//  Models.swift
//  Anime Now! (iOS)
//
//  Created by Erik Bautista on 9/6/22.
//

import Foundation
import SociableWeaver

protocol GraphQLArgument {
    func getValue() -> ArgumentValueRepresentable
    var description: String { get }
}

protocol GraphQLArgumentOptions {
    associatedtype ArgumentOptions
    associatedtype Argument: GraphQLArgument
}

protocol GraphQLQueryObject {
    static func createQueryObject(_ name: CodingKey) -> Object
}

protocol GraphQLQuery: Decodable, GraphQLArgumentOptions {
    static func createQuery(_ arguments: ArgumentOptions) -> Weave
}

enum GraphQL {
    struct Paylod: Codable, Equatable {
        let query: String
        var operationName: String? = nil
        var variables: [String: String] = [:]
    }

    struct Response<T: Decodable>: Decodable {
        let data: T
    }

    struct NodeList<T: Decodable, P: Decodable>: Decodable {
        let nodes: [T]
        let pageInfo: P

        enum CodingKeys: String, CodingKey {
            case nodes
            case pageInfo
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let throwables = try values.decode([Throwable<T>].self, forKey: .nodes)
            nodes = throwables.compactMap { try? $0.result.get() }
            pageInfo = try values.decode(P.self, forKey: .pageInfo)
        }
    }
}


extension Weave {
    public func format(removeOperation: Bool = true) -> String {
        let weave = String("\(self.description)")

        if (removeOperation) {
            let output = String(weave.split(separator: "{", maxSplits: 1, omittingEmptySubsequences: true).last ?? "")
            return  "{\(output)"
        } else {
            return "{ \(weave) }"
        }
    }
}

extension Object {
    func argument<V: GraphQLArgument>(_ argument: V) -> Self {
        let argumentKey = argument.description
        let value = argument.getValue()
        return self.argument(key: argumentKey, value: value)
    }
}

extension Field {
    func argument<V: GraphQLArgument>(_ argument: V) -> Self {
        let argumentKey = argument.description
        let value = argument.getValue()
        return self.argument(key: argumentKey, value: value)
    }
}
