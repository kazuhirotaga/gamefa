-- Real Quest Database Schema for Supabase
-- Based on Technical Design Document and Card Acquisition System

-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    line_user_id TEXT UNIQUE NOT NULL,
    display_name TEXT,
    level INTEGER DEFAULT 1,
    exp INTEGER DEFAULT 0,
    hp INTEGER DEFAULT 100,
    max_hp INTEGER DEFAULT 100,
    mp INTEGER DEFAULT 50,
    max_mp INTEGER DEFAULT 50,
    stamina INTEGER DEFAULT 100,
    max_stamina INTEGER DEFAULT 100,
    coins INTEGER DEFAULT 0,
    magic_stones INTEGER DEFAULT 0,
    current_location GEOGRAPHY(POINT),
    last_login_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Card Templates (Master Data)
CREATE TABLE card_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    rarity TEXT NOT NULL CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic', 'legendary')),
    category TEXT NOT NULL CHECK (category IN ('nature', 'artifact', 'location', 'creature', 'other')),
    element TEXT,
    image_url TEXT,
    
    -- Base Stats
    base_attack INTEGER DEFAULT 0,
    base_defense INTEGER DEFAULT 0,
    base_speed INTEGER DEFAULT 0,
    base_utility INTEGER DEFAULT 0,
    
    -- Acquisition Info
    region_id TEXT, -- e.g., 'niigata_sado', 'niigata_city'
    acquisition_radius_meters INTEGER DEFAULT 5000,
    
    -- Character Info (Anthropomorphized)
    character_name TEXT,
    character_voice_id TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. User Cards (Inventory)
CREATE TABLE user_cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    template_id UUID REFERENCES card_templates(id),
    
    -- Current Stats (Level up logic)
    level INTEGER DEFAULT 1,
    exp INTEGER DEFAULT 0,
    current_attack INTEGER,
    current_defense INTEGER,
    current_speed INTEGER,
    current_utility INTEGER,
    
    -- Metadata
    obtained_at TIMESTAMPTZ DEFAULT NOW(),
    obtained_location GEOGRAPHY(POINT),
    is_favorite BOOLEAN DEFAULT FALSE,
    is_equipped BOOLEAN DEFAULT FALSE
);

-- 4. Region Card Limits (Scarcity System)
CREATE TABLE region_card_limits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    region_id TEXT NOT NULL,
    card_template_id UUID REFERENCES card_templates(id),
    rarity TEXT NOT NULL,
    max_count INTEGER NOT NULL,
    current_count INTEGER DEFAULT 0,
    reset_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(region_id, card_template_id)
);

-- 5. User Pity Counter (Gacha Safety Net)
CREATE TABLE user_pity_counters (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    consecutive_no_rare INTEGER DEFAULT 0,
    consecutive_no_epic INTEGER DEFAULT 0,
    consecutive_no_legendary INTEGER DEFAULT 0,
    last_rare_at TIMESTAMPTZ,
    last_epic_at TIMESTAMPTZ,
    last_legendary_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Facilities (Check-in Spots)
CREATE TABLE facilities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('restaurant', 'hotel', 'retail', 'leisure', 'public', 'shrine', 'temple', 'other')),
    location GEOGRAPHY(POINT) NOT NULL,
    address TEXT,
    region_id TEXT,
    
    -- Gameplay Bonuses
    bonus_exp_rate FLOAT DEFAULT 1.0,
    bonus_drop_rate FLOAT DEFAULT 1.0,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Check-ins
CREATE TABLE checkins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    facility_id UUID REFERENCES facilities(id),
    location GEOGRAPHY(POINT),
    
    -- Payment Verification
    payment_amount INTEGER DEFAULT 0,
    receipt_image_url TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    
    -- Rewards
    exp_gained INTEGER DEFAULT 0,
    coins_gained INTEGER DEFAULT 0,
    cards_obtained UUID[], -- Array of user_card_ids
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Quests
CREATE TABLE quests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL CHECK (type IN ('daily', 'weekly', 'story', 'event')),
    
    -- Requirements
    target_action TEXT, -- 'walk', 'checkin', 'battle', 'collect'
    target_count INTEGER,
    target_facility_type TEXT,
    
    -- Rewards
    reward_exp INTEGER,
    reward_coins INTEGER,
    reward_items JSONB,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. User Quests (Progress)
CREATE TABLE user_quests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    quest_id UUID REFERENCES quests(id),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'claimed')),
    current_progress INTEGER DEFAULT 0,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for Performance
CREATE INDEX idx_users_line_id ON users(line_user_id);
CREATE INDEX idx_user_cards_user_id ON user_cards(user_id);
CREATE INDEX idx_checkins_user_id ON checkins(user_id);
CREATE INDEX idx_checkins_location ON checkins USING GIST(location);
CREATE INDEX idx_facilities_location ON facilities USING GIST(location);
CREATE INDEX idx_region_card_limits_region ON region_card_limits(region_id);

-- RLS Policies (Row Level Security)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkins ENABLE ROW LEVEL SECURITY;

-- Basic Policy: Users can only see/edit their own data
-- Note: In a real deployment, you'd define specific policies for each table.
-- For prototype, we assume the backend (n8n) uses a service role key.
