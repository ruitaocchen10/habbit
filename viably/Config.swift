//
//  Config.swift
//  viably
//
//  IMPORTANT: This file contains sensitive credentials.
//  It is excluded from version control via .gitignore.
//  Do NOT commit this file.
//

enum Config {
    static let supabaseURL = "https://pgtnhqqgyskiazwviybo.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBndG5ocXFneXNraWF6d3ZpeWJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEyNTgwNzcsImV4cCI6MjA4NjgzNDA3N30.rtyI0it6uz4HBYLjUqcwuPHleo9JIOFwHiTu_gcEZb8"

    // The URL scheme registered in Xcode (Target → Info → URL Types)
    // and added as a redirect URL in the Supabase dashboard.
    static let oauthRedirectURL = "io.supabase.viably://login-callback"
}
