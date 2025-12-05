//
//  AnyEncodable.swift
//  iOS Gym App
//
//  Created by Zachary Andrew Kolano on 12/4/25.
//

import Foundation

struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    init(_ value: Encodable) {
        self.encodeFunc = value.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}
