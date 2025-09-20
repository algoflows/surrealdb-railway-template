-- Idempotent example schema and seed
USE NS app; USE DB app;

-- Example: users table
DEFINE TABLE users SCHEMAFULL;
DEFINE FIELD name ON users TYPE string;
DEFINE FIELD email ON users TYPE string ASSERT string::is::email($value);
DEFINE INDEX idx_users_email ON users COLUMNS email UNIQUE;

-- Seed if not exists
LET $exists = SELECT count() AS c FROM users WHERE email = 'admin@example.com';
IF $exists[0].c = 0 THEN {
  CREATE users SET name = 'Admin', email = 'admin@example.com';
};

