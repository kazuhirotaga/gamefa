-- Add unique constraint to user_quests to allow upsert
ALTER TABLE user_quests ADD CONSTRAINT user_quests_user_id_quest_id_key UNIQUE (user_id, quest_id);
