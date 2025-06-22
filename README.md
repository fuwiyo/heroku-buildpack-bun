# Heroku Buildpack for Bun

A simple and efficient Heroku buildpack for [Bun](https://bun.sh/) - the fast all-in-one JavaScript runtime & toolkit.

> **🚀 Ready to deploy?** This buildpack provides everything you need to run Bun applications on Heroku with minimal configuration.

## Features

- ✅ **Latest Bun Support** - Always supports the latest Bun versions
- ✅ **Smart Detection** - Automatically detects Bun projects
- ✅ **Version Pinning** - Multiple ways to specify Bun version
- ✅ **Build Scripts** - Runs heroku-prebuild, build, and heroku-postbuild scripts
- ✅ **Caching** - Intelligent caching for faster builds
- ✅ **TypeScript** - Native TypeScript support

## Quick Start

1. **Set the buildpack for your Heroku app:**

   ```bash
   heroku buildpacks:set https://github.com/fuwiyo/heroku-buildpack-bun
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

## Version Specification

You can specify the Bun version in several ways (in order of precedence):

1. `.bun-version` file

   ```
   1.2.17
   ```

2. `runtime.bun.txt` file

   ```
   1.2.17
   ```

3. `runtime.txt` file

   ```
   bun-1.2.17
   ```

4. `package.json` `packageManager` field

   ```json
   {
     "packageManager": "bun@1.2.17"
   }
   ```

5. `package.json` `engines` field

   ```json
   {
     "engines": {
       "bun": "^1.2.0"
     }
   }
   ```

6. Environment variable
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

## TypeScript Support

Bun's native TypeScript support works out of the box:

- No additional configuration required
- Runs `.ts` files directly
- Supports `tsconfig.json`
- Fast compilation with Bun's built-in transpiler

## Troubleshooting

### Build Fails

1. **Check Bun version** - Ensure you're using a valid version
2. **Verify package.json** - Make sure it's valid JSON
3. **Check dependencies** - Ensure all dependencies are available
4. **Review build logs** - Look for specific error messages

### Version Issues

If the wrong Bun version is installed:

1. Check version specification precedence
2. Use `BUN_VERSION_OVERRIDE` environment variable
3. Clear build cache: `heroku builds:cache:purge`

## License

MIT License - see LICENSE file for details.
