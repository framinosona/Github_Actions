# 🔢 Generate Version Action

Intelligent semantic version generation based on Git tags, branch analysis, and build metadata.

## Features

- 🔍 **Git Tag Analysis** - Automatically finds and increments patch versions based on existing tags
- 🌿 **Branch-Aware Versioning** - Different versioning strategies for main vs feature branches
- 📦 **Multiple Output Formats** - Environment variables, action outputs, txt files, and .NET props
- 🏷️ **Flexible Tag Patterns** - Supports custom tag prefixes and semantic versioning
- 🔄 **Build Integration** - Incorporates build IDs and revision numbers
- 📊 **Comprehensive Outputs** - 12+ version components for various use cases

## Usage

### Basic Usage

Generate version for main branch (major.minor.patch):

```yaml
- name: Generate Version
  uses: ./generate-version
  with:
    major: '1'
    minor: '2'
```

### Feature Branch Versioning

Generate version for feature branch with suffix and revision:

```yaml
- name: Generate Feature Version
  uses: ./generate-version
  with:
    major: '1'
    minor: '3'
    build-id: ${{ github.run_number }}
```

### Complete Integration with File Outputs

```yaml
- name: Generate Version with Outputs
  uses: ./generate-version
  with:
    major: '2'
    minor: '0'
    tag-prefix: 'v'
    output-txt: 'version.txt'
    output-props: 'Directory.Build.props'
    main-branch: 'main'
```

## Inputs

### Required Inputs

| Input | Description | Example |
|-------|-------------|---------|
| `major` | Major version number | `1` |
| `minor` | Minor version number | `2` |

### Optional Inputs

| Input | Description | Default | Example |
|-------|-------------|---------|---------|
| `main-branch` | Name of the main branch | `main` | `master` |
| `build-id` | Build ID for revision numbering | `${{ github.run_number }}` | `42` |
| `tag-prefix` | Prefix for version tags | `v` | `release-` |
| `branch-suffix-max-length` | Max length for branch name suffix | `20` | `15` |
| `output-txt` | Path to output txt file | `''` | `version.txt` |
| `output-props` | Path to output .NET props file | `''` | `Directory.Build.props` |
| `fetch-depth` | Git history depth for tag analysis | `0` | `100` |
| `show-summary` | Show action summary | `true` | `false` |

## Outputs

### Version Components

| Output | Description | Example (Main) | Example (Feature) |
|--------|-------------|----------------|-------------------|
| `VERSION_MAJOR` | Major version number | `1` | `1` |
| `VERSION_MINOR` | Minor version number | `2` | `2` |
| `VERSION_PATCH` | Auto-incremented patch | `3` | `3` |
| `VERSION_CORE` | Core semantic version | `1.2.3` | `1.2.3` |
| `VERSION_FULL` | Full version string | `1.2.3` | `1.2.3-feature-xyz.42` |
| `VERSION_ASSEMBLY` | .NET assembly version | `1.2.3.100` | `1.2.3.100` |

### Branch-Specific Components

| Output | Description | Example (Main) | Example (Feature) |
|--------|-------------|----------------|-------------------|
| `VERSION_SUFFIX` | Branch name suffix | `''` | `feature-xyz` |
| `VERSION_REVISION` | Build revision | `''` | `42` |
| `VERSION_EXTENSION` | Complete extension | `''` | `feature-xyz.42` |
| `VERSION_BRANCHNAME` | Current branch name | `main` | `feature/xyz` |
| `VERSION_BUILDID` | Build identifier | `100` | `100` |

### File Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `VERSION_OUTPUTTXT` | Path to generated txt file | `version.txt` |
| `VERSION_OUTPUTPROPS` | Path to generated props file | `Directory.Build.props` |

## Versioning Logic

### Patch Version Calculation

The action analyzes existing Git tags to determine the next patch version:

1. **Find Matching Tags**: Searches for tags matching `{prefix}{major}.{minor}.*` pattern
2. **Extract Highest Patch**: Finds the highest patch number from matching tags
3. **Increment**: Increments the patch number by 1
4. **New Series**: If no matching tags found, starts patch at 0

### Branch-Based Versioning

#### Main Branch

- **Core Version**: `{major}.{minor}.{patch}`
- **Full Version**: Same as core version
- **No Suffix/Revision**: Clean semantic version

#### Feature Branches

- **Core Version**: `{major}.{minor}.{patch}`
- **Suffix**: Sanitized branch name (max length configurable)
- **Revision**: Build ID
- **Full Version**: `{major}.{minor}.{patch}-{suffix}.{revision}`

### Version Examples

| Scenario | Core | Full | Assembly |
|----------|------|------|----------|
| Main branch, no existing tags | `1.0.0` | `1.0.0` | `1.0.0.100` |
| Main branch, existing v1.0.2 | `1.0.3` | `1.0.3` | `1.0.3.100` |
| Feature branch `feature/auth` | `1.0.3` | `1.0.3-feature-auth.100` | `1.0.3.100` |
| Branch `hotfix/fix-login-bug` | `1.1.0` | `1.1.0-hotfix-fix-login-bu.100` | `1.1.0.100` |

## Examples

### Complete CI/CD Pipeline

```yaml
name: Build and Release

on:
  push:
    branches: [ main, 'feature/*', 'hotfix/*' ]
  pull_request:
    branches: [ main ]

jobs:
  version:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.VERSION_FULL }}
      core: ${{ steps.version.outputs.VERSION_CORE }}
      assembly: ${{ steps.version.outputs.VERSION_ASSEMBLY }}
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0  # Required for tag analysis

    - name: Generate Version
      id: version
      uses: ./generate-version
      with:
        major: '1'
        minor: '0'
        tag-prefix: 'v'
        output-txt: 'version.txt'
        output-props: 'Directory.Build.props'

    - name: Upload Version Files
      uses: actions/upload-artifact@v4
      with:
        name: version-files
        path: |
          version.txt
          Directory.Build.props

  build:
    needs: version
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Download Version Files
      uses: actions/download-artifact@v4
      with:
        name: version-files

    - name: Build with Version
      run: |
        echo "Building version: ${{ needs.version.outputs.version }}"
        # Your build commands here
        dotnet build -p:Version=${{ needs.version.outputs.core }}
```

### Release Workflow

```yaml
name: Release

on:
  workflow_dispatch:
    inputs:
      major:
        description: 'Major version'
        required: true
        default: '1'
      minor:
        description: 'Minor version'
        required: true
        default: '0'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0

    - name: Generate Release Version
      id: version
      uses: ./generate-version
      with:
        major: ${{ github.event.inputs.major }}
        minor: ${{ github.event.inputs.minor }}
        main-branch: 'main'

    - name: Create Git Tag
      run: |
        git tag v${{ steps.version.outputs.VERSION_CORE }}
        git push origin v${{ steps.version.outputs.VERSION_CORE }}

    - name: Create GitHub Release
      uses: ./github-release
      with:
        tag: v${{ steps.version.outputs.VERSION_CORE }}
        title: 'Release v${{ steps.version.outputs.VERSION_CORE }}'
        generate-notes: 'true'
```

### .NET Project Integration

```yaml
- name: Generate .NET Version
  uses: ./generate-version
  with:
    major: '2'
    minor: '1'
    output-props: 'src/Directory.Build.props'

- name: Build .NET Project
  run: |
    dotnet restore
    dotnet build --configuration Release
    dotnet pack --configuration Release
```

### Multi-Environment Versioning

```yaml
strategy:
  matrix:
    environment: [development, staging, production]
    include:
      - environment: development
        major: '0'
        minor: '1'
        branch: 'develop'
      - environment: staging
        major: '1'
        minor: '0'
        branch: 'staging'
      - environment: production
        major: '1'
        minor: '0'
        branch: 'main'

steps:
- name: Generate Environment Version
  uses: ./generate-version
  with:
    major: ${{ matrix.major }}
    minor: ${{ matrix.minor }}
    main-branch: ${{ matrix.branch }}
    output-txt: 'version-${{ matrix.environment }}.txt'
```

## Output File Formats

### Key=Value Text File (output-txt)

```
VERSION_MAJOR=1
VERSION_MINOR=2
VERSION_PATCH=3
VERSION_SUFFIX=feature-auth
VERSION_REVISION=42
VERSION_BUILDID=100
VERSION_CORE=1.2.3
VERSION_EXTENSION=feature-auth.42
VERSION_FULL=1.2.3-feature-auth.42
VERSION_ASSEMBLY=1.2.3.100
VERSION_BRANCHNAME=feature/auth
VERSION_SCRIPTCALLED=true
```

### .NET Props File (output-props)

```xml
<Project>
    <PropertyGroup>
        <Version_Major>1</Version_Major>
        <Version_Minor>2</Version_Minor>
        <Version_Patch>3</Version_Patch>
        <Version_Suffix>feature-auth</Version_Suffix>
        <Version_Revision>42</Version_Revision>
        <Version_BuildId>100</Version_BuildId>
        <Version_Core>1.2.3</Version_Core>
        <Version_Extension>feature-auth.42</Version_Extension>
        <Version_Full>1.2.3-feature-auth.42</Version_Full>
        <Version_Assembly>1.2.3.100</Version_Assembly>
        <Version_BranchName>feature/auth</Version_BranchName>
        <Version_ScriptCalled>true</Version_ScriptCalled>
    </PropertyGroup>
</Project>
```

## Requirements

### Prerequisites

- **Git Repository** - Must be a Git repository with appropriate history
- **Git Tags** - Uses existing tags for patch version calculation
- **Branch Information** - Requires branch context for suffix generation

### Dependencies

- **Git** - For tag analysis and branch detection (pre-installed on runners)
- **Bash** - For shell script execution (available on all runners)

### Supported Platforms

- ✅ Linux (ubuntu-latest)
- ✅ macOS (macos-latest)
- ✅ Windows (windows-latest)

## Advanced Configuration

### Tag Patterns

The action supports various tag patterns:

```yaml
# Standard semantic versioning
tag-prefix: 'v'          # Matches: v1.0.0, v1.0.1, v1.1.0

# Release prefixes
tag-prefix: 'release-'   # Matches: release-1.0.0, release-1.0.1

# No prefix
tag-prefix: ''           # Matches: 1.0.0, 1.0.1, 1.1.0

# Custom prefixes
tag-prefix: 'app-v'      # Matches: app-v1.0.0, app-v1.0.1
```

### Branch Name Sanitization

Branch names are sanitized for use as version suffixes:

| Original Branch | Sanitized Suffix | Max Length 10 |
|----------------|------------------|---------------|
| `feature/user-auth` | `feature-user-auth` | `feature-us` |
| `hotfix/Fix_Login_Bug` | `hotfix-fix-login-bug` | `hotfix-fix` |
| `develop` | `develop` | `develop` |
| `release/2.0` | `release-2-0` | `release-2` |

### Custom Build IDs

```yaml
# Use timestamp as build ID
- name: Generate with Timestamp
  uses: ./generate-version
  with:
    major: '1'
    minor: '0'
    build-id: ${{ github.run_number }}.${{ github.run_attempt }}

# Use commit hash as build ID
- name: Generate with Commit
  uses: ./generate-version
  with:
    major: '1'
    minor: '0'
    build-id: ${{ github.sha }}
```

## Troubleshooting

### Common Issues

#### ❌ No Git Tags Found

```
Found 0 existing tags
```

**Solutions:**

1. Ensure `fetch-depth: 0` in checkout action
2. Create initial tags if repository is new
3. Check tag prefix matches existing tags

#### ❌ Invalid Version Numbers

```
Error: Major version must be a non-negative integer
```

**Solutions:**

1. Ensure major/minor are numeric strings
2. Use quotes around version numbers in YAML
3. Validate input values before passing to action

#### ❌ Git History Issues

```
Error: Failed to fetch Git history
```

**Solutions:**

1. Use `fetch-depth: 0` for full history
2. Ensure repository has proper Git setup
3. Check repository permissions

### Debug Mode

Enable verbose output:

```yaml
- name: Debug Version Generation
  uses: ./generate-version
  with:
    major: '1'
    minor: '0'
  env:
    ACTIONS_STEP_DEBUG: true
```

### Manual Testing

Test version generation locally:

```bash
# Set up environment
export GITHUB_REF_NAME="feature/test"
export GITHUB_RUN_NUMBER="123"

# Run version generation logic
major=1
minor=0
git tag -l "v${major}.${minor}.*" | sort -V | tail -1
```

## Integration Patterns

### Docker Builds

```yaml
- name: Generate Docker Version
  id: version
  uses: ./generate-version
  with:
    major: '1'
    minor: '0'

- name: Build Docker Image
  run: |
    docker build \
      --build-arg VERSION=${{ steps.version.outputs.VERSION_FULL }} \
      --tag myapp:${{ steps.version.outputs.VERSION_CORE }} \
      --tag myapp:latest \
      .
```

### Artifact Naming

```yaml
- name: Upload Artifacts with Version
  uses: actions/upload-artifact@v4
  with:
    name: myapp-${{ steps.version.outputs.VERSION_FULL }}
    path: dist/
```

### Environment Deployment

```yaml
- name: Deploy to Environment
  run: |
    echo "Deploying version ${{ steps.version.outputs.VERSION_FULL }}"
    kubectl set image deployment/myapp \
      container=${{ steps.version.outputs.VERSION_CORE }}
```

## Security Considerations

### File Permissions

Generated files inherit default permissions. For sensitive environments:

```yaml
- name: Secure Generated Files
  run: |
    chmod 600 version.txt Directory.Build.props
```

### Branch Protection

Ensure version consistency with branch protection:

```yaml
# Only allow version generation on protected branches
- name: Check Branch
  if: github.ref != 'refs/heads/main'
  run: echo "Feature branch version: ${{ steps.version.outputs.VERSION_FULL }}"
```

## Contributing

When contributing to this action:

1. Follow the [Actions Guidelines](../.github/copilot-instructions.md)
2. Test with various Git tag scenarios
3. Ensure cross-platform compatibility
4. Update documentation for new features
5. Test with different branching strategies

## License

This action is distributed under the same license as the repository.

## Support

For issues related to:

- **Git operations:** Check [Git Documentation](https://git-scm.com/doc)
- **Semantic versioning:** Check [SemVer Specification](https://semver.org/)
- **Action bugs:** Create an issue in this repository
- **GitHub Actions:** Check [GitHub Actions Documentation](https://docs.github.com/en/actions)
