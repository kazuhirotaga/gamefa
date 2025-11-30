-- Add email column to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS email TEXT;

-- Make line_user_id nullable since we support email login now
ALTER TABLE users ALTER COLUMN line_user_id DROP NOT NULL;
