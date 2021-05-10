// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let aRGroups = try ARGroups(json)

import Foundation

// MARK: - ARGroup
struct ARGroup: Codable {
    var uuid, title, type, catagory: String
    var appArchives: [ARAppArchive]

    enum CodingKeys: String, CodingKey {
        case uuid = "UUID"
        case title = "Title"
        case type = "Type"
        case catagory = "Catagory"
        case appArchives = "AppArchives"
    }
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
        type: String? = nil,
        catagory: String? = nil,
        appArchives: [ARAppArchive]? = nil
    ) -> ARGroup {
        return ARGroup(
            uuid: uuid ?? self.uuid,
            title: title ?? self.title,
            type: type ?? self.type,
            catagory: catagory ?? self.catagory,
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
    var uuid, title, version, build: String
    var releaseType: String
    var date: Date
    var notes: String
    var tags: [String]

    enum CodingKeys: String, CodingKey {
        case uuid = "UUID"
        case title = "Title"
        case version = "Version"
        case build = "Build"
        case releaseType = "ReleaseType"
        case date = "Date"
        case notes = "Notes"
        case tags = "Tags"
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
        version: String? = nil,
        build: String? = nil,
        releaseType: String? = nil,
        date: Date? = nil,
        notes: String? = nil,
        tags: [String]? = nil
    ) -> ARAppArchive {
        return ARAppArchive(
            uuid: uuid ?? self.uuid,
            title: title ?? self.title,
            version: version ?? self.version,
            build: build ?? self.build,
            releaseType: releaseType ?? self.releaseType,
            date: date ?? self.date,
            notes: notes ?? self.notes,
            tags: tags ?? self.tags
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
