## Description

<!-- Provide a brief description of the changes in this PR -->

## Type of Change

Please delete options that are not relevant:

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring
- [ ] Test improvements

## Related Issues

<!-- Link to related issues -->
Fixes #(issue number)
Closes #(issue number)
Related to #(issue number)

## Changes Made

<!-- Describe the changes in detail -->

### Core Changes
- [ ] Modified detection logic
- [ ] Updated compile process
- [ ] Changed release configuration
- [ ] Updated utility functions
- [ ] Modified JSON parsing

### Documentation Changes
- [ ] Updated README
- [ ] Updated DEPLOYMENT guide
- [ ] Updated CHANGELOG
- [ ] Added/updated code comments

### Test Changes
- [ ] Added new tests
- [ ] Updated existing tests
- [ ] Fixed failing tests
- [ ] Updated test fixtures

## Testing

### Test Results
- [ ] All existing tests pass locally
- [ ] New tests added for new functionality
- [ ] Manual testing completed

### Test Command Output
```bash
# Paste the output of ./test/test-buildpack.sh here
```

### Manual Testing
<!-- Describe any manual testing performed -->

**Test Project Type:**
- [ ] Basic Bun server
- [ ] Hono web framework
- [ ] API with validation
- [ ] Full-stack application
- [ ] Monorepo with workspaces
- [ ] TypeScript project

**Bun Versions Tested:**
- [ ] Bun 1.0.x
- [ ] Bun 1.1.x
- [ ] Bun 1.2.x
- [ ] Latest stable

**Heroku Stacks Tested:**
- [ ] heroku-20
- [ ] heroku-22
- [ ] heroku-24

## Breaking Changes

<!-- If this is a breaking change, describe the impact and migration path -->

### What breaks?
<!-- Describe what will no longer work -->

### Migration Guide
<!-- Provide steps for users to migrate -->

### Backwards Compatibility
- [ ] Fully backwards compatible
- [ ] Backwards compatible with deprecation warnings
- [ ] Breaking change with migration path
- [ ] Breaking change without migration path

## Performance Impact

<!-- Describe any performance implications -->

- [ ] No performance impact
- [ ] Improves performance
- [ ] May impact performance (explain below)

**Performance Notes:**
<!-- Details about performance changes -->

## Security Considerations

<!-- Describe any security implications -->

- [ ] No security impact
- [ ] Improves security
- [ ] Potential security impact (explain below)

**Security Notes:**
<!-- Details about security changes -->

## Deployment Checklist

### Pre-merge Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review of code completed
- [ ] Code is properly commented
- [ ] Documentation updated where necessary
- [ ] Tests pass locally
- [ ] No merge conflicts

### Post-merge Checklist
- [ ] Version number updated (if needed)
- [ ] CHANGELOG updated
- [ ] Release notes prepared (if needed)

## Screenshots/Examples

<!-- Add screenshots or examples if applicable -->

### Before
<!-- Show current behavior -->

### After
<!-- Show new behavior -->

## Additional Notes

<!-- Any additional information that reviewers should know -->

### Dependencies
<!-- Any new dependencies or version changes -->

### Environment Variables
<!-- Any new environment variables or changes to existing ones -->

### Configuration Changes
<!-- Any changes to buildpack configuration -->

## Reviewer Notes

<!-- Specific areas you'd like reviewers to focus on -->

**Please review:**
- [ ] Logic in `bin/detect`
- [ ] Error handling in `bin/compile`
- [ ] Test coverage for new features
- [ ] Documentation accuracy
- [ ] Performance implications

**Questions for reviewers:**
<!-- Any specific questions or concerns -->

## Checklist

- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published

---

**Thank you for contributing to the Heroku Bun Buildpack!** 🎉