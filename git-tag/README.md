# 🏷️ Git Tag Management Action

A comprehensive GitHub Action for creating and managing Git tags with validation, conflict resolution, and flexible targeting options for robust version control workflows.

## ✨ Features

- 🏷️ **Flexible Tag Creation** - Support for lightweight and annotated tags with custom messages
- 🔍 **Comprehensive Validation** - Tag name validation and Git repository requirement checks
- 🔄 **Intelligent Conflict Resolution** - Handle existing tags with force update or fail options
- 🎯 **Precise Target Control** - Tag specific commits, branches, or HEAD with validation
- 🚀 **Automatic Push Support** - Optional pushing to remote repository with authentication
- 📝 **Rich Metadata Outputs** - Detailed tag information including SHA, URLs, and status
- 🛡️ **Secure Authentication** - GitHub token handling with proper permissions
- 📋 **Input Validation** - Comprehensive parameter validation with helpful error messages

## 🚀 Basic Usage

Create a simple tag:

```yaml
- name: "Create Tag"
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: "v1.0.0"
```

```yaml
- name: "Create annotated tag with push"
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: "1.0.0"
    prefix: "v"
    message: "Release version 1.0.0 with new features"
    annotated: "true"
    push: "true"
    target: "main"
```

```yaml
- name: "Create tag from version action"
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: ${{ steps.version.outputs.VERSION_CORE }}
    prefix: "v"
    message: "Automated release ${{ steps.version.outputs.VERSION_FULL }}"
```

## 🔧 Advanced Usage

Full configuration with all available options:

```yaml
- name: "Advanced tag creation"
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: "1.0.0"
    message: "Release version 1.0.0 with comprehensive features"
    prefix: "release-"
    annotated: "true"
    push: "true"
    force: "false"
    fail-if-exists: "true"
    git-user-name: "Release Bot"
    git-user-email: "releases@company.com"
    target: "main"
    github-token: ${{ secrets.GITHUB_TOKEN }}
    show-summary: "true"
```

## 🔐 Permissions Required

This action requires appropriate repository permissions:

```yaml
permissions:
  contents: read   # Required to checkout repository and read Git history
```

If creating and pushing tags:

```yaml
permissions:
  contents: write  # Required to create and push Git tags
```

## 🏗️ CI/CD Example

Complete workflow with version generation and tagging:

```yaml
name: "Release Workflow"

on:
  push:
    branches: ["main"]
  workflow_dispatch:
    inputs:
      version:
        description: "Release version"
        required: true
        default: "1.0.0"

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest

    steps:
      - name: "📥 Checkout repository"
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Required for Git tag analysis

      - name: "🔢 Generate version"
        id: version
        uses: laerdal/github_actions/generate-version@main
        with:
          major: "1"
          minor: "0"
          tag-prefix: "v"
          branch-name: ${{ github.head_ref || github.ref_name }}
          build-id: ${{ github.run_number }}

      - name: "🏷️ Create release tag"
        id: tag
        uses: laerdal/github_actions/git-tag@main
        with:
          tag: ${{ steps.version.outputs.version-short }}
          prefix: "v"
          message: |
            Release version ${{ steps.version.outputs.version }}

            Created from commit: ${{ github.sha }}
            Created by: ${{ github.actor }}
            Build number: ${{ github.run_number }}
          annotated: "true"
          push: "true"
          git-user-name: "Release Bot"
          git-user-email: "releases@company.com"
          show-summary: "true"

      - name: "🔧 Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: "🔨 Build with version"
        uses: laerdal/github_actions/dotnet@main
        with:
          command: "build"
          configuration: "Release"
        env:
          VERSION: ${{ steps.version.outputs.version }}

      - name: "🚀 Create GitHub release"
        uses: laerdal/github_actions/github-release@main
        with:
          tag: ${{ steps.tag.outputs.tag-name }}
          title: "Release ${{ steps.tag.outputs.tag-name }}"
          generate-notes: "true"
          assets-dir: "dist"

      - name: "📊 Report results"
        run: |
          echo "Created tag: ${{ steps.tag.outputs.tag-name }}"
          echo "Tag URL: ${{ steps.tag.outputs.tag-url }}"
          echo "Tag SHA: ${{ steps.tag.outputs.tag-sha }}"
          echo "New tag created: ${{ steps.tag.outputs.tag-created }}"
```

## 📋 Inputs

### Required Inputs

| Input | Description | Example |
|-------|-------------|---------|
| `tag` | Tag name to create | `1.0.0`, `release-1`, `beta-2` |

### Optional Inputs

| Input | Description | Default | Example |
|-------|-------------|---------|---------|
| `message` | Tag message (for annotated tags) | `''` | `Release version 1.0.0`, `Hotfix for critical bug` |
| `prefix` | Prefix to add to tag name | `''` | `v`, `release-`, `hotfix-` |
| `annotated` | Create annotated tag | `true` | `true`, `false` |
| `push` | Push tag to remote | `true` | `true`, `false` |
| `force` | Force create/update existing tag | `false` | `true`, `false` |
| `fail-if-exists` | Fail if tag already exists | `true` | `true`, `false` |
| `git-user-name` | Git user name | `${{ github.actor }}` | `Release Bot`, `CI System` |
| `git-user-email` | Git user email | `${{ github.actor }}@users.noreply.github.com` | `bot@example.com` |
| `target` | Target commit/branch/SHA | `''` | `main`, `develop`, `abc123` |
| `github-token` | GitHub token for auth | `${{ github.token }}` | `${{ secrets.GITHUB_TOKEN }}` |
| `show-summary` | Show action summary | `true` | `true`, `false` |

## 📤 Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `tag-name` | Full tag name (with prefix) | `v1.0.0`, `release-1.2.3` |
| `tag-exists` | Whether tag already existed | `false`, `true` |
| `tag-sha` | SHA of tagged commit | `a1b2c3d4e5f6789...` |
| `tag-created` | Whether new tag was created | `true`, `false` |
| `tag-pushed` | Whether tag was pushed | `true`, `false` |
| `tag-url` | GitHub URL to the tag | `https://github.com/owner/repo/releases/tag/v1.0.0` |

## 🔗 Related Actions

| Action | Purpose | Repository |
|--------|---------|------------|
| 🔢 **generate-version** | Generate semantic versions | `laerdal/github_actions/generate-version` |
| 🚀 **github-release** | Create GitHub releases | `laerdal/github_actions/github-release` |
| 🎯 **generate-badge** | Generate version badges | `laerdal/github_actions/generate-badge` |
| 🔧 **dotnet** | Build with version metadata | `laerdal/github_actions/dotnet` |

## 💡 Examples

### Complete Release Workflow

```yaml
- name: "Generate version"
  id: version
  uses: laerdal/github_actions/generate-version@main
  with:
    major: "1"
    minor: "0"

- name: "Create release tag"
  id: tag
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: ${{ steps.version.outputs.version-short }}
    prefix: "v"
    message: |
      Release version ${{ steps.version.outputs.version }}

      Created from commit: ${{ github.sha }}
      Created by: ${{ github.actor }}
    annotated: "true"
    push: "true"

- name: "Create GitHub release"
  uses: laerdal/github_actions/github-release@main
  with:
    tag: ${{ steps.tag.outputs.tag-name }}
    title: "Release ${{ steps.tag.outputs.tag-name }}"
    generate-notes: "true"
```

### Automated Versioning Pipeline

```yaml
name: "Auto Version and Tag"

on:
  push:
    branches: ["main"]

jobs:
  version-and-tag:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: "Generate version"
        id: version
        uses: laerdal/github_actions/generate-version@main
        with:
          major: "1"
          minor: "0"

      - name: "Create tag"
        id: tag
        uses: laerdal/github_actions/git-tag@main
        with:
          tag: ${{ steps.version.outputs.version-short }}
          prefix: "v"
          message: "Automated tag for version ${{ steps.version.outputs.version }}"
          fail-if-exists: "false"  # Don't fail if tag exists

      - name: "Report results"
        run: |
          echo "Created tag: ${{ steps.tag.outputs.tag-name }}"
          echo "Tag URL: ${{ steps.tag.outputs.tag-url }}"
          echo "Was new tag: ${{ steps.tag.outputs.tag-created }}"
```

### Development Branch Tagging

```yaml
- name: "Create development tag"
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: ${{ github.run_number }}
    prefix: "dev-"
    message: "Development build from ${{ github.ref_name }}"
    target: ${{ github.sha }}
    push: "true"
    fail-if-exists: "false"
```

### Force Update Existing Tag

```yaml
- name: "Update latest tag"
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: "latest"
    message: "Latest stable version"
    force: "true"  # Will update existing 'latest' tag
    push: "true"
```

### Multi-Environment Tagging

```yaml
strategy:
  matrix:
    environment: [dev, staging, prod]
    include:
      - environment: dev
        prefix: "dev-"
        target: "develop"
      - environment: staging
        prefix: "staging-"
        target: "staging"
      - environment: prod
        prefix: "v"
        target: "main"

steps:
  - name: "Create environment tag"
    uses: laerdal/github_actions/git-tag@main
    with:
      tag: ${{ env.VERSION }}
      prefix: ${{ matrix.prefix }}
      target: ${{ matrix.target }}
      message: "Release for ${{ matrix.environment }} environment"
```

### Conditional Tagging

```yaml
- name: "Create tag on main branch only"
  if: github.ref == 'refs/heads/main'
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: ${{ env.RELEASE_VERSION }}
    prefix: "v"
    message: "Production release ${{ env.RELEASE_VERSION }}"

- name: "Create pre-release tag on other branches"
  if: github.ref != 'refs/heads/main'
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: ${{ env.RELEASE_VERSION }}-${{ github.ref_name }}
    prefix: "pre-"
    message: "Pre-release from branch ${{ github.ref_name }}"
```

### Rollback Tag Creation

```yaml
- name: "Create rollback tag"
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: "rollback-${{ github.run_number }}"
    message: "Rollback point before deployment"
    target: "HEAD~1"  # Tag the previous commit
    push: "true"
```

## 🏷️ Tag Types

### Lightweight Tags

Simple pointers to commits:

```yaml
- name: "Create lightweight tag"
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: "checkpoint-1"
    annotated: "false"
```

### Annotated Tags

Full Git objects with metadata:

```yaml
- name: "Create annotated tag"
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: "v1.0.0"
    annotated: "true"
    message: |
      Release version 1.0.0

      Features:
      - New authentication system
      - Improved performance
      - Bug fixes

      Breaking Changes:
      - API endpoint changes
```

## ⚠️ Error Handling

### Tag Already Exists

```yaml
# Option 1: Fail if tag exists (default)
- name: "Create unique tag"
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: "v1.0.0"
    fail-if-exists: "true"

# Option 2: Continue if tag exists
- name: "Create tag (allow existing)"
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: "v1.0.0"
    fail-if-exists: "false"

# Option 3: Force update existing tag
- name: "Force update tag"
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: "v1.0.0"
    force: "true"
```

### Validation Features

The action validates:

- Tag name format (no spaces, no '..' sequences)
- Email format for Git configuration
- Boolean parameter values
- Git repository state
- Target commit/branch existence

## 📋 Requirements

### Prerequisites

- **Git Repository** - Must be run in a Git repository
- **Write Permissions** - For pushing tags to remote
- **GitHub Token** - For authentication (automatic via `github.token`)

### Dependencies

- **Git** - For tag creation and pushing (pre-installed on runners)

### Supported Platforms

- ✅ Linux (ubuntu-latest)
- ✅ macOS (macos-latest)
- ✅ Windows (windows-latest)

## 🔧 Advanced Configuration

### Custom Git Configuration

```yaml
- name: "Create tag with custom author"
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: "v1.0.0"
    git-user-name: "Release Bot"
    git-user-email: "releases@company.com"
    message: "Official release by Release Bot"
```

### Tag Naming Strategies

```yaml
# Semantic versioning
prefix: "v"
tag: "1.0.0"
# Result: v1.0.0

# Date-based tagging
prefix: "release-"
tag: "2024-01-15"
# Result: release-2024-01-15

# Build-based tagging
prefix: "build-"
tag: ${{ github.run_number }}
# Result: build-1234

# Branch-specific tagging
prefix: ${{ github.ref_name }}-
tag: ${{ env.VERSION }}
# Result: feature-auth-1.0.0
```

### Target Specifications

```yaml
# Tag specific commit
target: "a1b2c3d4e5f6"

# Tag specific branch
target: "main"

# Tag relative commit
target: "HEAD~1"

# Tag from environment
target: ${{ env.DEPLOY_SHA }}
```

## 🐛 Troubleshooting

### Common Issues

#### Permission Denied

**Problem**: Permission denied (publickey)

**Solutions:**

1. Ensure `github-token` has write permissions:

   ```yaml
   permissions:
     contents: write
   ```

2. Check repository settings allow tag creation

#### Tag Conflicts

**Problem**: Tag v1.0.0 already exists and fail-if-exists is true

**Solutions:**

1. Use force mode:

   ```yaml
   force: "true"
   ```

2. Allow existing tags:

   ```yaml
   fail-if-exists: "false"
   ```

3. Use different tag name or add suffix

#### Invalid Tag Name

**Problem**: Tag name cannot contain spaces

**Solutions:**

1. Remove spaces from tag names
2. Use hyphens instead of spaces
3. Validate tag names before passing to action

```yaml
- name: "Validate and clean tag name"
  id: clean-tag
  run: |
    TAG_NAME="${{ env.VERSION }}"
    # Remove spaces and special characters
    TAG_NAME=$(echo "$TAG_NAME" | tr ' ' '-' | tr -d '"')
    echo "clean-tag=$TAG_NAME" >> $GITHUB_OUTPUT

- name: "Create tag with clean name"
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: ${{ steps.clean-tag.outputs.clean-tag }}
```

#### Target Not Found

**Problem**: Target 'unknown-branch' not found

**Solutions:**

1. Verify target branch/commit exists
2. Use `HEAD` for current commit
3. Fetch required branches before tagging

```yaml
- name: "Fetch all branches"
  run: git fetch --all

- name: "Create tag"
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: "v1.0.0"
    target: "origin/main"
```

### Debug Mode

Enable verbose output:

```yaml
- name: "Debug tag creation"
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: "debug-tag"
    show-summary: "true"
  env:
    ACTIONS_STEP_DEBUG: true
```

### Manual Verification

Verify tag creation:

```yaml
- name: "Verify tag"
  run: |
    git tag -l "${{ steps.tag.outputs.tag-name }}"
    git show "${{ steps.tag.outputs.tag-name }}"
    git ls-remote --tags origin | grep "${{ steps.tag.outputs.tag-name }}"
```

## 🔗 Integration Patterns

### With Docker Builds

```yaml
- name: "Create docker tag"
  id: tag
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: ${{ env.VERSION }}
    prefix: "docker-"

- name: "Build docker image"
  run: |
    docker build -t myapp:${{ steps.tag.outputs.tag-name }} .
    docker tag myapp:${{ steps.tag.outputs.tag-name }} myapp:latest
```

### With Artifact Versioning

```yaml
- name: "Create artifact tag"
  id: tag
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: ${{ github.run_number }}
    prefix: "artifact-"

- name: "Upload versioned artifacts"
  uses: actions/upload-artifact@v4
  with:
    name: "build-${{ steps.tag.outputs.tag-name }}"
    path: dist/
```

### With Deployment Tracking

```yaml
- name: "Create deployment tag"
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: ${{ env.ENVIRONMENT }}-${{ env.VERSION }}
    message: "Deployed to ${{ env.ENVIRONMENT }} at ${{ env.DEPLOY_TIME }}"
    target: ${{ env.DEPLOY_SHA }}
```

## 🔐 Security Considerations

### Token Permissions

Ensure appropriate permissions:

```yaml
permissions:
  contents: write  # Required for creating and pushing tags
```

### Sensitive Information

Avoid including sensitive data in tag messages:

```yaml
# ❌ Don't include secrets
message: "Release with API key: ${{ secrets.API_KEY }}"

# ✅ Use generic messages
message: "Production release v${{ env.VERSION }}"
```

### Branch Protection

Consider tag protection in repository settings:

- Protect important tags from deletion
- Require reviews for tag creation
- Restrict tag creation to specific users/teams

## 📄 License

This action is part of the GitHub Actions collection by Francois Raminosona.

---

> 💡 **Tip**: Combine this action with our version generation and release creation actions for complete automated release workflows.
