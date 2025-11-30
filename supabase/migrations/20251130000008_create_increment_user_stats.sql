-- Create RPC function to increment user stats safely
CREATE OR REPLACE FUNCTION increment_user_stats(
    user_uuid UUID,
    exp_gain INTEGER,
    coin_gain INTEGER
)
RETURNS VOID AS $$
BEGIN
    UPDATE users
    SET 
        exp = exp + exp_gain,
        coins = coins + coin_gain,
        updated_at = NOW()
    WHERE id = user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
