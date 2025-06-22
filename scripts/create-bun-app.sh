#!/usr/bin/env bash
# Create a new Bun app ready for Heroku deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $*"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $*"
}

# Check if app name is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <app-name> [template]"
  echo
  echo "Templates:"
  echo "  basic    - Basic Bun server (default)"
  echo "  hono     - Hono web framework"
  echo "  api      - REST API with Hono"
  echo "  fullstack - Full-stack app with static files"
  echo
  echo "Example: $0 my-bun-app hono"
  exit 1
fi

APP_NAME="$1"
TEMPLATE="${2:-basic}"

# Validate app name
if [[ ! "$APP_NAME" =~ ^[a-z0-9-]+$ ]]; then
  log_error "App name must contain only lowercase letters, numbers, and hyphens"
  exit 1
fi

# Check if directory already exists
if [ -d "$APP_NAME" ]; then
  log_error "Directory '$APP_NAME' already exists"
  exit 1
fi

log_info "Creating Bun app: $APP_NAME"
log_info "Using template: $template"

# Create app directory
mkdir -p "$APP_NAME"
cd "$APP_NAME"

# Get latest Bun version
BUN_VERSION="1.2.17"

# Create base package.json
create_package_json() {
  local template="$1"

  case "$template" in
    "hono")
      cat > package.json << EOF
{
  "name": "$APP_NAME",
  "version": "1.0.0",
  "description": "A Bun app with Hono framework",
  "main": "index.ts",
  "scripts": {
    "start": "bun run index.ts",
    "dev": "bun run --watch index.ts",
    "build": "bun build index.ts --outdir=dist"
  },
  "dependencies": {
    "hono": "^3.12.0"
  },
  "devDependencies": {
    "@types/bun": "latest"
  },
  "engines": {
    "bun": "^1.2.0"
  },
  "packageManager": "bun@$BUN_VERSION"
}
EOF
      ;;
    "api")
      cat > package.json << EOF
{
  "name": "$APP_NAME",
  "version": "1.0.0",
  "description": "A REST API built with Bun and Hono",
  "main": "src/index.ts",
  "scripts": {
    "start": "bun run src/index.ts",
    "dev": "bun run --watch src/index.ts",
    "build": "bun build src/index.ts --outdir=dist",
    "test": "bun test"
  },
  "dependencies": {
    "hono": "^3.12.0",
    "@hono/zod-validator": "^0.2.0",
    "zod": "^3.22.0"
  },
  "devDependencies": {
    "@types/bun": "latest"
  },
  "engines": {
    "bun": "^1.2.0"
  },
  "packageManager": "bun@$BUN_VERSION"
}
EOF
      ;;
    "fullstack")
      cat > package.json << EOF
{
  "name": "$APP_NAME",
  "version": "1.0.0",
  "description": "A full-stack Bun application",
  "main": "src/server.ts",
  "scripts": {
    "start": "bun run dist/server.js",
    "dev": "bun run --watch src/server.ts",
    "build": "bun run build:client && bun run build:server",
    "build:client": "bun build src/client/index.ts --outdir=public",
    "build:server": "bun build src/server.ts --outdir=dist",
    "test": "bun test"
  },
  "dependencies": {
    "hono": "^3.12.0"
  },
  "devDependencies": {
    "@types/bun": "latest"
  },
  "engines": {
    "bun": "^1.2.0"
  },
  "packageManager": "bun@$BUN_VERSION"
}
EOF
      ;;
    *)
      # Basic template
      cat > package.json << EOF
{
  "name": "$APP_NAME",
  "version": "1.0.0",
  "description": "A basic Bun application",
  "main": "index.ts",
  "scripts": {
    "start": "bun run index.ts",
    "dev": "bun run --watch index.ts",
    "build": "bun build index.ts --outdir=dist",
    "test": "bun test"
  },
  "devDependencies": {
    "@types/bun": "latest"
  },
  "engines": {
    "bun": "^1.2.0"
  },
  "packageManager": "bun@$BUN_VERSION"
}
EOF
      ;;
  esac
}

# Create application files based on template
create_app_files() {
  local template="$1"

  case "$template" in
    "hono")
      cat > index.ts << 'EOF'
import { Hono } from 'hono'

const app = new Hono()

app.get('/', (c) => {
  return c.json({
    message: 'Hello from Bun + Hono on Heroku! 🚀',
    timestamp: new Date().toISOString(),
    bun_version: Bun.version
  })
})

app.get('/health', (c) => {
  return c.json({
    status: 'healthy',
    uptime: process.uptime(),
    memory: process.memoryUsage()
  })
})

const port = parseInt(process.env.PORT || '3000')

console.log(`🚀 Server starting on port ${port}`)
console.log(`📦 Bun version: ${Bun.version}`)

export default {
  port,
  fetch: app.fetch,
}
EOF
      ;;
    "api")
      mkdir -p src
      cat > src/index.ts << 'EOF'
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { z } from 'zod'

const app = new Hono()

// Request validation schema
const userSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
})

// In-memory storage (use a real database in production)
let users: Array<{ id: number; name: string; email: string }> = []
let nextId = 1

// Routes
app.get('/api/users', (c) => {
  return c.json({ users })
})

app.post('/api/users', zValidator('json', userSchema), (c) => {
  const data = c.req.valid('json')
  const user = { id: nextId++, ...data }
  users.push(user)
  return c.json({ user }, 201)
})

app.get('/api/users/:id', (c) => {
  const id = parseInt(c.req.param('id'))
  const user = users.find(u => u.id === id)

  if (!user) {
    return c.json({ error: 'User not found' }, 404)
  }

  return c.json({ user })
})

app.get('/health', (c) => {
  return c.json({
    status: 'healthy',
    uptime: process.uptime(),
    users_count: users.length
  })
})

const port = parseInt(process.env.PORT || '3000')

console.log(`🚀 API server starting on port ${port}`)
console.log(`📚 Available endpoints:`)
console.log(`   GET    /api/users`)
console.log(`   POST   /api/users`)
console.log(`   GET    /api/users/:id`)
console.log(`   GET    /health`)

export default {
  port,
  fetch: app.fetch,
}
EOF
      ;;
    "fullstack")
      mkdir -p src/client public
      cat > src/server.ts << 'EOF'
import { Hono } from 'hono'
import { serveStatic } from 'hono/serve-static'

const app = new Hono()

// API routes
app.get('/api/hello', (c) => {
  return c.json({
    message: 'Hello from the API!',
    timestamp: new Date().toISOString()
  })
})

app.get('/health', (c) => {
  return c.json({ status: 'healthy' })
})

// Serve static files
app.use('/static/*', serveStatic({ root: './public' }))

// Catch-all for SPA (serve index.html)
app.get('*', serveStatic({ path: './public/index.html' }))

const port = parseInt(process.env.PORT || '3000')

console.log(`🚀 Full-stack server starting on port ${port}`)

export default {
  port,
  fetch: app.fetch,
}
EOF

      cat > src/client/index.ts << 'EOF'
// Simple client-side TypeScript
console.log('Client-side Bun app loaded!')

async function fetchApi() {
  try {
    const response = await fetch('/api/hello')
    const data = await response.json()
    document.getElementById('api-response')!.textContent = JSON.stringify(data, null, 2)
  } catch (error) {
    console.error('API call failed:', error)
  }
}

// Load API data when page loads
document.addEventListener('DOMContentLoaded', fetchApi)
EOF

      cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Full-stack Bun App</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
        pre { background: #f5f5f5; padding: 10px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>🚀 Full-stack Bun App</h1>
    <p>This is a full-stack application built with Bun and Hono!</p>

    <h2>API Response:</h2>
    <pre id="api-response">Loading...</pre>

    <script src="/static/index.js"></script>
</body>
</html>
EOF
      ;;
    *)
      # Basic template
      cat > index.ts << 'EOF'
const server = Bun.serve({
  port: process.env.PORT || 3000,
  fetch(req) {
    const url = new URL(req.url)

    if (url.pathname === '/') {
      return new Response(JSON.stringify({
        message: 'Hello from Bun on Heroku! 🚀',
        timestamp: new Date().toISOString(),
        bun_version: Bun.version,
        path: url.pathname
      }), {
        headers: { 'Content-Type': 'application/json' }
      })
    }

    if (url.pathname === '/health') {
      return new Response(JSON.stringify({
        status: 'healthy',
        uptime: process.uptime(),
        memory: process.memoryUsage()
      }), {
        headers: { 'Content-Type': 'application/json' }
      })
    }

    return new Response('Not Found', { status: 404 })
  },
})

console.log(`🚀 Server running on port ${server.port}`)
console.log(`📦 Bun version: ${Bun.version}`)
console.log(`🌐 Visit: http://localhost:${server.port}`)
EOF
      ;;
  esac
}

# Create additional files
create_additional_files() {
  # Create .bun-version file
  echo "$BUN_VERSION" > .bun-version

  # Create Procfile
  case "$TEMPLATE" in
    "api")
      echo "web: bun run src/index.ts" > Procfile
      ;;
    "fullstack")
      echo "web: bun run dist/server.js" > Procfile
      ;;
    *)
      echo "web: bun run index.ts" > Procfile
      ;;
  esac

  # Create .gitignore
  cat > .gitignore << 'EOF'
# Bun
node_modules/

# Build output
dist/
public/*.js

# Environment
.env
.env.local

# Logs
*.log
logs/

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# Cache
.cache/

# Note: Keep bun.lock (text format) in git, but exclude bun.lockb (binary format) if present
# bun.lockb
EOF

  # Create README
  cat > README.md << EOF
# $APP_NAME

A Bun application built with the $TEMPLATE template.

## Getting Started

### Prerequisites

- [Bun](https://bun.sh/) installed locally
- [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) for deployment

### Local Development

1. Install dependencies:
   \`\`\`bash
   bun install
   \`\`\`

2. Start the development server:
   \`\`\`bash
   bun run dev
   \`\`\`

3. Visit [http://localhost:3000](http://localhost:3000)

### Deployment to Heroku

1. Create a Heroku app:
   \`\`\`bash
   heroku create $APP_NAME
   \`\`\`

2. Set the Bun buildpack:
   \`\`\`bash
   heroku buildpacks:set https://github.com/your-username/heroku-buildpack-bun
   \`\`\`

3. Deploy:
   \`\`\`bash
   git add .
   git commit -m "Initial commit"
   git push heroku main
   \`\`\`

## Scripts

- \`bun run dev\` - Start development server with auto-reload
- \`bun run start\` - Start production server
- \`bun run build\` - Build the application
- \`bun test\` - Run tests

## Built With

- [Bun](https://bun.sh/) - Fast all-in-one JavaScript runtime
EOF

  if [ "$TEMPLATE" != "basic" ]; then
    echo "- [Hono](https://hono.dev/) - Ultrafast web framework" >> README.md
  fi

  # Add template-specific README sections
  case "$TEMPLATE" in
    "api")
      cat >> README.md << 'EOF'

## API Endpoints

- `GET /api/users` - List all users
- `POST /api/users` - Create a new user
- `GET /api/users/:id` - Get user by ID
- `GET /health` - Health check

### Example Usage

```bash
# Get all users
curl https://your-app.herokuapp.com/api/users

# Create a user
curl -X POST https://your-app.herokuapp.com/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'
```
EOF
      ;;
    "fullstack")
      cat >> README.md << 'EOF'

## Build Process

The build process compiles both client and server code:

1. Client TypeScript is compiled to `public/index.js`
2. Server TypeScript is compiled to `dist/server.js`
3. Static files are served from `public/`

## API Endpoints

- `GET /api/hello` - Simple API endpoint
- `GET /health` - Health check
- `GET /*` - Serves static files and SPA
EOF
      ;;
  esac
}

# Create all files
log_info "Creating package.json..."
create_package_json "$TEMPLATE"

log_info "Creating application files..."
create_app_files "$TEMPLATE"

log_info "Creating additional files..."
create_additional_files

# Initialize git repository
log_info "Initializing git repository..."
git init
git add .
git commit -m "Initial commit: $TEMPLATE Bun app"

log_success "✅ Bun app '$APP_NAME' created successfully!"
echo
log_info "📁 App created in: $(pwd)"
log_info "🚀 Template used: $TEMPLATE"
echo
log_info "Next steps:"
echo "  1. cd $APP_NAME"
echo "  2. bun install"
echo "  3. bun run dev"
echo
log_info "To deploy to Heroku:"
echo "  1. heroku create $APP_NAME"
echo "  2. heroku buildpacks:set https://github.com/your-username/heroku-buildpack-bun"
echo "  3. git push heroku main"
echo
log_success "Happy coding! 🎉"
