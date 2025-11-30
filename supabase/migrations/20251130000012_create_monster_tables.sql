-- Create monster_templates table
CREATE TABLE IF NOT EXISTS monster_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    element TEXT, -- 'fire', 'water', 'wind', 'earth', 'light', 'dark'
    image_url TEXT,
    
    -- Stats
    hp INTEGER DEFAULT 100,
    attack INTEGER DEFAULT 10,
    defense INTEGER DEFAULT 5,
    speed INTEGER DEFAULT 10,
    
    -- Rewards
    exp_reward INTEGER DEFAULT 10,
    coin_reward INTEGER DEFAULT 10,
    drop_item_id UUID REFERENCES item_templates(id),
    drop_rate FLOAT DEFAULT 0.1, -- 10%
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE monster_templates ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Public read access for monster_templates" ON monster_templates FOR SELECT USING (true);
-- Allow authenticated users (admins) to insert/update
CREATE POLICY "Admins can insert monster_templates" ON monster_templates FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Admins can update monster_templates" ON monster_templates FOR UPDATE USING (auth.role() = 'authenticated');

-- Insert Sample Monster
INSERT INTO monster_templates (name, description, element, hp, attack, exp_reward, coin_reward) VALUES
('スライム', '初心者の冒険者が最初に戦うモンスター。', 'water', 30, 5, 5, 5),
('ゴブリン', '集団で行動する小鬼。', 'earth', 50, 10, 15, 10),
('ドラゴン', '強大な力を持つ伝説の生物。', 'fire', 500, 50, 500, 1000);
