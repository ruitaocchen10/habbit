-- Migration: 003_remove_icon_color_columns
-- Description: Drops icon and color columns from habit_templates (unused in app)
-- Created: 2026-02-23

ALTER TABLE habit_templates DROP COLUMN IF EXISTS icon;
ALTER TABLE habit_templates DROP COLUMN IF EXISTS color;
