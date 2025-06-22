# Heroku Buildpack for Bun

A comprehensive, no-BS Heroku buildpack for [Bun](https://bun.sh/) - the fast all-in-one JavaScript runtime & toolkit.

## Features

- ✅ **Latest Bun Support** - Always supports the latest Bun versions
- ✅ **Smart Detection** - Automatically detects Bun projects
- ✅ **Architecture Optimization** - Chooses optimal binaries for your platform
- ✅ **Version Pinning** - Multiple ways to specify Bun version
- ✅ **Build Scripts** - Runs heroku-prebuild, build, and heroku-postbuild scripts
- ✅ **Caching** - Intelligent caching for faster builds
- ✅ **Workspaces** - Full support for Bun workspaces
- ✅ **TypeScript** - Native TypeScript support
- ✅ **Error Handling** - Robust error handling and helpful messages
- ✅ **Security** - Download verification with SHA256 checksums

## Quick Start

1. **Set the buildpack for your Heroku app:**
   ```bash
   heroku buildpacks:set https://github.com/your-username/heroku-buildpack-bun
   ```

2. **Deploy your Bun app:**
   ```bash
   git push heroku main
   ```

That's it! The buildpack will automatically detect your Bun project and handle the rest.

## Detection

The buildpack detects Bun projects by looking for:

1. `bun.lock` file (Bun's text-based lockfile, default since v1.2)
2. `bun.lockb` file (Bun's legacy binary lockfile)
3. `packageManager` field in `package.json` set to `bun@x.x.x`
4. `engines.bun` field in `package.json`
5. Bun-specific version files (`.bun-version`, `runtime.bun.txt`, etc.)
6. `bunfig.toml` configuration file
7. TypeScript projects without other package managers

## Version Specification

You can specify the Bun version in several ways (in order of precedence):

### 1. `.bun-version` file
```
1.2.17
```

### 2. `runtime.bun.txt` file
```
1.2.17
```

### 3. `runtime.txt` file
```
bun-1.2.17
```

### 4. `package.json` `packageManager` field
```json
{
  "packageManager": "bun@1.2.17"
}
```

### 5. `package.json` `engines` field
```json
{
  "engines": {
    "bun": "^1.2.0"
  }
}
```

### 6. Environment variable
```bash
heroku config:set BUN_VERSION_OVERRIDE=1.2.17
```

If no version is specified, the latest stable version will be used.

## Build Process

The buildpack performs the following steps:

1. **Detection** - Determines if this is a Bun project
2. **Version Resolution** - Finds the Bun version to install
3. **Download & Install** - Downloads and installs the appropriate Bun binary
4. **Dependencies** - Runs `bun install` (unless `.skip-bun-install` exists)
5. **Build Scripts** - Executes build scripts in this order:
   - `heroku-prebuild` (unless `.skip-bun-heroku-prebuild` exists)
   - `build` (unless `.skip-bun-build` exists)
   - `heroku-postbuild` (unless `.skip-bun-heroku-postbuild` exists)

## Build Scripts

### Heroku-specific Scripts

- **`heroku-prebuild`** - Runs before dependency installation
- **`heroku-postbuild`** - Runs after the build process

Example `package.json`:
```json
{
  "scripts": {
    "heroku-prebuild": "echo 'Preparing for build'",
    "build": "bun run build:prod",
    "heroku-postbuild": "echo 'Build completed'",
    "start": "bun run src/server.ts"
  }
}
```

## Skip Flags

You can skip certain build steps by creating these files:

- `.skip-bun-install` - Skip dependency installation
- `.skip-bun-build` - Skip the build script
- `.skip-bun-heroku-prebuild` - Skip heroku-prebuild script
- `.skip-bun-heroku-postbuild` - Skip heroku-postbuild script

## Environment Variables

The buildpack sets these environment variables at runtime:

- `PATH` - Includes Bun binary location
- `BUN_INSTALL` - Bun installation directory
- `BUN_INSTALL_BIN` - Bun binary directory

## Caching

The buildpack intelligently caches:

- **Bun binaries** - Cached per version to speed up subsequent builds
- **Dependencies** - Bun's native caching for node_modules
- **Build artifacts** - Preserves cache between builds

Cache is automatically cleaned to prevent excessive disk usage.

## Workspaces

Full support for Bun workspaces. The buildpack will:

- Detect workspace configuration in `package.json`
- Install dependencies for all workspaces
- Respect workspace-specific scripts and configurations

Example workspace `package.json`:
```json
{
  "workspaces": ["packages/*", "apps/*"],
  "packageManager": "bun@1.2.17"
}
```

## Architecture Support

The buildpack automatically selects the optimal Bun binary for your platform:

- **Linux x64** - Standard and baseline builds
- **Linux ARM64** - Native ARM64 support
- **Alpine/musl** - Automatic detection and appropriate binary selection

## TypeScript Support

Bun's native TypeScript support works out of the box:

- No additional configuration required
- Runs `.ts` files directly
- Supports `tsconfig.json`
- Fast compilation with Bun's built-in transpiler

## Examples

### Basic Bun App
```json
{
  "name": "my-bun-app",
  "scripts": {
    "start": "bun run src/server.ts",
    "build": "bun build src/index.ts --outdir=dist"
  },
  "packageManager": "bun@1.2.17"
}
```

### Web Framework (Hono)
```json
{
  "name": "my-hono-app",
  "scripts": {
    "start": "bun run src/index.ts",
    "dev": "bun run --watch src/index.ts"
  },
  "dependencies": {
    "hono": "^3.0.0"
  },
  "engines": {
    "bun": "^1.2.0"
  }
}
```

### Full-stack App with Build Step
```json
{
  "name": "fullstack-bun-app",
  "scripts": {
    "build": "bun run build:client && bun run build:server",
    "build:client": "bun build client/index.ts --outdir=public",
    "build:server": "bun build server/index.ts --outdir=dist",
    "start": "bun run dist/index.js",
    "heroku-postbuild": "bun run optimize"
  },
  "packageManager": "bun@1.2.17"
}
```

## Configuration

### bunfig.toml

The buildpack respects Bun's configuration file:

```toml
[install]
# Configure package installation
cache = true
frozen = false

[install.scopes]
# Scoped registries
"@mycompany" = "https://npm.mycompany.com"

[run]
# Configure script runner
shell = "/bin/bash"
```

## Troubleshooting

### Build Fails

1. **Check Bun version** - Ensure you're using a valid version
2. **Verify package.json** - Make sure it's valid JSON
3. **Check dependencies** - Ensure all dependencies are available
4. **Review build logs** - Look for specific error messages

### Memory Issues

If you encounter memory issues during builds:

1. Use `.skip-bun-build` to skip heavy build processes
2. Optimize your build scripts
3. Consider using Heroku's performance dynos

### Version Issues

If the wrong Bun version is installed:

1. Check version specification precedence
2. Use `BUN_VERSION_OVERRIDE` environment variable
3. Clear build cache: `heroku builds:cache:purge`

## Contributing

1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Support

- [Bun Documentation](https://bun.sh/docs)
- [Heroku Buildpack Documentation](https://devcenter.heroku.com/articles/buildpacks)
- [GitHub Issues](https://github.com/your-username/heroku-buildpack-bun/issues)