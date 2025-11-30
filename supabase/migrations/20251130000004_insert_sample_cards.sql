-- Insert sample cards from Niigata Card Collection
INSERT INTO card_templates (name, description, rarity, category, base_attack, base_defense, base_speed, base_utility, image_url)
VALUES
('朱鷺', '新潟の象徴、特別天然記念物の朱鷺。その美しいピンクの羽根は見る者を魅了する。', 'legendary', 'creature', 70, 60, 95, 85, 'https://placehold.co/400x600/ffcccc/ffffff?text=Toki'),
('佐渡金山', 'かつて日本最大の金山として栄えた佐渡金山。その歴史的価値は計り知れない。', 'legendary', 'location', 50, 95, 20, 90, 'https://placehold.co/400x600/ffd700/000000?text=Sado+Kinzan'),
('コシヒカリ', '日本一の米どころ南魚沼で育まれた最高級コシヒカリ。その美味しさは折り紙付き。', 'epic', 'nature', 60, 70, 45, 95, 'https://placehold.co/400x600/ffffff/000000?text=Koshihikari'),
('上杉謙信', '越後の龍と称された戦国最強の武将。義を重んじ、毘沙門天の化身とも呼ばれた軍神。', 'legendary', 'other', 99, 85, 90, 80, 'https://placehold.co/400x600/000080/ffffff?text=Kenshin'),
('柿の種', '新潟発祥の国民的おやつ。ピリ辛でやみつきになる味。', 'common', 'artifact', 40, 30, 60, 85, 'https://placehold.co/400x600/ff8c00/ffffff?text=Kaki+no+Tane'),
('笹団子', '笹の葉で包まれた緑色のお餅。ヨモギの香りと餡の甘さが絶妙。', 'common', 'artifact', 30, 40, 50, 75, 'https://placehold.co/400x600/006400/ffffff?text=Sasadango');
