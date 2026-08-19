/*
# Add settings table for public theme selection

1. New Tables
- `settings`
  - `key` (varchar, primary key) - setting name
  - `value` (text) - setting value
  - `updated_at` (timestamp) - last modification
2. Purpose
- Stores admin-configurable system settings. First setting: `public_theme`
  with values 'classic' or 'modern'.
*/

CREATE TABLE IF NOT EXISTS settings (
    key VARCHAR(100) PRIMARY KEY,
    value TEXT NOT NULL DEFAULT '',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO settings (key, value)
VALUES ('public_theme', 'classic')
ON CONFLICT (key) DO NOTHING;
