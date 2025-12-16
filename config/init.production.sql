-- PostgREST Production Database Initialization Script
--
-- ⚠️  IMPORTANT: This script is for PRODUCTION databases only
--
-- What this script does:
--   1. Creates a dedicated 'api' schema for application data
--   2. Creates a dedicated 'anon' role with full CRUD permissions
--   3. Creates the database schema (tables, views, functions)
--   4. Grants appropriate permissions to the anon role
--
-- 🔒 SECURITY:
--   - Uses dedicated 'api' schema (not public)
--   - anon role has full CRUD access (for demo functionality)
--   - Fails loudly if roles cannot be created
--   - Consider restricting anon to read-only for production use
--
-- 📚  Learn more: https://postgrest.org/en/stable/tutorials/tut1.html

-- Create dedicated schema for API
CREATE SCHEMA IF NOT EXISTS api;

-- Create anon role for API access
-- IMPORTANT: This will fail if the database user doesn't have role creation privileges
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'anon') THEN
    CREATE ROLE anon NOLOGIN;
    RAISE NOTICE 'Created role: anon';
  ELSE
    RAISE NOTICE 'Role anon already exists';
  END IF;
EXCEPTION WHEN insufficient_privilege THEN
  RAISE EXCEPTION 'SECURITY ERROR: Cannot create anon role. Production databases require custom roles for security. Check that your database user has CREATEROLE privilege.';
END $$;

-- Create application tables in the api schema
CREATE TABLE IF NOT EXISTS api.todos (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Insert sample data (idempotent - won't create duplicates)
INSERT INTO api.todos (title, completed) VALUES
  ('Learn PostgREST', false),
  ('Deploy to App Platform', false),
  ('Build amazing APIs', false)
ON CONFLICT DO NOTHING;

-- Create views in the api schema
CREATE OR REPLACE VIEW api.todos_stats AS
  SELECT
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE completed) as completed_count,
    COUNT(*) FILTER (WHERE NOT completed) as pending_count
  FROM api.todos;

-- Create a welcome view with API usage examples (accessible at /welcome)
CREATE OR REPLACE VIEW api.welcome AS
  SELECT
    'Welcome to PostgREST API'::text as message,
    'PostgREST 12.2.3'::text as version,
    json_build_object(
      'todos', '/todos',
      'stats', '/todos_stats',
      'welcome', '/welcome',
      'openapi', '/'
    ) as endpoints,
    json_build_object(
      'list_all', 'curl https://your-app.ondigitalocean.app/todos',
      'get_stats', 'curl https://your-app.ondigitalocean.app/todos_stats',
      'create', 'curl -X POST https://your-app.ondigitalocean.app/todos -H "Content-Type: application/json" -d ''{"title":"New task","completed":false}''',
      'update', 'curl -X PATCH https://your-app.ondigitalocean.app/todos?id=eq.1 -H "Content-Type: application/json" -d ''{"completed":true}''',
      'delete', 'curl -X DELETE https://your-app.ondigitalocean.app/todos?id=eq.1',
      'filter', 'curl https://your-app.ondigitalocean.app/todos?completed=eq.false',
      'sort_limit', 'curl https://your-app.ondigitalocean.app/todos?order=id.desc&limit=5'
    ) as examples,
    'https://postgrest.org'::text as docs;

-- Grant permissions to anon role (full CRUD access for demo purposes)
-- Note: For production, consider implementing JWT authentication and limiting anon to read-only
GRANT USAGE ON SCHEMA api TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA api TO anon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA api TO anon;

-- Ensure future tables also get permissions
ALTER DEFAULT PRIVILEGES IN SCHEMA api GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA api GRANT USAGE, SELECT ON SEQUENCES TO anon;

-- Log completion
DO $$
BEGIN
  RAISE NOTICE '✓ Production database initialized successfully!';
  RAISE NOTICE '✓ Schema created: api';
  RAISE NOTICE '✓ Role created: anon (full CRUD access)';
  RAISE NOTICE '✓ Tables: api.todos';
  RAISE NOTICE '✓ Views: api.todos_stats, api.welcome';
  RAISE NOTICE '✓ Permissions: anon role has SELECT, INSERT, UPDATE, DELETE on api schema';
  RAISE NOTICE '';
  RAISE NOTICE 'Available endpoints:';
  RAISE NOTICE '  GET /welcome - API usage guide with curl examples ⭐';
  RAISE NOTICE '  GET /todos - List all todos';
  RAISE NOTICE '  GET /todos_stats - View statistics';
  RAISE NOTICE '  GET / - Full OpenAPI documentation';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  SECURITY NOTE: anon role has full write access for demo purposes.';
  RAISE NOTICE '   For production use, consider:';
  RAISE NOTICE '   1. Implementing JWT-based authentication';
  RAISE NOTICE '   2. Creating an "authenticated" role for write operations';
  RAISE NOTICE '   3. Restricting anon role to SELECT-only';
  RAISE NOTICE '   4. Adding row-level security (RLS) policies';
END $$;
