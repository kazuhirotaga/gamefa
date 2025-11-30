-- Insert a default facility for testing/prototyping
INSERT INTO facilities (id, name, type, location, address, region_id)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'Default Park',
    'public',
    'POINT(139.6917 35.6895)',
    'Tokyo, Japan',
    'tokyo'
)
ON CONFLICT (id) DO NOTHING;
