import Foundation

struct UserPresetRecord: Codable, Equatable, Sendable {
    var number: Int
    var name: String
    var values: [String: Float]
}

enum UserPresetStore {
    private static let defaultsKey = "jjmoon.userPresets.v1"

    static func load() -> [UserPresetRecord] {
        if let records = decode(SharedDefaults.group?.data(forKey: defaultsKey)) { return records }
        if let records = decode(UserDefaults.standard.data(forKey: defaultsKey)) {
            try? save(records)
            return records
        }
        if let records = decode(fileData()) {
            try? save(records)
            return records
        }
        return []
    }

    private static func decode(_ data: Data?) -> [UserPresetRecord]? {
        guard let data else { return nil }
        return try? JSONDecoder().decode([UserPresetRecord].self, from: data)
    }

    static func save(_ records: [UserPresetRecord]) throws {
        let data = try JSONEncoder().encode(records)
        SharedDefaults.set(data, forKey: defaultsKey)
        if let url = try? fileURL() {
            try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? data.write(to: url, options: [.atomic])
        }
    }

    private static func fileData() -> Data? {
        guard let url = try? fileURL() else { return nil }
        return try? Data(contentsOf: url)
    }

    private static func directoryURL() throws -> URL {
        if let group = SharedDefaults.containerURL {
            return group.appendingPathComponent("jj-moon", isDirectory: true)
        }
        let base = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return base.appendingPathComponent("jj-moon", isDirectory: true)
    }

    private static func fileURL() throws -> URL {
        try directoryURL().appendingPathComponent("user-presets.json")
    }
}
