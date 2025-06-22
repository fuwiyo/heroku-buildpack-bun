---
name: Bug Report
about: Create a report to help us improve the buildpack
title: '[BUG] '
labels: ['bug']
assignees: ''

---

## Bug Report

**Describe the bug**
A clear and concise description of what the bug is.

## Environment

- **Bun Version**: (run `bun --version`)
- **Heroku Stack**: (heroku-20, heroku-22, heroku-24, container)
- **Buildpack Version**: (check your build logs or use latest)
- **Project Type**: (basic server, Hono app, full-stack, monorepo, etc.)

## Project Configuration

**package.json** (relevant parts):
```json
{
  "name": "your-app",
  "scripts": {
    // your scripts
  },
  "engines": {
    // your engines if any
  },
  "packageManager": "bun@x.x.x"
}
```

**Lockfile present**:
- [ ] bun.lock (text format)
- [ ] bun.lockb (binary format)
- [ ] No lockfile

**Version specification method**:
- [ ] .bun-version file
- [ ] runtime.bun.txt file
- [ ] runtime.txt file
- [ ] package.json packageManager field
- [ ] package.json engines field
- [ ] Environment variable
- [ ] Using latest (auto-detected)

## Steps to Reproduce

1. Create a project with...
2. Configure buildpack with...
3. Deploy to Heroku...
4. See error...

## Expected Behavior

A clear and concise description of what you expected to happen.

## Actual Behavior

A clear and concise description of what actually happened.

## Build Logs

<details>
<summary>Complete build logs (click to expand)</summary>

```
Paste your complete build logs here, from:
git push heroku main

Include everything from the push to the error.
```

</details>

## Application Logs

<details>
<summary>Application logs if relevant (click to expand)</summary>

```
heroku logs --tail output here
```

</details>

## Additional Context

- Is this a new project or existing one?
- Did this work before with a different Bun version?
- Any custom build configuration?
- Using any skip flags (.skip-bun-install, etc.)?
- Monorepo or single package?

## Possible Solution

If you have any ideas on how to fix this, please share them here.

## Checklist

- [ ] I have searched existing issues to make sure this is not a duplicate
- [ ] I have included all required environment information
- [ ] I have included complete build logs
- [ ] I have tested with the latest buildpack version
- [ ] I have provided a minimal reproduction case