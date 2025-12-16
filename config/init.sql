-- PostgREST Database Initialization Script
--
-- ⚠️  IMPORTANT: This script runs AUTOMATICALLY on every deployment via App Platform jobs
--
-- What this script does:
--   1. Creates a sample 'todos' table in the public schema
--   2. Creates a 'todos_stats' view for aggregated statistics
--   3. Inserts sample data to test the API immediately
--
-- ✏️  CUSTOMIZE THIS SCRIPT:
--   - Edit this file to add your own tables, views, and functions
--   - Remove or modify the sample 'todos' table as needed
--   - All tables/views are created in the 'public' schema (default for App Platform dev databases)
--   - This script is idempotent - safe to run multiple times
--
-- 📚  Learn more: https://postgrest.org/en/stable/tutorials/tut0.html
--
-- 💡 NOTE: App Platform dev databases don't allow creating custom schemas or roles.
--    We use the 'public' schema and the default database user instead.

-- Create a sample table in the public schema
CREATE TABLE IF NOT EXISTS public.todos (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Insert sample data (idempotent - won't create duplicates)
INSERT INTO public.todos (title, completed) VALUES
  ('Learn PostgREST', false),
  ('Deploy to App Platform', false),
  ('Build amazing APIs', false)
ON CONFLICT DO NOTHING;

-- Create a sample view
CREATE OR REPLACE VIEW public.todos_stats AS
  SELECT
    COUNT(*) as total,
    COUNT(*) FILTER (WHERE completed) as completed_count,
    COUNT(*) FILTER (WHERE NOT completed) as pending_count
  FROM public.todos;

-- Create a welcome view with API usage examples (accessible at /welcome)
CREATE OR REPLACE VIEW public.welcome AS
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

-- Log completion
DO $$
BEGIN
  RAISE NOTICE 'PostgREST database initialized successfully!';
  RAISE NOTICE 'Sample table: public.todos';
  RAISE NOTICE 'Sample views: public.todos_stats, public.welcome';
  RAISE NOTICE '';
  RAISE NOTICE 'Available endpoints:';
  RAISE NOTICE '  GET /welcome - API usage guide with curl examples ⭐';
  RAISE NOTICE '  GET /todos - List all todos';
  RAISE NOTICE '  GET /todos_stats - View statistics';
  RAISE NOTICE '  GET / - Full OpenAPI documentation';
END $$;
