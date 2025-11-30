-- Create item_templates table
CREATE TABLE IF NOT EXISTS item_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL CHECK (type IN ('consumable', 'material', 'key_item')),
    effect_type TEXT, -- e.g., 'heal_hp', 'heal_mp', 'buff_atk'
    effect_value INTEGER,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create user_items table
CREATE TABLE IF NOT EXISTS user_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    template_id UUID REFERENCES item_templates(id),
    quantity INTEGER DEFAULT 1 CHECK (quantity >= 0),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, template_id)
);

-- Enable RLS
ALTER TABLE item_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_items ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Public read access for item_templates" ON item_templates FOR SELECT USING (true);
CREATE POLICY "Users can see own items" ON user_items FOR SELECT USING (auth.uid() = user_id);

-- Insert Sample Items
INSERT INTO item_templates (name, description, type, effect_type, effect_value) VALUES
('ポーション', 'HPを50回復する', 'consumable', 'heal_hp', 50),
('エーテル', 'MPを20回復する', 'consumable', 'heal_mp', 20),
('毒消し草', '毒状態を治す', 'consumable', 'cure_poison', 0),
('鉄の剣', '攻撃力が少し上がる（装備品）', 'material', 'equip_atk', 5);

-- Give test user some items (assuming test user exists, if not this might fail or just skip. 
-- Better to do this in a separate script or just let the user earn them. 
-- For prototype, let's try to insert for the known test user ID if possible, or just leave it empty and let verification script add them.)
