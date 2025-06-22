# Changelog

All notable changes to this Heroku Bun Buildpack will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-21

### Added
- Initial release of the comprehensive Heroku Bun Buildpack
- Smart Bun project detection via multiple methods:
  - `bun.lock` text-based lockfile detection (default since v1.2)
  - `bun.lockb` legacy binary lockfile detection
  - `packageManager` field in package.json
  - `engines.bun` field in package.json
  - Bun-specific version files (`.bun-version`, `runtime.bun.txt`, etc.)
  - `bunfig.toml` configuration file
  - TypeScript projects without other package managers
- Multiple version specification methods with proper precedence:
  - `.bun-version` file
  - `runtime.bun.txt` file
  - `runtime.txt` file
  - `package.json` packageManager field
  - `package.json` engines field
  - Environment variable override
  - Automatic latest version detection
- Intelligent architecture detection and optimization:
  - Linux x64 (standard and baseline builds)
  - Linux ARM64 native support
  - Alpine/musl automatic detection
  - CPU feature detection for optimal binary selection
- Comprehensive build process:
  - Automatic dependency installation via `bun install`
  - Support for frozen lockfiles (both bun.lock and bun.lockb)
  - Workspace detection and support
  - Build script execution (heroku-prebuild, build, heroku-postbuild)
- Advanced caching system:
  - Per-version Bun binary caching
  - Dependency caching with size management
  - Automatic cache cleanup to prevent bloat
- Robust error handling and logging:
  - Colored output for better readability
  - Detailed error messages with helpful suggestions
  - Build timing information
  - Progress indicators
- Security features:
  - SHA256 checksum verification for downloads
  - Download retry logic with exponential backoff
  - Secure environment variable handling
- Skip flags for build customization:
  - `.skip-bun-install` - Skip dependency installation
  - `.skip-bun-build` - Skip build script
  - `.skip-bun-heroku-prebuild` - Skip heroku-prebuild script
  - `.skip-bun-heroku-postbuild` - Skip heroku-postbuild script
- Runtime environment setup:
  - Proper PATH configuration
  - BUN_INSTALL environment variables
  - Profile script creation for dyno startup
- Multi-stack support:
  - heroku-20 stack compatibility
  - heroku-22 stack compatibility
  - heroku-24 stack compatibility
  - Container stack support
- Comprehensive test fixtures:
  - Basic Bun application example
  - Hono web framework integration
  - TypeScript support demonstration
- Complete documentation:
  - Detailed README with examples
  - Usage instructions and best practices
  - Troubleshooting guide
  - Configuration options

### Technical Features
- JSON parsing utilities with jq fallbacks
- Disk space validation before installation
- Memory usage optimization
- Download integrity verification
- Automatic latest version fetching from GitHub API
- Version normalization and validation
- Workspace configuration detection
- TypeScript native support
- Build timing measurements
- Intelligent cache management

### Developer Experience
- Clear, actionable error messages
- Progress indicators and build timing
- Helpful logging with color coding
- Automatic platform detection
- Zero-configuration setup for standard projects
- Flexible configuration options for advanced use cases

### Supported Bun Features
- Native TypeScript compilation
- Bun workspaces
- Package manager functionality
- Build system integration
- Configuration via bunfig.toml
- All Bun runtime features
- Hot reloading in development
- Fast dependency installation
- Modern text-based lockfile support (bun.lock)
- Legacy binary lockfile support (bun.lockb)

### Performance Optimizations
- Intelligent binary selection based on CPU capabilities
- Aggressive caching strategy
- Parallel operations where possible
- Minimal network requests
- Efficient disk usage management
- Fast builds through proper caching

## [1.0.1] - 2025-01-21

### Updated
- **Lockfile Support** - Updated to support both bun.lock (text format, default since v1.2) and bun.lockb (legacy binary format)
- **Detection Priority** - Now prioritizes bun.lock over bun.lockb for project detection
- **Documentation** - Updated all documentation to reflect current lockfile formats
- **Test Coverage** - Added tests for both lockfile formats
- **App Generator** - Updated create-bun-app script to use proper gitignore for lockfiles

### Technical Changes
- Detection script now checks for bun.lock first, then bun.lockb
- Compile script handles both lockfile formats for frozen installs
- Test suite validates detection of both lockfile types
- Documentation updated across README, DEPLOYMENT, and BUILDPACK_SUMMARY

## [Unreleased]

### Planned Features
- Cloud Native Buildpack (CNB) support
- Multi-architecture container builds
- Enhanced workspace monorepo support
- Integration with Heroku CI/CD
- Advanced caching strategies
- Performance monitoring integration
- Custom registry support
- Build cache warming

---

## Version History

- **1.0.1** - Updated lockfile support for bun.lock and bun.lockb formats
- **1.0.0** - Initial comprehensive release with full Bun support