-- Enable RLS on users table (already enabled but good to be explicit)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy to allow users to insert their own profile
CREATE POLICY "Users can insert their own profile" 
ON users FOR INSERT 
WITH CHECK (auth.uid() = id);

-- Policy to allow users to update their own profile
CREATE POLICY "Users can update their own profile" 
ON users FOR UPDATE 
USING (auth.uid() = id);

-- Policy to allow users to select their own profile
CREATE POLICY "Users can select their own profile" 
ON users FOR SELECT 
USING (auth.uid() = id);
