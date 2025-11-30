-- Create level_definitions table
CREATE TABLE IF NOT EXISTS level_definitions (
    level INTEGER PRIMARY KEY,
    required_exp INTEGER NOT NULL,
    max_hp INTEGER NOT NULL,
    max_mp INTEGER NOT NULL,
    max_stamina INTEGER NOT NULL,
    reward_coins INTEGER NOT NULL
);

-- Enable RLS (Read-only for users)
ALTER TABLE level_definitions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access" ON level_definitions
    FOR SELECT USING (true);

-- Populate with data for levels 1-99
-- Formulae:
-- EXP: 50 * (Level-1) * Level (Quadratic curve) -> L1=0, L2=100, L3=300...
-- HP: 100 + (Level-1) * 10
-- MP: 50 + (Level-1) * 2
-- Stamina: 100 + (Level-1)
-- Coins: Level * 100 (Reward for reaching this level)

INSERT INTO level_definitions (level, required_exp, max_hp, max_mp, max_stamina, reward_coins)
SELECT
    l,
    50 * (l - 1) * l,
    100 + (l - 1) * 10,
    50 + (l - 1) * 2,
    100 + (l - 1),
    l * 100
FROM generate_series(1, 99) as l
ON CONFLICT (level) DO UPDATE SET
    required_exp = EXCLUDED.required_exp,
    max_hp = EXCLUDED.max_hp,
    max_mp = EXCLUDED.max_mp,
    max_stamina = EXCLUDED.max_stamina,
    reward_coins = EXCLUDED.reward_coins;
