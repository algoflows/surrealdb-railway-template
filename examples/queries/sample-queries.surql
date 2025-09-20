-- SurrealDB Sample Queries
-- These examples demonstrate various SurrealDB features and capabilities

-- =====================================
-- 1. BASIC CRUD OPERATIONS
-- =====================================

-- Create users table with sample data
CREATE users:john SET 
    name = 'John Doe',
    email = 'john@example.com',
    age = 30,
    active = true,
    created_at = time::now();

CREATE users:jane SET 
    name = 'Jane Smith', 
    email = 'jane@example.com',
    age = 28,
    active = true,
    created_at = time::now();

-- Select all users
SELECT * FROM users;

-- Update user
UPDATE users:john SET age = 31, last_login = time::now();

-- Delete user (commented out for safety)
-- DELETE users:john;

-- =====================================
-- 2. ADVANCED QUERIES
-- =====================================

-- Query with conditions and sorting
SELECT * FROM users 
WHERE age > 25 AND active = true 
ORDER BY created_at DESC;

-- Aggregation queries
SELECT 
    count() as total_users,
    math::mean(age) as average_age,
    math::max(age) as oldest_user,
    math::min(age) as youngest_user
FROM users;

-- String operations
SELECT 
    name,
    string::uppercase(name) as name_upper,
    string::len(email) as email_length,
    string::split(email, '@') as email_parts
FROM users;

-- =====================================
-- 3. GRAPH RELATIONSHIPS
-- =====================================

-- Create posts
CREATE posts:post1 SET 
    title = 'Introduction to SurrealDB',
    content = 'SurrealDB is a revolutionary database...',
    published = true,
    created_at = time::now();

CREATE posts:post2 SET 
    title = 'Advanced SurrealDB Features',
    content = 'Let\'s explore advanced features...',
    published = false,
    created_at = time::now();

-- Create relationships
RELATE users:john->wrote->posts:post1 SET created_at = time::now();
RELATE users:jane->wrote->posts:post2 SET created_at = time::now();

-- Create follow relationships
RELATE users:john->follows->users:jane SET since = time::now();

-- Query with graph traversal
SELECT *,
    ->wrote->posts as authored_posts,
    ->follows->users.name as following,
    <-follows<-users.name as followers
FROM users;

-- Complex graph query
SELECT * FROM users WHERE ->wrote->posts[WHERE published = true];

-- =====================================
-- 4. GEOSPATIAL QUERIES
-- =====================================

-- Create locations with coordinates
CREATE locations:nyc SET 
    name = 'New York City',
    coordinates = { latitude: 40.7128, longitude: -74.0060 },
    population = 8400000;

CREATE locations:la SET 
    name = 'Los Angeles',
    coordinates = { latitude: 34.0522, longitude: -118.2437 },
    population = 3900000;

-- Find locations within distance
SELECT * FROM locations 
WHERE geo::distance(coordinates, { latitude: 40.7589, longitude: -73.9851 }) < 50000;

-- =====================================
-- 5. TIME-BASED QUERIES
-- =====================================

-- Create events with timestamps
CREATE events:event1 SET 
    name = 'Database Conference',
    start_time = time::now() + 1w,
    end_time = time::now() + 1w + 8h,
    location = 'San Francisco';

-- Query events in date range
SELECT * FROM events 
WHERE start_time > time::now() 
AND start_time < time::now() + 1mo;

-- Format dates
SELECT 
    name,
    time::format(start_time, '%Y-%m-%d %H:%M') as formatted_start,
    time::group(start_time, 'day') as day_group
FROM events;

-- =====================================
-- 6. ARRAY AND OBJECT OPERATIONS
-- =====================================

-- Create user with complex data
CREATE users:complex SET 
    name = 'Complex User',
    tags = ['developer', 'database', 'surreal'],
    preferences = {
        theme: 'dark',
        notifications: true,
        language: 'en'
    },
    addresses = [
        { type: 'home', street: '123 Main St', city: 'Anytown' },
        { type: 'work', street: '456 Office Blvd', city: 'Business City' }
    ];

-- Query array elements
SELECT * FROM users WHERE 'developer' IN tags;

-- Access object properties
SELECT 
    name,
    preferences.theme as theme,
    addresses[WHERE type = 'home'][0].city as home_city
FROM users:complex;

-- =====================================
-- 7. FULL-TEXT SEARCH
-- =====================================

-- Search in text fields
SELECT * FROM posts 
WHERE string::lowercase(title) CONTAINS 'surrealdb'
OR string::lowercase(content) CONTAINS 'database';

-- Search with scoring (manual implementation)
SELECT *,
    (
        (string::lowercase(title) CONTAINS 'surrealdb') * 2 +
        (string::lowercase(content) CONTAINS 'surrealdb') * 1
    ) as relevance_score
FROM posts 
WHERE relevance_score > 0
ORDER BY relevance_score DESC;

-- =====================================
-- 8. TRANSACTIONS
-- =====================================

-- Transaction example
BEGIN TRANSACTION;

LET $user = CREATE users SET 
    name = 'Transaction User',
    email = 'tx@example.com',
    balance = 1000;

LET $account = CREATE accounts SET 
    user = $user.id,
    balance = $user.balance,
    created_at = time::now();

UPDATE $user SET account = $account.id;

COMMIT TRANSACTION;

-- =====================================
-- 9. CONDITIONAL LOGIC
-- =====================================

-- Using IF/ELSE in queries
SELECT 
    name,
    age,
    IF age >= 18 THEN 'Adult' ELSE 'Minor' END as age_group,
    IF active THEN 'Active User' ELSE 'Inactive User' END as status
FROM users;

-- CASE statements
SELECT 
    name,
    CASE 
        WHEN age < 18 THEN 'Minor'
        WHEN age < 65 THEN 'Adult' 
        ELSE 'Senior'
    END as life_stage
FROM users;

-- =====================================
-- 10. MATHEMATICAL OPERATIONS
-- =====================================

-- Math functions
SELECT 
    math::abs(-42) as absolute_value,
    math::ceil(3.14) as ceiling,
    math::floor(3.99) as floor,
    math::round(3.14159, 2) as rounded,
    math::sqrt(16) as square_root,
    math::pow(2, 8) as power;

-- Statistical functions on user ages
SELECT 
    math::mean(age) as mean_age,
    math::median(age) as median_age,
    math::mode(age) as mode_age,
    math::stddev(age) as stddev_age,
    math::variance(age) as variance_age
FROM users;

-- =====================================
-- 11. UTILITY QUERIES
-- =====================================

-- Get database info
INFO FOR DB;

-- Get table info
INFO FOR TABLE users;

-- Get current time
SELECT time::now() as current_time;

-- Generate random data
SELECT 
    rand::uuid() as random_id,
    rand::int(1, 100) as random_number,
    rand::string(10) as random_string;

-- =====================================
-- 12. CLEANUP (Optional)
-- =====================================

-- Remove sample data (uncomment if needed)
-- REMOVE TABLE users;
-- REMOVE TABLE posts; 
-- REMOVE TABLE locations;
-- REMOVE TABLE events;
-- REMOVE TABLE accounts;
