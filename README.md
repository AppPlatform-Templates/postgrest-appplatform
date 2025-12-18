# PostgREST on DigitalOcean App Platform

A production-ready template for deploying [PostgREST](https://postgrest.org) on DigitalOcean App Platform. Automatically generates a RESTful API from your PostgreSQL database schema.

[![Deploy to DO](https://www.deploytodo.com/do-btn-blue.svg)](https://cloud.digitalocean.com/apps/new?repo=https://github.com/AppPlatform-Templates/postgrest-appplatform/tree/main)

## What is PostgREST?

PostgREST transforms your PostgreSQL database directly into a RESTful API. The database schema and permissions define the API endpoints automatically - no backend code required.

**Use Cases**: Rapid API development, database-first architecture, lightweight data layer for microservices.

**What's Included**:
- PostgREST Server (automatic REST API generation)
- PostgreSQL Database (managed by App Platform)
- Sample `todos` table with working endpoints (`/welcome`, `/todos`, `/todos_stats`)

## Quick Start

### One-Click Deploy

Click the **Deploy to DigitalOcean** button above for instant deployment with sample data.

### Deploy via CLI

**Development** (includes dev database with sample data):
```bash
git clone https://github.com/AppPlatform-Templates/postgrest-appplatform.git
cd postgrest-appplatform
doctl apps create --spec .do/app.yaml
```

**Production** (uses your existing database with autoscaling):
```bash
# 1. Create a PostgreSQL database
doctl databases create postgrest-db --engine pg --version 16 --region nyc3 --size db-s-1vcpu-1gb

# 2. Deploy the app
doctl apps create --spec .do/production-app.yaml
```

Your API will be immediately functional with example endpoints at `/welcome`, `/todos`, and `/todos_stats`.

**Production features**: Autoscaling (1-3 instances), dedicated `api` schema, `anon` role for security.

## Local Development

```bash
# Optional: Create .env file for custom credentials
cp .env.example .env

# Start services
docker-compose up
# Access API at http://127.0.0.1:3000
```

See [LOCAL_DEVELOPMENT.md](LOCAL_DEVELOPMENT.md) for API examples and troubleshooting.

## Customization

### Using Sample Data (Default)

The template includes a `db-init` PRE_DEPLOY job that initializes your database with:
- Sample `todos` table with example data
- Sample `todos_stats` view
- Required permissions

**Files**: `config/init.sql` (dev) or `config/init.production.sql` (production)

**To customize**: Edit these files to add your own tables, views, and functions. The init script runs on every deployment.

### Using Your Own Database

**The `db-init` job is optional.** To use an existing database with your own schema:

1. **Remove the jobs section** from `.do/app.yaml` or `.do/production-app.yaml`
2. **Update environment variables**:
   - `PGRST_DB_SCHEMAS` - your schema name(s)
   - `PGRST_DB_ANON_ROLE` - database role for API access
3. **Deploy** - PostgREST auto-generates endpoints from your schema

**Note**: Production databases should use dedicated schemas (not `public`) and roles (not default user) for security.

## Resources

- [PostgREST Documentation](https://postgrest.org/)
- [DigitalOcean App Platform Documentation](https://docs.digitalocean.com/products/app-platform/)
- [App Spec Reference](https://docs.digitalocean.com/products/app-platform/reference/app-spec/)
- [Local Development Guide](LOCAL_DEVELOPMENT.md)

## Getting Help

- **GitHub Issues**: [Report bugs or request features](https://github.com/AppPlatform-Templates/postgrest-appplatform/issues)
- **DigitalOcean Community**: [community.digitalocean.com](https://www.digitalocean.com/community)
- **Support**: [DigitalOcean Support](https://www.digitalocean.com/support/)
