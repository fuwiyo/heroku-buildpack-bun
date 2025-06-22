# Deployment Guide - Heroku Bun Buildpack

This guide will walk you through deploying your Bun application to Heroku using this buildpack.

## Prerequisites

- [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) installed
- Git repository with your Bun application
- Heroku account

## Quick Deployment

### 1. Prepare Your Bun Application

Ensure your app has the following structure:

```
your-bun-app/
├── package.json          # Required: Contains your app configuration
├── index.ts              # Your main application file
├── .bun-version          # Optional: Pin Bun version
├── bun.lock              # Optional: Lockfile (text format, v1.2+)
├── Procfile              # Optional: Process definitions
└── bunfig.toml           # Optional: Bun configuration
```

### 2. Configure package.json

Your `package.json` should include:

```json
{
  "name": "my-bun-app",
  "scripts": {
    "start": "bun run index.ts",
    "build": "bun build src/index.ts --outdir=dist"
  },
  "engines": {
    "bun": "^1.2.0"
  },
  "packageManager": "bun@1.2.17",
  "dependencies": {
    "hono": "^3.12.0"
  }
}
```

### 3. Create a Heroku App

```bash
# Create a new Heroku app
heroku create your-app-name

# Or use an existing app
heroku git:remote -a your-existing-app
```

### 4. Set the Buildpack

```bash
# Option 1: Use this buildpack from GitHub (recommended)
heroku buildpacks:set https://github.com/your-username/heroku-buildpack-bun

# Option 2: Use local buildpack for testing
heroku buildpacks:set file:///path/to/this/buildpack
```

### 5. Deploy

```bash
git add .
git commit -m "Initial Bun app"
git push heroku main
```

## Advanced Configuration

### Environment Variables

Set environment variables for your app:

```bash
# Set Node environment
heroku config:set NODE_ENV=production

# Override Bun version
heroku config:set BUN_VERSION_OVERRIDE=1.2.17

# Set custom port (Heroku automatically sets PORT)
heroku config:set PORT=3000
```

### Process Types (Procfile)

Create a `Procfile` to define process types:

```
web: bun run index.ts
worker: bun run worker.ts
cron: bun run cron.ts
```

### Build Configuration

#### Skip Build Steps

Create these files to skip specific build steps:

```bash
# Skip dependency installation
touch .skip-bun-install

# Skip build script
touch .skip-bun-build

# Skip heroku-prebuild script
touch .skip-bun-heroku-prebuild

# Skip heroku-postbuild script
touch .skip-bun-heroku-postbuild
```

#### Build Scripts

Use these npm scripts for build automation:

```json
{
  "scripts": {
    "heroku-prebuild": "echo 'Running before dependency installation'",
    "build": "bun build src/index.ts --outdir=dist",
    "heroku-postbuild": "echo 'Running after build completion'",
    "start": "bun run dist/index.js"
  }
}
```

### Bun Configuration (bunfig.toml)

Configure Bun behavior:

```toml
[install]
# Use exact versions
exact = true

# Configure registry
registry = "https://registry.npmjs.org"

# Configure cache
cache = true

[install.scopes]
# Scoped packages
"@mycompany" = "https://npm.mycompany.com"

[run]
# Shell for script execution
shell = "/bin/bash"
```

## Example Applications

### Basic Web Server

```typescript
// index.ts
const server = Bun.serve({
  port: process.env.PORT || 3000,
  fetch(req) {
    return new Response("Hello from Bun on Heroku!");
  },
});

console.log(`Server running on port ${server.port}`);
```

```json
// package.json
{
  "name": "basic-bun-server",
  "scripts": {
    "start": "bun run index.ts"
  },
  "engines": {
    "bun": "^1.2.0"
  }
}
```

### Hono Web Framework

```typescript
// index.ts
import { Hono } from 'hono'

const app = new Hono()

app.get('/', (c) => {
  return c.json({
    message: 'Hello from Bun + Hono on Heroku!',
    timestamp: new Date().toISOString()
  })
})

export default {
  port: process.env.PORT || 3000,
  fetch: app.fetch,
}
```

```json
// package.json
{
  "name": "hono-bun-app",
  "scripts": {
    "start": "bun run index.ts",
    "dev": "bun run --watch index.ts"
  },
  "dependencies": {
    "hono": "^3.12.0"
  },
  "engines": {
    "bun": "^1.2.0"
  },
  "packageManager": "bun@1.2.17"
}
```

### Full-Stack Application

```typescript
// src/server.ts
import { Hono } from 'hono'
import { serveStatic } from 'hono/serve-static'

const app = new Hono()

// Serve static files
app.use('/static/*', serveStatic({ root: './public' }))

// API routes
app.get('/api/health', (c) => c.json({ status: 'ok' }))

// Catch-all for SPA
app.get('*', serveStatic({ path: './public/index.html' }))

export default {
  port: process.env.PORT || 3000,
  fetch: app.fetch,
}
```

```json
// package.json
{
  "name": "fullstack-bun-app",
  "scripts": {
    "build": "bun run build:client && bun run build:server",
    "build:client": "bun build src/client/index.ts --outdir=public",
    "build:server": "bun build src/server.ts --outdir=dist",
    "start": "bun run dist/server.js",
    "dev": "bun run --watch src/server.ts"
  },
  "dependencies": {
    "hono": "^3.12.0"
  },
  "devDependencies": {
    "@types/bun": "latest"
  },
  "engines": {
    "bun": "^1.2.0"
  }
}
```

## Troubleshooting

### Common Issues

#### 1. Build Fails with "Bun not found"

**Problem**: Buildpack detection failed or Bun installation failed.

**Solutions**:
- Ensure you have a `package.json` with Bun configuration
- Add `.bun-version` file with a valid version
- Check buildpack is set correctly: `heroku buildpacks`

#### 2. Dependencies Not Installing

**Problem**: `bun install` fails or dependencies missing.

**Solutions**:
- Verify `package.json` is valid JSON
- Check for private dependencies (not supported in build environment)
- Remove `.skip-bun-install` if present

#### 3. App Crashes on Startup

**Problem**: Application fails to start after deployment.

**Solutions**:
- Check your `Procfile` or `package.json` start script
- Ensure your app listens on `process.env.PORT`
- Check logs: `heroku logs --tail`

#### 4. Build Takes Too Long

**Problem**: Build process times out or takes excessive time.

**Solutions**:
- Use build cache by not clearing it frequently
- Optimize build scripts
- Consider skipping unnecessary build steps

### Debug Commands

```bash
# View build logs
heroku logs --tail --dyno=build

# Check buildpack configuration
heroku buildpacks

# View app logs
heroku logs --tail

# Access app shell
heroku run bash

# Check Bun version in deployed app
heroku run bun --version

# View environment variables
heroku config

# Restart app
heroku restart

# Scale app
heroku ps:scale web=1
```

### Performance Optimization

#### 1. Enable Build Cache

The buildpack automatically caches Bun binaries and dependencies. Don't clear cache unless necessary:

```bash
# Only clear if experiencing cache issues
heroku builds:cache:purge
```

#### 2. Lockfile Management

The buildpack supports both Bun lockfile formats:

- **bun.lock** (text format, default since v1.2) - Commit this to git
- **bun.lockb** (binary format, legacy) - Should be excluded from git

```bash
# For projects with text lockfile (recommended)
git add bun.lock

# For legacy projects, exclude binary lockfile
echo "bun.lockb" >> .gitignore
```

#### 2. Optimize Dependencies

```json
{
  "scripts": {
    "heroku-postbuild": "bun install --production"
  }
}
```

#### 3. Use Bun's Speed

```typescript
// Take advantage of Bun's fast startup
console.time('startup')
// Your app initialization
console.timeEnd('startup')
```

## Monitoring

### Health Checks

```typescript
// Add health check endpoint
app.get('/health', (c) => {
  return c.json({
    status: 'healthy',
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    version: Bun.version
  })
})
```

### Logging

```typescript
// Structured logging for Heroku
console.log(JSON.stringify({
  level: 'info',
  message: 'Server started',
  port: process.env.PORT,
  timestamp: new Date().toISOString()
}))
```

## Security Best Practices

1. **Environment Variables**: Never commit secrets to git
   ```bash
   heroku config:set DATABASE_URL=postgresql://...
   heroku config:set API_KEY=your-secret-key
   ```

2. **Dependencies**: Keep dependencies updated
   ```bash
   bun update
   ```

3. **Lockfiles**: Always commit your lockfile for reproducible builds
   ```bash
   # For Bun v1.2+ (text format)
   git add bun.lock
   
   # Never commit binary lockfiles
   echo "bun.lockb" >> .gitignore
   ```

4. **HTTPS**: Heroku provides HTTPS by default for `*.herokuapp.com`

5. **CORS**: Configure CORS for API endpoints
   ```typescript
   import { cors } from 'hono/cors'
   app.use('*', cors())
   ```

## Support

- [Buildpack Issues](https://github.com/your-username/heroku-buildpack-bun/issues)
- [Bun Documentation](https://bun.sh/docs)
- [Heroku Documentation](https://devcenter.heroku.com/)
- [Heroku Support](https://help.heroku.com/)