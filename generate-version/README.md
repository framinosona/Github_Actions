# 🔢 Generate Version Action

A GitHub Action for semantic version generation based on Git tag analysis and branch information with multiple output formats.

> 🚀 **New**: Looking for a ready-to-use solution? Check out our [**Reusable Workflow**](./WORKFLOW.md) that handles checkout, version generation, and artifact management automatically!

## 📋 Quick Navigation

| What do you want to do? | Use this |
|-------------------------|----------|
| 🚀 **Get started quickly** | [**Reusable Workflow**](./WORKFLOW.md) - Complete solution |
| 🔧 **Custom integration** | **Standalone Action** (this page) - Full control |
| 🎯 **Compare approaches** | [Action vs Workflow](#-action-vs-reusable-workflow) |

## ✨ Features

- 🔍 **Git Tag Analysis** - Automatic patch version increment based on existing Git tags
- 🌿 **Branch-Aware Versioning** - Different versioning for main vs feature branches
- 📦 **Multiple Output Formats** - Text files, .NET properties, and JSON files
- 🏷️ **Configurable Tag Prefixes** - Custom prefixes for version tags
- 🔄 **Build Integration** - Build ID integration for assembly versioning
- 🛡️ **Cross-Platform** - Works on Windows, Linux, and macOS runners
- 📋 **Input Validation** - Comprehensive validation of all input parameters

## 🚀 Basic Usage

Generate version for main branch releases:

```yaml
- name: "Generate version"
  id: version
  uses: framinosona/github_actions/generate-version@main
  with:
    tag-prefix: "v"
    major: "1"
    minor: "0"
```

Or using a configuration file:

```yaml
- name: "Generate version from config"
  id: version
  uses: framinosona/github_actions/generate-version@main
  with:
    config-file: "./version.json"
    tag-prefix: "v"
```

```yaml
- name: "Generate with build metadata"
  id: version
  uses: framinosona/github_actions/generate-version@main
  with:
    tag-prefix: "v"
    major: "1"
    minor: "2"
    build-id: ${{ github.run_number }}
```

```yaml
- name: "Feature branch versioning"
  id: version
  uses: framinosona/github_actions/generate-version@main
  with:
    tag-prefix: "v"
    major: "2"
    minor: "0"
    main-branch: "main"
```

With a version configuration file (`version.json`):

```json
{
  "major": 2,
  "minor": 1
}
```

## 🎯 Action vs Reusable Workflow

Choose the right approach for your needs:

| Feature | **Standalone Action** | **[Reusable Workflow](./WORKFLOW.md)** |
|---------|----------------------|---------------------------------------|
| **Setup Complexity** | Manual checkout + action call | Single workflow call |
| **Artifact Handling** | Manual upload/download | Automatic |
| **Output Management** | Manual output mapping | Pre-configured |
| **Customization** | Full control over each step | Opinionated defaults |
| **Best For** | Custom integrations, Complex workflows | Standard CI/CD, Quick setup |

### 🚀 Quick Start with Reusable Workflow

```yaml
jobs:
  version:
    uses: framinosona/github_actions/generate-version/workflow.yml@main
    with:
      major: "1"
      minor: "0"

  build:
    needs: version
    runs-on: ubuntu-latest
    steps:
      - name: "Build v${{ needs.version.outputs.version-full }}"
        run: echo "Building..."
```

[**📖 See full workflow documentation →**](./WORKFLOW.md)

## 🔧 Advanced Usage

Full configuration with all available options:

```yaml
- name: "Advanced version generation"
  id: version
  uses: framinosona/github_actions/generate-version@main
  with:
    config-file: "./config/version.json"  # Alternative to major/minor
    major: "1"                            # Required if no config-file
    minor: "0"                            # Required if no config-file
    main-branch: "main"                   # Default branch name
    tag-prefix: "release-"                # Custom tag prefix
    build-id: ${{ github.run_number }}    # Build identifier
    branch-suffix-max-length: "40"        # Max length for branch suffix
    output-txt: "./version.txt"           # Generate text file
    output-props: "./src/Version.props"   # Generate .NET props file
    output-json: "./build/version.json"   # Generate JSON file
    fetch-depth: "0"                      # Git history depth
    show-summary: "true"                  # Show action summary
    dry-run: "false"                      # Run without generating files
```

## 🔐 Permissions Required

Basic permissions for version generation:

```yaml
permissions:
  contents: read  # Required to checkout repository and read Git history
```

If creating and pushing tags:

```yaml
permissions:
  contents: write  # Required to create and push Git tags
```

## 🏗️ CI/CD Example

Complete workflow with version generation:

```yaml
name: "Release Workflow"

on:
  push:
    branches: ["main", "release/*"]
  pull_request:
    branches: ["main"]

permissions:
  contents: read

jobs:
  build-and-release:
    runs-on: ubuntu-latest

    steps:
      - name: "📥 Checkout repository"
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Required for Git tag analysis

      - name: "🔢 Generate version"
        id: version
        uses: framinosona/github_actions/generate-version@main
        with:
          config-file: "./version.json"  # or use major: "1" and minor: "0"
          tag-prefix: "v"
          main-branch: "main"
          build-id: ${{ github.run_number }}
          output-txt: "./build/version.txt"
          output-json: "./build/version.json"
          output-props: "./src/Version.props"
          show-summary: "true"

      - name: "🔧 Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: "🔨 Build with version"
        uses: framinosona/github_actions/dotnet@main
        with:
          command: "build"
          configuration: "Release"
          verbosity: "minimal"
        env:
          VERSION_CORE: ${{ steps.version.outputs.VERSION_CORE }}
          VERSION_ASSEMBLY: ${{ steps.version.outputs.VERSION_ASSEMBLY }}
          VERSION_FULL: ${{ steps.version.outputs.VERSION_FULL }}

      - name: "📦 Pack NuGet package"
        if: github.ref == 'refs/heads/main'
        uses: framinosona/github_actions/dotnet@main
        with:
          command: "pack"
          configuration: "Release"
          output: "./packages"
        env:
          PACKAGE_VERSION: ${{ steps.version.outputs.VERSION_FULL }}
```

## 📋 Inputs

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `config-file` | Path to version.json file with major/minor | ⚠️ No* | `""` | `./version.json`, `config/version.json` |
| `major` | Major version number | ⚠️ No* | `""` | `1`, `2`, `3` |
| `minor` | Minor version number | ⚠️ No* | `""` | `0`, `1`, `5` |
| `main-branch` | Name of the main branch | ❌ No | Repository default | `main`, `master`, `develop` |
| `build-id` | Build ID for revision numbering | ❌ No | `${{ github.run_number }}` | `123`, `${{ github.run_number }}` |
| `tag-prefix` | Prefix for version tags | ❌ No | `"v"` | `v`, `release-`, `version-` |
| `branch-suffix-max-length` | Maximum length for branch name suffix | ❌ No | `"40"` | `40`, `20`, `60` |
| `output-txt` | Path to output txt file with key=value pairs | ❌ No | `""` | `./version.txt`, `./build/version.env` |
| `output-props` | Path to output .NET props file | ❌ No | `""` | `./src/Version.props`, `./Directory.Build.props` |
| `output-json` | Path to output JSON file with version information | ❌ No | `""` | `./build/version.json` |
| `fetch-depth` | Depth of Git history to fetch for tag analysis | ❌ No | `"0"` | `0`, `50`, `100` |
| `show-summary` | Whether to show the action summary | ❌ No | `"false"` | `true`, `false` |
| `dry-run` | Run in dry-run mode (generate versions but don't create output files) | ❌ No | `"false"` | `true`, `false` |

> **Note**: Either ***`config-file`*** OR both ***`major` and `minor`*** must be provided. If `config-file` is specified, it takes precedence over individual `major`/`minor` inputs.

## 📤 Outputs

| Output | Description | Type | Example |
|--------|-------------|------|---------|
| `VERSION_MAJOR` | Major version number | `string` | `1` |
| `VERSION_MINOR` | Minor version number | `string` | `2` |
| `VERSION_PATCH` | Patch version number (auto-incremented) | `string` | `3` |
| `VERSION_SUFFIX` | Version suffix (branch name for non-main branches) | `string` | `feature-new-api` |
| `VERSION_REVISION` | Revision number (build ID for non-main branches) | `string` | `123` |
| `VERSION_ISPRERELEASE` | Whether this is a prerelease version | `string` | `true`, `false` |
| `VERSION_BUILDID` | Build ID used for versioning | `string` | `123` |
| `VERSION_CORE` | Core version (major.minor.patch) | `string` | `1.2.3` |
| `VERSION_EXTENSION` | Version extension (suffix.revision for branches) | `string` | `feature-new-api.123` |
| `VERSION_FULL` | Full version (core + extension) | `string` | `1.2.3-feature-new-api.123` |
| `VERSION_ASSEMBLY` | Assembly version for .NET (major.minor.patch.buildid) | `string` | `1.2.3.123` |
| `VERSION_FORTAG` | Version string suitable for Git tags (with prefix) | `string` | `v1.2.3` |
| `VERSION_BRANCHNAME` | Current branch name | `string` | `feature/new-api` |
| `VERSION_PREFIX` | Tag prefix used for version tags | `string` | `v` |
| `VERSION_OUTPUTTXT` | Path to generated txt file (if created) | `string` | `./version.txt` |
| `VERSION_OUTPUTPROPS` | Path to generated props file (if created) | `string` | `./src/Version.props` |
| `VERSION_OUTPUTJSON` | Path to generated JSON file (if created) | `string` | `./build/version.json` |
| `VERSION_TAG_EXISTS` | Whether a tag already exists for this version | `string` | `true`, `false` |
| `VERSION_LATEST_TAG` | Latest tag found for this major.minor combination | `string` | `v1.2.2` |

## 🔗 Related Actions

| Action | Purpose | Repository |
|--------|---------|------------|
| 🏷️ **git-tag** | Create and manage Git tags | `framinosona/github_actions/git-tag` |
| 🚀 **github-release** | Create GitHub releases | `framinosona/github_actions/github-release` |
| 🎯 **generate-badge** | Generate version badges | `framinosona/github_actions/generate-badge` |
| 🔧 **dotnet** | Build with version metadata | `framinosona/github_actions/dotnet` |

## 📄 License

This action is part of the GitHub Actions collection by Francois Raminosona.

---

> 💡 **Tip**: Use this action with Git tag management and release actions for complete version workflows.

## 💡 Examples

### Configuration File Usage

```yaml
# Create version.json file
- name: "Create version config"
  run: |
    echo '{"major": 1, "minor": 2}' > version.json

- name: "Generate version from config"
  id: version
  uses: framinosona/github_actions/generate-version@main
  with:
    config-file: "version.json"
    tag-prefix: "v"
    show-summary: "true"
```

### Main Branch Release Versioning

```yaml
- name: "Generate release version"
  id: version
  uses: framinosona/github_actions/generate-version@main
  with:
    major: "1"
    minor: "0"
    tag-prefix: "v"
    main-branch: "main"
```

### Feature Branch Development

```yaml
- name: "Generate feature version"
  id: version
  uses: framinosona/github_actions/generate-version@main
  with:
    major: "1"
    minor: "1"
    main-branch: "main"
    build-id: ${{ github.run_number }}
```

### Multi-Output Generation

```yaml
- name: "Generate all version outputs"
  id: version
  uses: framinosona/github_actions/generate-version@main
  with:
    major: "2"
    minor: "0"
    output-txt: "./build/version.txt"
    output-json: "./build/version.json"
    output-props: "./src/Directory.Build.props"
    show-summary: "true"
```

### Custom Configuration

```yaml
- name: "Generate custom version"
  id: version
  uses: framinosona/github_actions/generate-version@main
  with:
    major: "1"
    minor: "5"
    tag-prefix: "release-"
    branch-suffix-max-length: "20"
    fetch-depth: "50"
```

## 🌿 Branch Behavior

| Branch Type | Behavior | Version Format | Example |
|-------------|----------|----------------|---------|
| Main branch | Clean semantic version | `major.minor.patch` | `1.2.3` |
| Feature branches | Adds branch suffix and revision | `major.minor.patch-suffix.revision` | `1.2.3-feature-api.123` |
| Any other branch | Adds branch suffix and revision | `major.minor.patch-suffix.revision` | `1.2.3-develop.456` |

The action automatically detects whether you're on the main branch or a feature branch:

- **Main branch**: Generates clean semantic versions (e.g., `1.2.3`)
- **Other branches**: Adds a sanitized branch name suffix and build ID (e.g., `1.2.3-feature-api.123`)

## 📁 Output File Formats

### JSON Version File

```json
{
  "VERSION_MAJOR": "1",
  "VERSION_MINOR": "2",
  "VERSION_PATCH": "3",
  "VERSION_PREFIX": "v",
  "VERSION_SUFFIX": "feature-api",
  "VERSION_REVISION": "123",
  "VERSION_ISPRERELEASE": true,
  "VERSION_BUILDID": "123",
  "VERSION_CORE": "1.2.3",
  "VERSION_EXTENSION": "feature-api.123",
  "VERSION_FULL": "1.2.3-feature-api.123",
  "VERSION_ASSEMBLY": "1.2.3.123",
  "VERSION_FORTAG": "v1.2.3-feature-api.123",
  "VERSION_BRANCHNAME": "feature/api",
  "VERSION_SCRIPTCALLED": true
}
```

### .NET Properties File

```xml
<!-- Version.props -->
<Project>
    <PropertyGroup>
        <Version_Major>1</Version_Major>
        <Version_Minor>2</Version_Minor>
        <Version_Patch>3</Version_Patch>
        <Version_Prefix>v</Version_Prefix>
        <Version_Suffix>feature-api</Version_Suffix>
        <Version_Revision>123</Version_Revision>
        <Version_IsPrerelease>true</Version_IsPrerelease>
        <Version_BuildId>123</Version_BuildId>
        <Version_Core>1.2.3</Version_Core>
        <Version_Extension>feature-api.123</Version_Extension>
        <Version_Full>1.2.3-feature-api.123</Version_Full>
        <Version_Assembly>1.2.3.123</Version_Assembly>
        <Version_ForTag>v1.2.3-feature-api.123</Version_ForTag>
        <Version_BranchName>feature/api</Version_BranchName>
        <Version_ScriptCalled>true</Version_ScriptCalled>
    </PropertyGroup>
</Project>
```

### Text File (Key=Value pairs)

```bash
VERSION_MAJOR=1
VERSION_MINOR=2
VERSION_PATCH=3
VERSION_PREFIX=v
VERSION_SUFFIX=feature-api
VERSION_REVISION=123
VERSION_ISPRERELEASE=true
VERSION_BUILDID=123
VERSION_CORE=1.2.3
VERSION_EXTENSION=feature-api.123
VERSION_FULL=1.2.3-feature-api.123
VERSION_ASSEMBLY=1.2.3.123
VERSION_FORTAG=v1.2.3-feature-api.123
VERSION_BRANCHNAME=feature/api
VERSION_SCRIPTCALLED=true
```

## 🐛 Troubleshooting

### Common Issues

#### No Git Tags Found

**Problem**: Cannot determine next patch version due to missing tags

**Solution**: The action will start with patch version 0:

```yaml
- name: "Generate version with no existing tags"
  uses: framinosona/github_actions/generate-version@main
  with:
    major: "1"
    minor: "0"
    # Will generate 1.0.0 if no tags exist
```

#### Shallow Git History

**Problem**: Insufficient Git history for tag analysis

**Solution**: Use fetch-depth: 0 in checkout:

```yaml
- name: "Checkout with full history"
  uses: actions/checkout@v4
  with:
    fetch-depth: 0  # Required for Git tag analysis
```

#### Invalid Configuration File

**Problem**: Config file not found or invalid JSON format

**Solution**: Ensure proper file format and location:

```bash
# Valid version.json format
{
  "major": 1,
  "minor": 0
}
```

```yaml
- name: "Validate config file exists"
  run: |
    if [ ! -f "./version.json" ]; then
      echo '{"major": 1, "minor": 0}' > version.json
    fi

- name: "Generate version"
  uses: framinosona/github_actions/generate-version@main
  with:
    config-file: "./version.json"
```

#### Missing Major/Minor Version

**Problem**: Neither config-file nor major/minor provided

**Solution**: Provide either a config file or both major and minor:

```yaml
- name: "Generate version with explicit versions"
  uses: framinosona/github_actions/generate-version@main
  with:
    major: "1"
    minor: "0"
```

### Debug Tips

1. **Enable Summary**: Set `show-summary: "true"` to see detailed output
2. **Check Git History**: Verify tags exist with `git tag --list`
3. **Validate Inputs**: Ensure major/minor are valid integers
4. **Test Locally**: Run version generation locally to debug issues

## 📊 How It Works

### Version Generation Logic

1. **Input Validation**: Validates major/minor versions and all input parameters
2. **Git History Fetch**: Fetches Git tags and history for analysis
3. **Tag Analysis**: Finds existing tags matching the major.minor pattern
4. **Patch Increment**: Auto-increments patch version from the latest matching tag
5. **Branch Detection**: Determines if on main branch or feature branch
6. **Version Assembly**: Builds final version strings based on branch type
7. **Output Generation**: Creates requested output files and sets action outputs

### Patch Version Logic

- Searches for existing Git tags with pattern: `{prefix}{major}.{minor}.{patch}`
- Finds the highest patch number for the given major.minor combination
- Increments the patch version by 1
- If no matching tags exist, starts with patch version 0

### Branch-Specific Behavior

- **Main Branch**: Generates clean semantic versions (e.g., `1.2.3`)
- **Feature Branches**: Adds sanitized branch name and build ID (e.g., `1.2.3-feature-api.123`)

## 📝 Requirements

- GitHub Actions runner (Windows, Linux, or macOS)
- Git repository with history access
- Either `config-file` OR both `major` and `minor` inputs
- Optional: Existing Git tags for patch version increment

## 🔧 Advanced Features

### Custom Tag Prefixes

```yaml
- name: "Custom prefix versioning"
  uses: framinosona/github_actions/generate-version@main
  with:
    major: "1"
    minor: "0"
    tag-prefix: "release-"  # Will generate release-1.0.0
```

### Branch Name Sanitization

The action automatically sanitizes branch names for version suffixes:

- Replaces non-alphanumeric characters with hyphens
- Converts to lowercase
- Truncates to `branch-suffix-max-length` (default: 40 characters)
- Removes leading/trailing hyphens

### Dry Run Mode

```yaml
- name: "Test version generation"
  uses: framinosona/github_actions/generate-version@main
  with:
    major: "1"
    minor: "0"
    dry-run: "true"  # Generate versions but don't create files
```

## � Related Actions

| Action | Purpose | Repository |
|--------|---------|------------|
| 🏷️ **git-tag** | Create and manage Git tags | `framinosona/github_actions/git-tag` |
| 🚀 **github-release** | Create GitHub releases | `framinosona/github_actions/github-release` |
| 🎯 **generate-badge** | Generate version badges | `framinosona/github_actions/generate-badge` |
| 🔧 **dotnet** | Build with version metadata | `framinosona/github_actions/dotnet` |

## �📄 License

This action is part of the GitHub Actions collection by Francois Raminosona.

---

> 💡 **Tip**: Use this action with Git tag management and release actions for complete version workflows.
