# PostgREST on DigitalOcean App Platform

A production-ready template for deploying [PostgREST](https://postgrest.org) on DigitalOcean App Platform. Automatically generates a RESTful API from your PostgreSQL database schema.

**✨ Zero-configuration deployment** - Database automatically initialized with working API endpoints!

[![Deploy to DO](https://www.deploytodo.com/do-btn-blue.svg)](https://cloud.digitalocean.com/apps/new?repo=https://github.com/AppPlatform-Templates/postgrest-appplatform/tree/main)

## What is PostgREST?

PostgREST is a standalone web server that transforms your PostgreSQL database directly into a RESTful API. The database schema and permissions define the API endpoints and operations automatically.

## Use Cases

- **Rapid API Development**: Build REST APIs instantly from existing PostgreSQL databases
- **Database-First Architecture**: Define your API through PostgreSQL schemas and functions
- **Serverless Data Layer**: Lightweight API server with minimal resource footprint
- **Microservices Backend**: Expose specific database schemas as independent services

## What's Included

**Components**:
1. **PostgREST Server** - REST API server (port 3000)
2. **PostgreSQL Database** - Dev database via App Platform (production: false)
3. **Sample Schema** - Example `public.todos` table and `public.todos_stats` view

**Endpoints**:
- `/welcome` - Simple API usage guide with curl examples (⭐ **Start here!**)
- `/todos` - CRUD operations on the todos table
- `/todos_stats` - Read-only view of todo statistics
- `/` - Full OpenAPI documentation (advanced users)

## Architecture

```
┌─────────────────────────────────────┐
│   DigitalOcean App Platform         │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  PostgREST Service (Port 3000)│  │
│  │                               │  │
│  │  ┌────────────────────────┐   │  │
│  │  │   PostgREST Server     │   │  │
│  │  │  Automatic REST API    │   │  │
│  │  └──────────┬─────────────┘   │  │
│  │             │                 │  │
│  └─────────────┼─────────────────┘  │
│                │                    │
│  ┌─────────────▼─────────────────┐  │
│  │   Managed PostgreSQL DB       │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

## Project Structure

```
postgrest-appplatform/
├── .do/
│   ├── app.yaml                     # App Platform deployment spec
│   └── deploy.template.yaml         # Deploy button template
├── config/
│   ├── postgrest.conf               # PostgREST configuration
│   └── init.sql                     # Database initialization script
├── Dockerfile                       # Container definition
├── docker-compose.yml               # Local development setup
├── start.sh                         # Container startup script
├── Makefile                         # Development commands
├── README.md                        # Main documentation
└── LOCAL_DEVELOPMENT.md             # Local development guide
```

## Deployment Methods

### One-Click Deploy

Click the "Deploy to DigitalOcean" button above to deploy instantly with zero configuration.
This uses the Development mode configuration mentioned below.

### Deploy via CLI

**Development/Testing** (uses dev database with `public` schema):
```bash
# Clone the repository
git clone https://github.com/AppPlatform-Templates/postgrest-appplatform.git
cd postgrest-appplatform

# Deploy to App Platform
doctl apps create --spec .do/app.yaml
```

**Production** (uses managed database with `api` schema and `anon` role):

**Prerequisites: (⚠️ MUST DO)**
- Create PostgreSQL: `doctl databases create postgrest-db --engine pg --version 16 --region <region> --size db-s-1vcpu-1gb`

```bash
# Deploy with production configuration
doctl apps create --spec .do/production-app.yaml
```

The database will be **automatically initialized** with a sample schema on first deployment. Your API will be immediately functional with example endpoints!

**Key differences:**
- **Dev template**: Uses `public` schema, default user, smaller resources
- **Production template**: Uses `api` schema, dedicated `anon` role, larger resources, better security

### Deploy Your Own Fork

1. Fork this repository to your GitHub account
2. Update `.do/app.yaml` or `.do/production-app.yaml` to point to your fork
3. Deploy using `doctl apps create --spec .do/app.yaml` or `doctl apps create --spec .do/production-app.yaml`

## Local Development

**Quick Start:**
```bash
docker-compose up
```

Access the API at `http://127.0.0.1:3000`

**📖 See [LOCAL_DEVELOPMENT.md](LOCAL_DEVELOPMENT.md)** for complete setup instructions, API examples, troubleshooting, and advanced configuration.

## Automatic Database Initialization

On deployment, the database is **automatically initialized** with:
- ✅ Sample `todos` table with example data (for demo purposes)
- ✅ Sample `todos_stats` view for aggregated statistics
- ✅ All necessary permissions configured automatically

This happens via a **PRE_DEPLOY job** (`db-init`) that runs `config/init.sql` or `config/init.production.sql` before the PostgREST service starts.

**Note on Schema and Roles**: App Platform dev databases (`production: false`) use the `public` schema and default database user. This template is optimized for these constraints. For production deployments with custom schemas and roles, consider using a full managed PostgreSQL database.

### Using Your Own Database in Production

**The `db-init` job is optional** - it's primarily for demo purposes to showcase PostgREST functionality. If you have your own production database with existing schema:

1. **Remove the db-init job** from `.do/app.yaml` or `.do/production-app.yaml`:
   ```yaml
   # Remove or comment out the entire jobs section
   # jobs:
   #   - name: db-init
   #     ...
   ```

2. **Point to your existing database** by updating the database reference in the service environment variables

3. **Ensure your database has**:
   - A schema exposed via PostgREST (set in `PGRST_DB_SCHEMAS`)
   - Appropriate role permissions (set in `PGRST_DB_ANON_ROLE`)

4. **Deploy** - PostgREST will automatically generate API endpoints from your existing schema

### Why Sample Data?

The sample `todos` table lets you:
- ✅ Test the API immediately after deployment
- ✅ See a working example of CRUD operations
- ✅ Understand the schema structure

**You can safely delete the sample data** once you've explored it!

## Customizing Your API

To customize the API for your use case:

1. **Edit** `config/init.sql` or `config/init.production.sql` to add your own tables, views, and functions
2. **Keep** the schema and role setup (required for PostgREST)
3. **Remove or modify** the sample `todos` table as needed
4. **Commit and push** - the init script runs automatically on every deployment
5. **Deploy** - PostgREST automatically generates endpoints for your schema

## Resources

- [PostgREST Documentation](https://postgrest.org/)
- [DigitalOcean App Platform Documentation](https://docs.digitalocean.com/products/app-platform/)
- [App Spec Reference](https://docs.digitalocean.com/products/app-platform/reference/app-spec/)
- [Local Development Guide](LOCAL_DEVELOPMENT.md)

## Getting Help

- **GitHub Issues**: [Report bugs or request features](https://github.com/AppPlatform-Templates/postgrest-appplatform/issues)
- **DigitalOcean Community**: [community.digitalocean.com](https://www.digitalocean.com/community)
- **Support**: [DigitalOcean Support](https://www.digitalocean.com/support/)
