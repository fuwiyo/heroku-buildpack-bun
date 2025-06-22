# Contributing to Heroku Bun Buildpack

Thank you for your interest in contributing to the Heroku Bun Buildpack! This project aims to provide the best possible experience for deploying Bun applications to Heroku.

## 🚀 Quick Start

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/heroku-buildpack-bun.git
   cd heroku-buildpack-bun
   ```
3. **Make the scripts executable**:
   ```bash
   chmod +x bin/* lib/* scripts/* test/*
   ```
4. **Run the tests** to ensure everything works:
   ```bash
   ./test/test-buildpack.sh
   ```

## 📋 Development Setup

### Prerequisites

- **Bash/Zsh shell** - Required for running buildpack scripts
- **Git** - For version control
- **curl** - For downloading Bun binaries (testing)
- **jq** - For JSON parsing (optional, has fallbacks)
- **unzip** - For extracting Bun archives

### Repository Structure

```
heroku-buildpack-bun/
├── bin/                    # Core buildpack scripts
│   ├── detect             # Project detection logic
│   ├── compile            # Main build process
│   ├── release            # Process type definitions
│   └── setup              # Setup script
├── lib/                   # Helper libraries
│   ├── json.sh           # JSON parsing utilities
│   └── utils.sh          # Platform detection & helpers
├── test/                  # Test suite
│   ├── fixtures/         # Test applications
│   └── test-buildpack.sh # Main test runner
├── scripts/              # Additional utilities
│   └── create-bun-app.sh # App generator
└── docs/                 # Documentation
    ├── README.md
    ├── DEPLOYMENT.md
    └── ...
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
./test/test-buildpack.sh

# Test specific components
./bin/detect test/fixtures/basic-app
./bin/release test/fixtures/basic-app
```

### Test Coverage

Our test suite covers:
- ✅ Buildpack structure validation
- ✅ Detection logic for all supported project types
- ✅ JSON utility functions
- ✅ Platform detection and URL generation
- ✅ Release script behavior
- ✅ Test fixture validation

### Adding New Tests

When adding new features, please include tests:

```bash
# Add test function to test/test-buildpack.sh
test_your_new_feature() {
  log_info "Testing your new feature..."
  
  # Your test logic here
  if [ condition ]; then
    log_info "Test passed"
    return 0
  else
    log_error "Test failed"
    return 1
  fi
}

# Add to main test runner
run_test "Your New Feature" test_your_new_feature
```

## 🐛 Bug Reports

When reporting bugs, please include:

### Required Information
- **Bun version** (`bun --version`)
- **Heroku stack** (heroku-20, heroku-22, heroku-24)
- **Project structure** (package.json, lockfiles, etc.)
- **Build logs** (complete output from `git push heroku main`)
- **Expected vs. actual behavior**

### Issue Template
```markdown
## Bug Report

**Bun Version:** 1.2.17
**Heroku Stack:** heroku-24
**Buildpack Version:** 1.0.1

**Description:**
Brief description of the issue.

**Steps to Reproduce:**
1. Create project with...
2. Deploy to Heroku...
3. See error...

**Expected Behavior:**
What should happen.

**Actual Behavior:**
What actually happens.

**Build Logs:**
```
(paste complete build logs here)
```

**Additional Context:**
Any other relevant information.
```

## ✨ Feature Requests

We welcome feature requests! Please:

1. **Check existing issues** to avoid duplicates
2. **Describe the use case** - why is this needed?
3. **Propose a solution** - how should it work?
4. **Consider backwards compatibility** - will this break existing apps?

### Feature Request Template
```markdown
## Feature Request

**Use Case:**
Describe the problem you're trying to solve.

**Proposed Solution:**
How should this feature work?

**Alternatives Considered:**
What other approaches did you consider?

**Additional Context:**
Any other relevant information.
```

## 🔧 Code Contributions

### Coding Standards

#### Shell Scripting Guidelines
- **Use `#!/usr/bin/env bash`** for all scripts
- **Set safety flags**: `set -e` for error exit, `set -o pipefail` for pipe failures
- **Quote variables**: Use `"$VAR"` instead of `$VAR`
- **Check command existence**: Use `command -v cmd >/dev/null 2>&1`
- **Provide fallbacks**: For optional dependencies like `jq`

#### Error Handling
```bash
# Good: Check command success
if ! some_command; then
  log_error "Command failed"
  exit 1
fi

# Good: Validate inputs
if [ -z "$REQUIRED_VAR" ]; then
  log_error "REQUIRED_VAR not set"
  exit 1
fi
```

#### Logging
Use the provided logging functions:
```bash
log_info "Informational message"
log_warning "Warning message"
log_error "Error message"
log_success "Success message"
header "Section header"
```

### Commit Guidelines

#### Commit Message Format
```
type(scope): brief description

Detailed explanation if needed.

- Bullet points for lists
- Reference issues with #123
```

#### Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **test**: Test additions/changes
- **refactor**: Code refactoring
- **style**: Code style changes
- **chore**: Maintenance tasks

#### Examples
```
feat(detect): add support for bunfig.toml detection

Adds detection logic for Bun configuration files to improve
project identification accuracy.

- Checks for both .bunfig.toml and bunfig.toml
- Updates test suite with new detection cases
- Fixes #42

fix(compile): handle missing lockfile gracefully

Previously would fail if no lockfile present. Now falls back
to regular install without --frozen-lockfile flag.

docs(readme): update installation instructions

- Add GitHub badges
- Improve quick start section
- Fix broken links
```

### Pull Request Process

1. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the coding standards

3. **Add/update tests** for your changes

4. **Run the test suite**:
   ```bash
   ./test/test-buildpack.sh
   ```

5. **Update documentation** if needed

6. **Commit your changes** with clear messages

7. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

8. **Create a Pull Request** on GitHub

### Pull Request Template
```markdown
## Description
Brief description of the changes.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Tests pass locally
- [ ] Added tests for new functionality
- [ ] Tested with sample Bun application

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or marked as such)

## Related Issues
Fixes #(issue number)
```

## 📖 Documentation

### Writing Documentation
- **Use clear, simple language**
- **Provide examples** for all features
- **Include troubleshooting** for common issues
- **Keep it up-to-date** with code changes

### Documentation Structure
- **README.md** - Overview and quick start
- **DEPLOYMENT.md** - Detailed deployment guide
- **BUILDPACK_SUMMARY.md** - Technical overview
- **MIGRATION.md** - Migration guides
- **CONTRIBUTING.md** - This file

## 🌟 Recognition

Contributors are recognized in several ways:

### GitHub Contributors
All contributors are automatically listed in the GitHub contributors section.

### Release Notes
Significant contributions are mentioned in release notes and changelog.

### Special Recognition
Outstanding contributors may be invited to become maintainers.

## 📞 Getting Help

### Questions & Discussions
- **GitHub Discussions** - For general questions
- **GitHub Issues** - For bugs and feature requests
- **Bun Discord** - For Bun-specific questions

### Maintainer Contact
- **GitHub Issues** - Primary communication method
- **Code Reviews** - During pull request process

## 📜 Code of Conduct

### Our Pledge
We are committed to making participation in this project a harassment-free experience for everyone.

### Standards
- **Be respectful** and inclusive
- **Accept constructive criticism** gracefully
- **Focus on what's best** for the community
- **Show empathy** towards other community members

### Enforcement
Instances of abusive, harassing, or otherwise unacceptable behavior may be reported to the project maintainers.

## 🎯 Roadmap

### Current Focus
- ✅ Stable Bun support for all versions
- ✅ Comprehensive testing coverage
- ✅ Clear documentation
- 🔄 Performance optimizations
- 🔄 Enhanced error messages

### Future Plans
- 📋 Cloud Native Buildpack (CNB) support
- 📋 Enhanced monorepo support
- 📋 Performance monitoring integration
- 📋 Custom registry support

## 📊 Project Stats

- **Lines of Code**: ~2,000+ (bash, documentation)
- **Test Coverage**: 7 test suites, 100% core functionality
- **Documentation**: 6 comprehensive guides
- **Supported Platforms**: Linux x64/ARM64, Alpine/musl

## 🏆 Contributors

Thank you to all the people who have contributed to this project!

<!-- This will be automatically populated by GitHub -->

---

**Happy Contributing!** 🎉

For any questions about contributing, feel free to open an issue or start a discussion.