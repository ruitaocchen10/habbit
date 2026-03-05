# Database Migrations

This directory contains SQL migration files for the Viably app's Supabase database.

## How to Apply Migrations

1. Open your [Supabase Dashboard](https://supabase.com/dashboard)
2. Navigate to your project: `pgtnhqqgyskiazwviybo`
3. Go to **SQL Editor** in the left sidebar
4. Click **New Query**
5. Copy the contents of the migration file (e.g., `002_fix_date_columns.sql`)
6. Paste into the SQL Editor
7. Click **Run** (or press Cmd/Ctrl + Enter)
8. Verify the migration succeeded

## Migration History

| Migration | Date | Description | Status |
|-----------|------|-------------|--------|
| `001_initial_schema.sql` | 2026-02-19 | Initial tables, RLS policies, indexes | ✓ Applied |
| `002_fix_date_columns.sql` | 2026-02-21 | Convert DATE to TIMESTAMPTZ for decoder compatibility | ⏳ **Apply this now** |

## Current Issue

The app is experiencing "Data Couldn't Be Read" errors because:
- Database has `DATE` columns (`activated_at`, `completed_date`)
- Swift decoder expects ISO8601 timestamps with time component
- Migration 002 fixes this by converting all date columns to `TIMESTAMPTZ`

**Action Required:** Run migration `002_fix_date_columns.sql` in Supabase SQL Editor now.
