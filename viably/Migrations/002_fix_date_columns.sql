-- Migration: 002_fix_date_columns
-- Description: Convert DATE columns to TIMESTAMPTZ for consistent encoding/decoding
-- Created: 2026-02-21
--
-- This fixes the "Data Couldn't Be Read" issue by ensuring all date fields
-- use TIMESTAMPTZ format, which matches the ISO8601 decoder configuration.

-- Convert activated_at from DATE to TIMESTAMPTZ
ALTER TABLE habit_templates
  ALTER COLUMN activated_at TYPE TIMESTAMPTZ USING activated_at::TIMESTAMPTZ;

-- Convert completed_date from DATE to TIMESTAMPTZ
ALTER TABLE habit_completions
  ALTER COLUMN completed_date TYPE TIMESTAMPTZ USING completed_date::TIMESTAMPTZ;

-- Note: The USING clause converts existing DATE values to TIMESTAMPTZ at midnight UTC
-- Existing data will be preserved with time set to 00:00:00+00
