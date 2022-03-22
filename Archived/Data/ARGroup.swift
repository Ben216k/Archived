// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let aRGroups = try ARGroups(json)

import Foundation

// MARK: - ARGroup
struct ARGroup: Codable, Identifiable {
    var uuid, title, category: String
    var appArchives: [ARAppArchive]

    enum CodingKeys: String, CodingKey {
        case uuid = "UUID"
        case title = "Title"
        case category = "Category"
        case appArchives = "AppArchives"
    }
    
    var id: String { uuid }
}

// MARK: ARGroup convenience initializers and mutators

extension ARGroup {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ARGroup.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        uuid: String? = nil,
        title: String? = nil,
        category: String? = nil,
        appArchives: [ARAppArchive]? = nil
    ) -> ARGroup {
        return ARGroup(
            uuid: uuid ?? self.uuid,
            title: title ?? self.title,
            category: category ?? self.category,
            appArchives: appArchives ?? self.appArchives
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - ARAppArchive
struct ARAppArchive: Codable {
    var uuid, title, releaseType: String
    var date: Date
    var notes: String
    var files: [String]

    enum CodingKeys: String, CodingKey {
        case uuid = "UUID"
        case title = "Title"
        case releaseType = "ReleaseType"
        case date = "Date"
        case notes = "Notes"
        case files = "Files"
    }
}

// MARK: ARAppArchive convenience initializers and mutators

extension ARAppArchive {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ARAppArchive.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        uuid: String? = nil,
        title: String? = nil,
        releaseType: String? = nil,
        date: Date? = nil,
        notes: String? = nil,
        files: [String]? = nil
    ) -> ARAppArchive {
        return ARAppArchive(
            uuid: uuid ?? self.uuid,
            title: title ?? self.title,
            releaseType: releaseType ?? self.releaseType,
            date: date ?? self.date,
            notes: notes ?? self.notes,
            files: files ?? self.files
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

typealias ARGroups = [ARGroup]

extension Array where Element == ARGroups.Element {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ARGroups.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
