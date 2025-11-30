-- Update RPC function to handle Level Up logic
CREATE OR REPLACE FUNCTION increment_user_stats(
    user_uuid UUID,
    exp_gain INTEGER,
    coin_gain INTEGER
)
RETURNS VOID AS $$
DECLARE
    current_exp INTEGER;
    new_exp INTEGER;
    new_level INTEGER;
    level_def RECORD;
BEGIN
    -- 1. Get current stats
    SELECT exp INTO current_exp FROM users WHERE id = user_uuid;
    new_exp := current_exp + exp_gain;

    -- 2. Determine new level based on level_definitions
    -- Find the highest level where required_exp <= new_exp
    SELECT * INTO level_def
    FROM level_definitions
    WHERE required_exp <= new_exp
    ORDER BY level DESC
    LIMIT 1;

    -- Default to level 1 if something goes wrong (shouldn't happen if table is populated)
    IF level_def IS NULL THEN
        new_level := 1;
    ELSE
        new_level := level_def.level;
    END IF;

    -- 3. Update User
    -- We update level and max stats if the level has changed (or just always sync them to be safe)
    UPDATE users
    SET 
        exp = new_exp,
        coins = coins + coin_gain,
        level = new_level,
        max_hp = COALESCE(level_def.max_hp, max_hp),
        max_mp = COALESCE(level_def.max_mp, max_mp),
        max_stamina = COALESCE(level_def.max_stamina, max_stamina),
        -- Optional: Heal HP/MP on level up? Let's just increase max for now.
        updated_at = NOW()
    WHERE id = user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
