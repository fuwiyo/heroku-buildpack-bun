# Migration Guide - Bun Lockfile Format Changes

This guide helps you migrate your Bun project from the legacy binary lockfile format (`bun.lockb`) to the new text-based format (`bun.lock`).

## Overview

Bun v1.2+ introduced a new text-based lockfile format (`bun.lock`) that replaces the previous binary format (`bun.lockb`). The new format offers several advantages:

- **Human-readable** - Easy to review in pull requests
- **Git-friendly** - Better merge conflict resolution
- **Smaller size** - More efficient storage
- **Cross-platform** - Better compatibility across different systems

## Migration Steps

### Step 1: Check Your Current Bun Version

First, ensure you're using Bun v1.2 or later:

```bash
bun --version
```

If you're using an older version, upgrade first:

```bash
bun upgrade
```

### Step 2: Migrate Your Lockfile

If you have an existing `bun.lockb` file, migrate it to the new format:

```bash
# Generate new text-based lockfile
bun install --save-text-lockfile --frozen-lockfile --lockfile-only

# Remove the old binary lockfile
rm bun.lockb
```

### Step 3: Update Your .gitignore

Ensure your `.gitignore` is configured correctly for the new format:

```gitignore
# Bun
node_modules/

# Keep bun.lock (text format) in git
# Exclude bun.lockb (binary format) if it exists
bun.lockb

# Other files...
```

### Step 4: Commit the Changes

```bash
git add bun.lock .gitignore
git rm bun.lockb  # if it was previously committed
git commit -m "Migrate to text-based bun.lock format"
```

## Buildpack Compatibility

The Heroku Bun Buildpack automatically supports both formats:

- **bun.lock** (text format) - Detected first, recommended
- **bun.lockb** (binary format) - Legacy support maintained

### Detection Priority

The buildpack checks for lockfiles in this order:

1. `bun.lock` (preferred)
2. `bun.lockb` (fallback)
3. Other detection methods (package.json, etc.)

### Frozen Lockfile Behavior

The buildpack will use `--frozen-lockfile` when either format is present:

```bash
# For bun.lock
bun install --frozen-lockfile

# For bun.lockb (legacy)
bun install --frozen-lockfile
```

## Team Migration

For teams migrating together:

### Option 1: Coordinated Migration

1. **Team Lead** performs migration:
   ```bash
   bun install --save-text-lockfile --frozen-lockfile --lockfile-only
   rm bun.lockb
   git add bun.lock .gitignore
   git rm bun.lockb
   git commit -m "Migrate to bun.lock format"
   git push
   ```

2. **Team Members** pull and clean up:
   ```bash
   git pull
   rm bun.lockb  # if it still exists locally
   ```

### Option 2: Gradual Migration

The buildpack supports both formats, so teams can migrate gradually:

1. Update buildpack to v1.0.1+ (supports both formats)
2. Individual developers can migrate when ready
3. Eventually remove `bun.lockb` when all team members have migrated

## CI/CD Considerations

### GitHub Actions

Update your workflow to handle both formats during transition:

```yaml
- name: Install dependencies
  run: |
    if [ -f "bun.lock" ]; then
      bun install --frozen-lockfile
    elif [ -f "bun.lockb" ]; then
      bun install --frozen-lockfile
    else
      bun install
    fi
```

### Heroku Deployment

No changes needed - the buildpack handles both formats automatically.

## Troubleshooting

### Issue: Merge Conflicts in bun.lockb

**Problem**: Binary lockfiles cause merge conflicts that are hard to resolve.

**Solution**: Migrate to text format and regenerate:

```bash
# Delete conflicted binary lockfile
rm bun.lockb

# Regenerate from package.json
bun install --save-text-lockfile

# Commit the new format
git add bun.lock
git commit -m "Resolve lockfile conflict with text format"
```

### Issue: Different Lockfile Formats in Team

**Problem**: Some team members have `bun.lock`, others have `bun.lockb`.

**Solution**: Coordinate migration or use gradual approach:

```bash
# Check which format is in the repo
ls bun.lock* 

# If both exist, prefer text format
if [ -f "bun.lock" ]; then
  rm bun.lockb
  git rm bun.lockb
  git commit -m "Remove legacy binary lockfile"
fi
```

### Issue: Build Fails After Migration

**Problem**: Dependencies seem different after lockfile migration.

**Solution**: Clean install and verify:

```bash
# Clean slate
rm -rf node_modules bun.lock*

# Fresh install with new format
bun install --save-text-lockfile

# Test your application
bun test
bun run build
```

## Benefits After Migration

Once migrated to `bun.lock`, you'll enjoy:

- **Better Code Reviews** - Lockfile changes are readable in PRs
- **Easier Conflict Resolution** - Text-based merging instead of binary
- **Smaller Repository Size** - Text format is more efficient
- **Cross-Platform Compatibility** - No binary format issues between systems
- **Future-Proof** - Aligned with Bun's long-term direction

## Version Compatibility

| Bun Version | Default Format | Supported Formats |
|-------------|----------------|------------------|
| < 1.2       | `bun.lockb`    | `bun.lockb` only |
| 1.2+        | `bun.lock`     | Both formats     |

## Getting Help

If you encounter issues during migration:

1. **Check Bun Documentation**: [https://bun.sh/docs/install/lockfile](https://bun.sh/docs/install/lockfile)
2. **Buildpack Issues**: [GitHub Issues](https://github.com/your-username/heroku-buildpack-bun/issues)
3. **Bun Community**: [Discord](https://bun.sh/discord)

---

**Note**: This migration is recommended but not required immediately. The buildpack maintains backward compatibility with `bun.lockb` files.