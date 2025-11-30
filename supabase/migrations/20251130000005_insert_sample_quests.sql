-- Insert sample quests
INSERT INTO quests (title, description, type, target_action, target_count, reward_exp, reward_coins)
VALUES
-- Daily Quests
('デイリーチェックイン', '任意の施設に1回チェックインする', 'daily', 'checkin', 1, 50, 100),
('デイリーバトル', 'モンスターと1回戦う', 'daily', 'battle', 1, 50, 100),

-- Weekly Quests
('ウィークリーウォーカー', '合計5回チェックインする', 'weekly', 'checkin', 5, 200, 500),

-- Story/Tutorial Quests
('はじめてのチェックイン', '記念すべき最初のチェックイン！', 'story', 'checkin', 1, 100, 200),
('はじめての勝利', 'バトルで初勝利を収める', 'story', 'battle_win', 1, 100, 200);
