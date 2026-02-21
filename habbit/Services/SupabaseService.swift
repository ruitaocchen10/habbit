//
//  SupabaseService.swift
//  habbit
//

import Supabase
import Foundation

enum SupabaseService {
    static let client: SupabaseClient = {
        // Configure custom JSONDecoder with ISO8601 date strategy that supports fractional seconds
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try parsing with fractional seconds first (Supabase format)
            let formatterWithFractional = ISO8601DateFormatter()
            formatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatterWithFractional.date(from: dateString) {
                return date
            }

            // Fall back to parsing without fractional seconds
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date string: \(dateString)"
            )
        })

        // Create client options with custom decoder
        let options = SupabaseClientOptions(
            db: .init(decoder: decoder)
        )

        return SupabaseClient(
            supabaseURL: URL(string: Config.supabaseURL)!,
            supabaseKey: Config.supabaseAnonKey,
            options: options
        )
    }()
}
