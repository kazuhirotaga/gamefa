-- Initial Data for Niigata Card Collection
-- Based on "新潟県カードコレクション.md"

INSERT INTO card_templates (name, rarity, category, description, base_attack, base_defense, base_speed, base_utility, region_id, character_name) VALUES
-- Legendary (5 cards)
('朱鷺（トキ）', 'legendary', 'creature', '新潟の象徴、特別天然記念物の朱鷺。その美しいピンクの羽根は見る者を魅了する。', 70, 60, 95, 85, 'niigata_sado', 'トキヒメ'),
('佐渡金山', 'legendary', 'location', 'かつて日本最大の金山として栄えた佐渡金山。その歴史的価値は計り知れない。', 50, 95, 20, 90, 'niigata_sado', 'キンザン'),
('八海山', 'legendary', 'location', '越後三山の一つ、霊峰八海山。その雄大な姿は訪れる者に畏敬の念を抱かせる。', 85, 90, 40, 75, 'niigata_uonuma', 'ハッカイ'),
('弥彦神社', 'legendary', 'location', '越後一宮として千年以上の歴史を持つ霊験あらたかな古社。', 75, 95, 50, 90, 'niigata_yahiko', 'ヤヒコノミコト'),
('上杉謙信', 'legendary', 'other', '越後の龍と称された戦国最強の武将。義を重んじる軍神。', 99, 85, 90, 80, 'niigata_joetsu', 'ケンシン'),

-- Epic (10 cards selected)
('直江兼続', 'epic', 'other', '「愛」の兜で有名な上杉家の名家老。文武両道の智将。', 75, 70, 80, 95, 'niigata_uonuma', 'カネツグ'),
('越後の日本酒', 'epic', 'artifact', '名水と良質な米から生まれる越後の日本酒。', 55, 40, 50, 90, 'niigata_all', 'サケノミヤ'),
('白山神社', 'epic', 'location', '新潟市の総鎮守。縁結びのパワースポット。', 60, 85, 55, 80, 'niigata_city', 'ハクサンヒメ'),
('コシヒカリ（南魚沼産）', 'epic', 'nature', '日本一の米どころ南魚沼で育まれた最高級コシヒカリ。', 60, 70, 45, 95, 'niigata_uonuma', 'ヒカリ'),
('雲洞庵', 'epic', 'location', '上杉謙信や直江兼続が幼少期に学んだ歴史ある禅寺。', 55, 90, 40, 85, 'niigata_uonuma', 'ウントウ'),
('上杉景勝', 'epic', 'other', '上杉謙信の養子で後継者。寡黙だが義を重んじる武将。', 80, 85, 65, 75, 'niigata_joetsu', 'カゲカツ'),
('新潟の花火', 'epic', 'other', '日本三大花火大会の一つ。夜空を彩る大輪の花。', 95, 30, 85, 60, 'niigata_nagaoka', 'ハナビ'),
('燕三条の金属製品', 'epic', 'artifact', '世界に誇る金属加工技術。職人の技が生み出す逸品。', 85, 75, 60, 95, 'niigata_tsubame', 'タクミ'),

-- Rare (Selected)
('長尾為景', 'rare', 'other', '上杉謙信の父。越後の統一に尽力した戦国武将。', 85, 70, 75, 65, 'niigata_joetsu', 'タメカゲ'),
('居多神社', 'rare', 'location', '越後国一宮の一社。上杉謙信が戦勝祈願をした神社。', 65, 75, 50, 70, 'niigata_joetsu', 'コタノカミ'),
('へぎそば', 'rare', 'artifact', '布海苔をつなぎに使った新潟名物。', 45, 50, 70, 80, 'niigata_ojiya', 'ヘギベエ'),
('笹団子', 'rare', 'artifact', '笹の葉で包まれた緑色のお餅。', 30, 40, 50, 75, 'niigata_all', 'ササコ'),
('日本海の荒波', 'rare', 'nature', '荒々しくも美しい日本海の波。', 75, 55, 60, 50, 'niigata_coast', 'ナミ'),

-- Uncommon (Selected)
('越後の雪景色', 'uncommon', 'location', '一面の銀世界。豪雪地帯ならではの美しい雪景色。', 30, 80, 35, 60, 'niigata_all', 'ユキオンナ'),
('信濃川', 'uncommon', 'location', '日本一長い川、信濃川。', 50, 60, 55, 70, 'niigata_river', 'シナノ'),
('柿の種', 'uncommon', 'artifact', '新潟発祥の国民的おやつ。', 40, 30, 60, 85, 'niigata_all', 'カキピー'),
('加茂水族館のクラゲ', 'uncommon', 'creature', '幻想的に漂うクラゲ。', 35, 50, 25, 65, 'niigata_kamo', 'クラゲ');

-- Initialize Region Limits for Legendary Cards (Example)
-- Assuming we have the UUIDs, but for SQL script we'd need to select them.
-- This is a conceptual block. In real implementation, this would be done via script or manual entry.
/*
INSERT INTO region_card_limits (region_id, card_template_id, rarity, max_count, reset_at)
SELECT 'niigata_sado', id, 'legendary', 1, NOW() + INTERVAL '3 months'
FROM card_templates WHERE name = '朱鷺（トキ）';
*/
