-- Migration: 004_add_is_mvd_to_habit_templates
-- Description: Adds is_mvd boolean column to habit_templates for Minimum Viable Day feature
-- Created: 2026-03-05

ALTER TABLE habit_templates ADD COLUMN is_mvd boolean NOT NULL DEFAULT false;
