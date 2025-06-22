# Lockfile Format Update - Bun v1.2+ Support

## Summary

The Heroku Bun Buildpack has been updated to fully support both Bun lockfile formats:

- **`bun.lock`** - New text-based format (default since Bun v1.2)
- **`bun.lockb`** - Legacy binary format (maintained for compatibility)

## What Changed

### 🔍 Detection Logic
- **Priority Order**: `bun.lock` is now checked first, then `bun.lockb`
- **Backward Compatibility**: Projects with legacy `bun.lockb` continue to work
- **Future Ready**: Prioritizes the modern text-based format

### 🏗️ Build Process
- **Frozen Lockfile**: Supports `--frozen-lockfile` for both formats
- **Clear Logging**: Shows which lockfile format is being used during build
- **Smart Detection**: Automatically chooses appropriate install strategy

### 📝 Documentation Updates
- **README**: Updated detection section with lockfile priorities
- **DEPLOYMENT**: Added lockfile management best practices
- **BUILDPACK_SUMMARY**: Reflects current lockfile support
- **MIGRATION**: New guide for upgrading from binary to text format

### 🧪 Testing
- **Dual Format Tests**: Validates detection of both `bun.lock` and `bun.lockb`
- **Test Fixtures**: Updated with realistic `bun.lock` example
- **Edge Cases**: Ensures no false positives with other package managers

## Migration Path

### For New Projects
- Use Bun v1.2+ and get `bun.lock` automatically
- Commit `bun.lock` to version control
- No additional configuration needed

### For Existing Projects with `bun.lockb`
1. **Upgrade Bun**: `bun upgrade` to v1.2+
2. **Migrate Format**: `bun install --save-text-lockfile --frozen-lockfile --lockfile-only`
3. **Clean Up**: `rm bun.lockb`
4. **Update Git**: Commit `bun.lock`, remove `bun.lockb`

### For Teams
- **Gradual Migration**: Buildpack supports both during transition
- **Coordinated Switch**: Team lead migrates, others pull changes
- **No Deployment Issues**: Heroku deployments work with either format

## Benefits of Text Format

### Developer Experience
- **Readable Diffs**: See dependency changes in pull requests
- **Merge Friendly**: Easier conflict resolution than binary format
- **Debugging**: Can inspect lockfile contents directly

### Performance
- **Smaller Size**: Text format is more storage efficient
- **Faster Git**: Better performance with version control
- **Cross Platform**: No binary compatibility issues

### Tooling
- **Better IDE Support**: Syntax highlighting and analysis
- **CI/CD Friendly**: Easier to work with in automated workflows
- **Standards Compliant**: Follows package manager best practices

## Compatibility Matrix

| Bun Version | Default Format | Buildpack Support |
|-------------|----------------|------------------|
| < 1.2       | `bun.lockb`    | ✅ Full Support   |
| 1.2.0+      | `bun.lock`     | ✅ Full Support   |
| Mixed Team  | Both           | ✅ Automatic      |

## Technical Implementation

### Detection Priority
```bash
# 1. Check for text format (preferred)
if [ -f "$BUILD_DIR/bun.lock" ]; then
  echo "Bun"
  exit 0
fi

# 2. Check for binary format (legacy)
if [ -f "$BUILD_DIR/bun.lockb" ]; then
  echo "Bun"
  exit 0
fi
```

### Build Logic
```bash
# Smart lockfile detection
if [ -f "bun.lock" ]; then
  install_args="--frozen-lockfile"
  log_info "Using frozen lockfile (bun.lock)"
elif [ -f "bun.lockb" ]; then
  install_args="--frozen-lockfile"
  log_info "Using frozen lockfile (bun.lockb)"
fi
```

## Best Practices

### For Application Developers
- **Always Commit Lockfiles**: Ensures reproducible builds
- **Use Text Format**: Upgrade to `bun.lock` when possible
- **Update .gitignore**: Exclude `bun.lockb`, include `bun.lock`

### For Teams
- **Coordinate Migration**: Plan lockfile format changes together
- **Test After Migration**: Verify builds work with new format
- **Document Changes**: Inform team about migration timeline

### For CI/CD
- **Cache Strategy**: Cache based on lockfile existence and content
- **Validation**: Ensure lockfile is committed and up-to-date
- **Error Handling**: Handle missing lockfiles gracefully

## Troubleshooting

### Common Issues
1. **Both Formats Present**: Buildpack uses `bun.lock` (correct behavior)
2. **Migration Failures**: Follow migration guide step-by-step
3. **Team Conflicts**: Use gradual migration approach
4. **Build Differences**: Clean install after format change

### Debug Commands
```bash
# Check which lockfile exists
ls -la bun.lock*

# Verify buildpack detection
heroku buildpacks:test-detect

# Force lockfile regeneration
rm bun.lock* && bun install --save-text-lockfile
```

## Future Considerations

### Deprecation Timeline
- **Now**: Both formats supported
- **Future**: `bun.lockb` support may be removed eventually
- **Recommendation**: Migrate to `bun.lock` when convenient

### Feature Parity
- All buildpack features work with both formats
- No functionality differences between formats
- Performance characteristics identical for builds

---

**Status**: ✅ Complete - Both lockfile formats fully supported
**Version**: Buildpack v1.0.1+
**Next Steps**: Consider migrating to `bun.lock` for better developer experience