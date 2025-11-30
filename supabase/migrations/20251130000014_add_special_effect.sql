-- Add special_effect column to card_templates
ALTER TABLE card_templates ADD COLUMN IF NOT EXISTS special_effect TEXT;
