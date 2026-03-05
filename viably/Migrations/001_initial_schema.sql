-- Migration: 001_initial_schema
-- Description: Creates habit_templates and habit_completions tables with RLS policies
-- Created: 2026-02-19

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create habit_templates table
CREATE TABLE IF NOT EXISTS habit_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    color TEXT,
    is_active BOOLEAN NOT NULL DEFAULT false,
    activated_at TIMESTAMPTZ,  -- Changed from DATE to TIMESTAMPTZ in migration 002
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create habit_completions table
CREATE TABLE IF NOT EXISTS habit_completions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    template_id UUID NOT NULL REFERENCES habit_templates(id) ON DELETE CASCADE,
    completed_date TIMESTAMPTZ NOT NULL,  -- Changed from DATE to TIMESTAMPTZ in migration 002
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, template_id, completed_date)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_habit_templates_user_id ON habit_templates(user_id);
CREATE INDEX IF NOT EXISTS idx_habit_templates_user_active ON habit_templates(user_id, is_active);
CREATE INDEX IF NOT EXISTS idx_habit_completions_user_id ON habit_completions(user_id);
CREATE INDEX IF NOT EXISTS idx_habit_completions_template_id ON habit_completions(template_id);
CREATE INDEX IF NOT EXISTS idx_habit_completions_user_date ON habit_completions(user_id, completed_date);

-- Enable Row Level Security
ALTER TABLE habit_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE habit_completions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for habit_templates
CREATE POLICY "Users can view their own habit templates"
    ON habit_templates FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own habit templates"
    ON habit_templates FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own habit templates"
    ON habit_templates FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own habit templates"
    ON habit_templates FOR DELETE
    USING (auth.uid() = user_id);

-- RLS Policies for habit_completions
CREATE POLICY "Users can view their own habit completions"
    ON habit_completions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own habit completions"
    ON habit_completions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own habit completions"
    ON habit_completions FOR DELETE
    USING (auth.uid() = user_id);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for habit_templates
CREATE TRIGGER update_habit_templates_updated_at
    BEFORE UPDATE ON habit_templates
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
