-- Allow users to insert/update their own items (For prototype testing only)
CREATE POLICY "Users can insert own items" ON user_items FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own items" ON user_items FOR UPDATE USING (auth.uid() = user_id);
