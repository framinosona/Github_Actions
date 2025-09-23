# 🏷️ Git Tag Action

Create and push Git tags with comprehensive validation, configuration, and error handling.

## Features

- 🏷️ **Flexible Tag Creation** - Support for both lightweight and annotated tags
- 🔍 **Tag Validation** - Comprehensive validation of tag names and Git requirements
- 🔄 **Conflict Resolution** - Handle existing tags with force or fail options
- 🎯 **Target Control** - Tag specific commits, branches, or HEAD
- 🚀 **Automatic Push** - Optional pushing to remote repository
- 📝 **Rich Outputs** - Detailed information about created tags
- 🛡️ **Authentication** - Secure GitHub token handling

## Usage

### Basic Usage

Create a simple tag:

```yaml
- name: Create Tag
  uses: ./git-tag
  with:
    tag: 'v1.0.0'
```

### Advanced Usage

Create an annotated tag with custom message and push:

```yaml
- name: Create Release Tag
  uses: ./git-tag
  with:
    tag: '1.0.0'
    prefix: 'v'
    message: 'Release version 1.0.0 with new features'
    annotated: 'true'
    push: 'true'
    target: 'main'
```

### Integration with Version Generation

```yaml
- name: Generate Version
  id: version
  uses: ./generate-version
  with:
    major: '1'
    minor: '0'

- name: Create Version Tag
  uses: ./git-tag
  with:
    tag: ${{ steps.version.outputs.VERSION_CORE }}
    prefix: 'v'
    message: 'Automated release ${{ steps.version.outputs.VERSION_FULL }}'
```

## Inputs

### Required Inputs

| Input | Description | Example |
|-------|-------------|---------|
| `tag` | Tag name to create | `1.0.0` |

### Optional Inputs

| Input | Description | Default | Example |
|-------|-------------|---------|---------|
| `message` | Tag message (for annotated tags) | `''` | `Release version 1.0.0` |
| `prefix` | Prefix to add to tag name | `''` | `v` |
| `annotated` | Create annotated tag | `true` | `false` |
| `push` | Push tag to remote | `true` | `false` |
| `force` | Force create/update existing tag | `false` | `true` |
| `fail-if-exists` | Fail if tag already exists | `true` | `false` |
| `git-user-name` | Git user name | `${{ github.actor }}` | `Release Bot` |
| `git-user-email` | Git user email | `${{ github.actor }}@users.noreply.github.com` | `bot@example.com` |
| `target` | Target commit/branch/SHA | `''` | `main` |
| `github-token` | GitHub token for auth | `${{ github.token }}` | `${{ secrets.GITHUB_TOKEN }}` |
| `show-summary` | Show action summary | `true` | `false` |

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `tag-name` | Full tag name (with prefix) | `v1.0.0` |
| `tag-exists` | Whether tag already existed | `false` |
| `tag-sha` | SHA of tagged commit | `a1b2c3d...` |
| `tag-created` | Whether new tag was created | `true` |
| `tag-pushed` | Whether tag was pushed | `true` |
| `tag-url` | GitHub URL to the tag | `https://github.com/owner/repo/releases/tag/v1.0.0` |

## Examples

### Complete Release Workflow

```yaml
name: Release

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Release version'
        required: true
        default: '1.0.0'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0

    - name: Create Release Tag
      id: tag
      uses: ./git-tag
      with:
        tag: ${{ github.event.inputs.version }}
        prefix: 'v'
        message: |
          Release version ${{ github.event.inputs.version }}

          Created from commit: ${{ github.sha }}
          Created by: ${{ github.actor }}
        annotated: 'true'
        push: 'true'

    - name: Create GitHub Release
      uses: ./github-release
      with:
        tag: ${{ steps.tag.outputs.tag-name }}
        title: 'Release ${{ steps.tag.outputs.tag-name }}'
        generate-notes: 'true'
```

### Automated Versioning Pipeline

```yaml
name: Auto Version and Tag

on:
  push:
    branches: [ main ]

jobs:
  version-and-tag:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0

    - name: Generate Version
      id: version
      uses: ./generate-version
      with:
        major: '1'
        minor: '0'

    - name: Create Tag
      id: tag
      uses: ./git-tag
      with:
        tag: ${{ steps.version.outputs.VERSION_CORE }}
        prefix: 'v'
        message: 'Automated tag for version ${{ steps.version.outputs.VERSION_FULL }}'
        fail-if-exists: 'false'  # Don't fail if tag exists

    - name: Report Results
      run: |
        echo "Created tag: ${{ steps.tag.outputs.tag-name }}"
        echo "Tag URL: ${{ steps.tag.outputs.tag-url }}"
        echo "Was new tag: ${{ steps.tag.outputs.tag-created }}"
```

### Development Branch Tagging

```yaml
- name: Create Development Tag
  uses: ./git-tag
  with:
    tag: ${{ github.run_number }}
    prefix: 'dev-'
    message: 'Development build from ${{ github.ref_name }}'
    target: ${{ github.sha }}
    push: 'true'
    fail-if-exists: 'false'
```

### Force Update Existing Tag

```yaml
- name: Update Latest Tag
  uses: ./git-tag
  with:
    tag: 'latest'
    message: 'Latest stable version'
    force: 'true'  # Will update existing 'latest' tag
    push: 'true'
```

### Multi-Environment Tagging

```yaml
strategy:
  matrix:
    environment: [dev, staging, prod]
    include:
      - environment: dev
        prefix: 'dev-'
        target: 'develop'
      - environment: staging
        prefix: 'staging-'
        target: 'staging'
      - environment: prod
        prefix: 'v'
        target: 'main'

steps:
- name: Create Environment Tag
  uses: ./git-tag
  with:
    tag: ${{ env.VERSION }}
    prefix: ${{ matrix.prefix }}
    target: ${{ matrix.target }}
    message: 'Release for ${{ matrix.environment }} environment'
```

### Conditional Tagging

```yaml
- name: Create Tag on Main Branch Only
  if: github.ref == 'refs/heads/main'
  uses: ./git-tag
  with:
    tag: ${{ env.RELEASE_VERSION }}
    prefix: 'v'
    message: 'Production release ${{ env.RELEASE_VERSION }}'

- name: Create Pre-release Tag on Other Branches
  if: github.ref != 'refs/heads/main'
  uses: ./git-tag
  with:
    tag: ${{ env.RELEASE_VERSION }}-${{ github.ref_name }}
    prefix: 'pre-'
    message: 'Pre-release from branch ${{ github.ref_name }}'
```

### Rollback Tag Creation

```yaml
- name: Create Rollback Tag
  uses: ./git-tag
  with:
    tag: 'rollback-${{ github.run_number }}'
    message: 'Rollback point before deployment'
    target: 'HEAD~1'  # Tag the previous commit
    push: 'true'
```

## Tag Types

### Lightweight Tags

Simple pointers to commits:

```yaml
- name: Create Lightweight Tag
  uses: ./git-tag
  with:
    tag: 'checkpoint-1'
    annotated: 'false'
```

### Annotated Tags

Full Git objects with metadata:

```yaml
- name: Create Annotated Tag
  uses: ./git-tag
  with:
    tag: 'v1.0.0'
    annotated: 'true'
    message: |
      Release version 1.0.0

      Features:
      - New authentication system
      - Improved performance
      - Bug fixes

      Breaking Changes:
      - API endpoint changes
```

## Error Handling

### Tag Already Exists

```yaml
# Option 1: Fail if tag exists (default)
- name: Create Unique Tag
  uses: ./git-tag
  with:
    tag: 'v1.0.0'
    fail-if-exists: 'true'

# Option 2: Continue if tag exists
- name: Create Tag (Allow Existing)
  uses: ./git-tag
  with:
    tag: 'v1.0.0'
    fail-if-exists: 'false'

# Option 3: Force update existing tag
- name: Force Update Tag
  uses: ./git-tag
  with:
    tag: 'v1.0.0'
    force: 'true'
```

### Validation Errors

The action validates:
- Tag name format (no spaces, no '..' sequences)
- Email format for Git configuration
- Boolean parameter values
- Git repository state

## Requirements

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

## Advanced Configuration

### Custom Git Configuration

```yaml
- name: Create Tag with Custom Author
  uses: ./git-tag
  with:
    tag: 'v1.0.0'
    git-user-name: 'Release Bot'
    git-user-email: 'releases@company.com'
    message: 'Official release by Release Bot'
```

### Tag Naming Strategies

```yaml
# Semantic versioning
prefix: 'v'
tag: '1.0.0'
# Result: v1.0.0

# Date-based tagging
prefix: 'release-'
tag: '2024-01-15'
# Result: release-2024-01-15

# Build-based tagging
prefix: 'build-'
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
target: 'a1b2c3d4e5f6'

# Tag specific branch
target: 'main'

# Tag relative commit
target: 'HEAD~1'

# Tag from environment
target: ${{ env.DEPLOY_SHA }}
```

## Troubleshooting

### Common Issues

#### ❌ Permission Denied

```
Permission denied (publickey)
```

**Solutions:**
1. Ensure `github-token` has write permissions:
   ```yaml
   permissions:
     contents: write
   ```

2. Check repository settings allow tag creation

#### ❌ Tag Already Exists

```
Error: Tag v1.0.0 already exists and fail-if-exists is true
```

**Solutions:**
1. Use force mode:
   ```yaml
   force: 'true'
   ```

2. Allow existing tags:
   ```yaml
   fail-if-exists: 'false'
   ```

3. Use different tag name or add suffix

#### ❌ Invalid Tag Name

```
Error: Tag name cannot contain spaces
```

**Solutions:**
1. Remove spaces from tag names
2. Use hyphens instead of spaces
3. Validate tag names before passing to action

#### ❌ Target Not Found

```
Error: Target 'unknown-branch' not found
```

**Solutions:**
1. Verify target branch/commit exists
2. Use `HEAD` for current commit
3. Fetch required branches before tagging

### Debug Mode

Enable verbose output:

```yaml
- name: Debug Tag Creation
  uses: ./git-tag
  with:
    tag: 'debug-tag'
  env:
    ACTIONS_STEP_DEBUG: true
```

### Manual Verification

Verify tag creation:

```yaml
- name: Verify Tag
  run: |
    git tag -l "${{ steps.tag.outputs.tag-name }}"
    git show "${{ steps.tag.outputs.tag-name }}"
    git ls-remote --tags origin | grep "${{ steps.tag.outputs.tag-name }}"
```

## Integration Patterns

### With Docker Builds

```yaml
- name: Create Docker Tag
  id: tag
  uses: ./git-tag
  with:
    tag: ${{ env.VERSION }}
    prefix: 'docker-'

- name: Build Docker Image
  run: |
    docker build -t myapp:${{ steps.tag.outputs.tag-name }} .
    docker tag myapp:${{ steps.tag.outputs.tag-name }} myapp:latest
```

### With Artifact Versioning

```yaml
- name: Create Artifact Tag
  id: tag
  uses: ./git-tag
  with:
    tag: ${{ github.run_number }}
    prefix: 'artifact-'

- name: Upload Versioned Artifacts
  uses: actions/upload-artifact@v4
  with:
    name: build-${{ steps.tag.outputs.tag-name }}
    path: dist/
```

### With Deployment Tracking

```yaml
- name: Create Deployment Tag
  uses: ./git-tag
  with:
    tag: ${{ env.ENVIRONMENT }}-${{ env.VERSION }}
    message: 'Deployed to ${{ env.ENVIRONMENT }} at ${{ env.DEPLOY_TIME }}'
    target: ${{ env.DEPLOY_SHA }}
```

## Security Considerations

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
message: 'Release with API key: ${{ secrets.API_KEY }}'

# ✅ Use generic messages
message: 'Production release v${{ env.VERSION }}'
```

### Branch Protection

Consider tag protection in repository settings:
- Protect important tags from deletion
- Require reviews for tag creation
- Restrict tag creation to specific users/teams

## Contributing

When contributing to this action:

1. Follow the [Actions Guidelines](../.github/copilot-instructions.md)
2. Test with various Git scenarios and tag types
3. Ensure cross-platform compatibility
4. Update documentation for new features
5. Test error conditions and edge cases

## License

This action is distributed under the same license as the repository.

## Support

For issues related to:
- **Git operations:** Check [Git Documentation](https://git-scm.com/docs/git-tag)
- **GitHub tokens:** Check [GitHub Token Documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- **Action bugs:** Create an issue in this repository
- **GitHub Actions:** Check [GitHub Actions Documentation](https://docs.github.com/en/actions)
