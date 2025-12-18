# Local Development Guide

Run PostgREST locally for development and testing.

## Quick Start

```bash
git clone https://github.com/AppPlatform-Templates/postgrest-appplatform.git
cd postgrest-appplatform
docker-compose up
```

**Access**:
- API: http://127.0.0.1:3000
- PostgreSQL: 127.0.0.1:5432 (user: `postgres`, password: `postgres`)

The database initializes automatically using `config/init.sql` with sample `todos` data.

## API Examples

**View API guide**:
```bash
curl http://127.0.0.1:3000/welcome
```

**List all todos**:
```bash
curl http://127.0.0.1:3000/todos
```

**Create a todo**:
```bash
curl -X POST http://127.0.0.1:3000/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"New task","completed":false}'
```

**Update a todo**:
```bash
curl -X PATCH "http://127.0.0.1:3000/todos?id=eq.1" \
  -H "Content-Type: application/json" \
  -d '{"completed":true}'
```

**Delete a todo**:
```bash
curl -X DELETE "http://127.0.0.1:3000/todos?id=eq.1"
```

**Get statistics**:
```bash
curl http://127.0.0.1:3000/todos_stats
```

**OpenAPI docs**: http://127.0.0.1:3000/

## Database Access

```bash
# Connect via Docker
docker exec -it postgrest-db psql -U postgres

# Or from host (requires psql)
psql -h 127.0.0.1 -U postgres -d postgres
```

## Development Workflow

**Modify database schema**:
1. Edit `config/init.sql`
2. Rebuild: `docker-compose down -v && docker-compose up`

**Modify PostgREST config**:
1. Edit `config/postgrest.conf` or `docker-compose.yml`
2. Restart: `docker-compose restart postgrest`

## Advanced

**Expose multiple schemas**:
```yaml
# docker-compose.yml
environment:
  - PGRST_DB_SCHEMAS=api,admin,public
```
Access at: `/api/*`, `/admin/*`, `/public/*`

**Enable JWT auth**: See [PostgREST Authentication](https://postgrest.org/en/stable/tutorials/tut1.html)

**Row-level security**: See [PostgreSQL RLS](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
