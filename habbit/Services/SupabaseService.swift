//
//  SupabaseService.swift
//  habbit
//

import Supabase
import Foundation

enum SupabaseService {
    static let client = SupabaseClient(
        supabaseURL: URL(string: Config.supabaseURL)!,
        supabaseKey: Config.supabaseAnonKey
    )
}
