-- Allow authenticated users (Admin App users) to view and edit all user data
-- Note: In a production app, you would check for a specific 'admin' role or claim.
-- For this prototype, we assume any authenticated user using the Admin App is an admin.

-- Users table
CREATE POLICY "Admins can view all profiles" ON users FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Admins can update all profiles" ON users FOR UPDATE USING (auth.role() = 'authenticated');

-- User Items
CREATE POLICY "Admins can view all user items" ON user_items FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Admins can insert user items" ON user_items FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Admins can update user items" ON user_items FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Admins can delete user items" ON user_items FOR DELETE USING (auth.role() = 'authenticated');

-- User Cards
CREATE POLICY "Admins can view all user cards" ON user_cards FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Admins can insert user cards" ON user_cards FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Admins can update user cards" ON user_cards FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Admins can delete user cards" ON user_cards FOR DELETE USING (auth.role() = 'authenticated');

-- User Quests
CREATE POLICY "Admins can view all user quests" ON user_quests FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Admins can update user quests" ON user_quests FOR UPDATE USING (auth.role() = 'authenticated');
