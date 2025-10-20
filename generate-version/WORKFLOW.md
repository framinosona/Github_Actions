# 🔢 Generate Version Workflow (Reusable)

A ready-to-use GitHub reusable workflow that handles repository checkout, version generation, and artifact management in a single job. Perfect for integrating semantic versioning into your CI/CD pipelines.

## ✨ Features

- 🔄 **Complete Workflow** - Handles checkout, version generation, and artifact upload
- 📤 **Exposed Outputs** - All version information available as job outputs
- 📦 **Artifact Management** - Automatic upload of generated version files
- 🛡️ **Input Validation** - Comprehensive validation through the underlying action
- 🎯 **Configurable** - All original action inputs plus workflow-specific options
- 📊 **Rich Summary** - Detailed job summary with version information

## 🚀 Basic Usage

### Simple Version Generation

```yaml
name: "Build with Version"

on:
  push:
    branches: ["main", "develop"]
  pull_request:
    branches: ["main"]

jobs:
  version:
    uses: framinosona/github_actions/generate-version/workflow.yml@main
    with:
      major: "1"
      minor: "0"
      tag-prefix: "v"

  build:
    needs: version
    runs-on: ubuntu-latest
    steps:
      - name: "📥 Checkout"
        uses: actions/checkout@v4

      - name: "🔨 Build with version"
        run: |
          echo "Building version: ${{ needs.version.outputs.version-full }}"
          # Your build commands here
        env:
          VERSION: ${{ needs.version.outputs.version-full }}
          VERSION_CORE: ${{ needs.version.outputs.version-core }}
          VERSION_ASSEMBLY: ${{ needs.version.outputs.version-assembly }}
```

### Using Configuration File

```yaml
jobs:
  version:
    uses: framinosona/github_actions/generate-version/workflow.yml@main
    with:
      config-file: "./version.json"
      tag-prefix: "v"
      output-props: "./src/Version.props"

  build:
    needs: version
    runs-on: ubuntu-latest
    steps:
      - name: "📥 Download version artifacts"
        uses: actions/download-artifact@v4
        with:
          name: version-files

      - name: "🔧 Use version files"
        run: |
          cat version.json
          if [ -f "./src/Version.props" ]; then
            echo "Props file generated successfully"
          fi
```

## 🔧 Advanced Configuration

### Complete Configuration Example

```yaml
jobs:
  version:
    uses: framinosona/github_actions/generate-version/workflow.yml@main
    with:
      # Version configuration
      config-file: "./config/version.json"
      major: "2"                                    # Alternative to config-file
      minor: "1"                                    # Alternative to config-file

      # Branch and build settings
      main-branch: "main"
      build-id: ${{ github.run_number }}
      tag-prefix: "release-"
      branch-suffix-max-length: "30"

      # Output file generation
      output-txt: "./build/version.env"
      output-props: "./src/Directory.Build.props"
      output-json: "./build/version.json"

      # Git and workflow settings
      fetch-depth: "0"
      show-summary: true
      dry-run: false

      # Artifact management
      upload-artifacts: true
      artifact-name: "version-metadata"
      artifact-retention-days: 90

  deploy:
    needs: version
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: "🚀 Deploy version ${{ needs.version.outputs.version-full }}"
        run: |
          echo "Deploying ${{ needs.version.outputs.version-fortag }}"
          # Deployment logic here
```

### Multi-Platform Build Example

```yaml
name: "Multi-Platform Build"

on:
  push:
    branches: ["main"]
    tags: ["v*"]

jobs:
  version:
    uses: framinosona/github_actions/generate-version/workflow.yml@main
    with:
      major: "1"
      minor: "0"
      output-json: "./version.json"
      artifact-name: "build-version"

  build:
    needs: version
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
    runs-on: ${{ matrix.os }}

    steps:
      - name: "📥 Checkout"
        uses: actions/checkout@v4

      - name: "📦 Download version"
        uses: actions/download-artifact@v4
        with:
          name: build-version

      - name: "🔨 Build for ${{ matrix.os }}"
        run: |
          echo "Building version ${{ needs.version.outputs.version-full }} on ${{ matrix.os }}"
          # Platform-specific build commands
```

## 📋 Inputs

All inputs from the original `generate-version` action plus workflow-specific options:

### Version Configuration

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `config-file` | Path to version.json file | ⚠️ No* | `""` | `./version.json` |
| `major` | Major version number | ⚠️ No* | `""` | `1`, `2`, `3` |
| `minor` | Minor version number | ⚠️ No* | `""` | `0`, `1`, `5` |

> **Note**: Either `config-file` OR both `major` and `minor` must be provided.

### Branch and Build Settings

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `main-branch` | Name of the main branch | ❌ No | Repository default | `main`, `develop` |
| `build-id` | Build ID for revision numbering | ❌ No | `${{ github.run_number }}` | `123` |
| `tag-prefix` | Prefix for version tags | ❌ No | `"v"` | `v`, `release-` |
| `branch-suffix-max-length` | Maximum length for branch name suffix | ❌ No | `"40"` | `30`, `50` |

### Output File Generation

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `output-txt` | Path to output txt file | ❌ No | `"./version.txt"` | `./build/version.env` |
| `output-props` | Path to output .NET props file | ❌ No | `""` | `./src/Version.props` |
| `output-json` | Path to output JSON file | ❌ No | `"./version.json"` | `./build/version.json` |

### Workflow Settings

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `fetch-depth` | Git history depth to fetch | ❌ No | `"0"` | `50`, `100` |
| `show-summary` | Whether to show action summary | ❌ No | `true` | `false` |
| `dry-run` | Generate versions without files | ❌ No | `false` | `true` |

### Artifact Management

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `upload-artifacts` | Whether to upload generated files | ❌ No | `true` | `false` |
| `artifact-name` | Name for the uploaded artifact | ❌ No | `"version-files"` | `"build-metadata"` |
| `artifact-retention-days` | Days to retain the artifact | ❌ No | `30` | `90`, `7` |

## 📤 Outputs

All outputs from the original action are exposed with kebab-case naming:

### Core Version Information

| Output | Description | Example |
|--------|-------------|---------|
| `version-major` | Major version number | `1` |
| `version-minor` | Minor version number | `2` |
| `version-patch` | Patch version number | `3` |
| `version-core` | Core version (major.minor.patch) | `1.2.3` |
| `version-full` | Full version with extensions | `1.2.3-feature.123` |
| `version-assembly` | Assembly version for .NET | `1.2.3.123` |
| `version-fortag` | Version string for Git tags | `v1.2.3` |

### Branch and Build Information

| Output | Description | Example |
|--------|-------------|---------|
| `version-branchname` | Current branch name | `feature/new-api` |
| `version-suffix` | Version suffix for branches | `feature-new-api` |
| `version-revision` | Revision number | `123` |
| `version-isprerelease` | Whether this is a prerelease | `true`, `false` |
| `version-buildid` | Build ID used | `123` |
| `version-prefix` | Tag prefix | `v` |

### File and Tag Information

| Output | Description | Example |
|--------|-------------|---------|
| `version-outputtxt` | Path to generated txt file | `./version.txt` |
| `version-outputprops` | Path to generated props file | `./src/Version.props` |
| `version-outputjson` | Path to generated JSON file | `./version.json` |
| `version-tag-exists` | Whether tag already exists | `true`, `false` |
| `version-latest-tag` | Latest tag found | `v1.2.2` |

## 📦 Artifacts

When `upload-artifacts` is `true` (default), the workflow uploads generated files as artifacts:

### Default Artifact Structure

```text
version-files/
├── version.txt      # Key=value pairs (if output-txt specified)
├── version.json     # JSON format (if output-json specified)
└── Version.props    # .NET props file (if output-props specified)
```

### Using Artifacts in Other Jobs

```yaml
jobs:
  version:
    uses: framinosona/github_actions/generate-version/workflow.yml@main
    with:
      major: "1"
      minor: "0"
      output-props: "./src/Version.props"

  build:
    needs: version
    runs-on: ubuntu-latest
    steps:
      - name: "📥 Checkout"
        uses: actions/checkout@v4

      - name: "📦 Download version files"
        uses: actions/download-artifact@v4
        with:
          name: version-files

      - name: "🔧 Use version in build"
        run: |
          # Load version variables
          source version.txt
          echo "Building version: $VERSION_FULL"

          # Use .NET props file
          if [ -f "Version.props" ]; then
            cp Version.props ./src/
          fi
```

## 🌿 Branch Behavior

The workflow automatically handles different branch types:

| Branch Type | Version Format | Prerelease | Example |
|-------------|----------------|------------|---------|
| Main branch | `major.minor.patch` | `false` | `1.2.3` |
| Feature branches | `major.minor.patch-suffix.revision` | `true` | `1.2.3-feature-api.123` |
| Other branches | `major.minor.patch-suffix.revision` | `true` | `1.2.3-develop.456` |

## 💡 Use Cases

### 1. Simple CI/CD with Version

```yaml
name: "CI/CD Pipeline"

on:
  push:
    branches: ["main"]

jobs:
  version:
    uses: framinosona/github_actions/generate-version/workflow.yml@main
    with:
      major: "1"
      minor: "0"

  test:
    needs: version
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: "🧪 Run tests for v${{ needs.version.outputs.version-core }}"
        run: npm test

  deploy:
    needs: [version, test]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: "🚀 Deploy ${{ needs.version.outputs.version-fortag }}"
        run: echo "Deploying..."
```

### 2. .NET Build with Version Props

```yaml
jobs:
  version:
    uses: framinosona/github_actions/generate-version/workflow.yml@main
    with:
      config-file: "./version.json"
      output-props: "./Directory.Build.props"

  build:
    needs: version
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/download-artifact@v4
        with:
          name: version-files
      - name: "🔧 Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"
      - name: "🔨 Build with version"
        run: dotnet build -c Release
```

### 3. Multi-Output Versioning

```yaml
jobs:
  version:
    uses: framinosona/github_actions/generate-version/workflow.yml@main
    with:
      major: "2"
      minor: "1"
      output-txt: "./build.env"
      output-json: "./package.json"
      output-props: "./src/Version.props"
      artifact-name: "build-metadata"
      artifact-retention-days: 90

  package:
    needs: version
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/download-artifact@v4
        with:
          name: build-metadata
      - name: "📦 Package with version"
        run: |
          source build.env
          echo "Packaging version: $VERSION_FULL"
```

## 🔗 Integration Examples

### With Release Creation

```yaml
jobs:
  version:
    uses: framinosona/github_actions/generate-version/workflow.yml@main
    with:
      major: "1"
      minor: "0"

  release:
    needs: version
    if: github.ref == 'refs/heads/main' && needs.version.outputs.version-tag-exists == 'false'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: "🏷️ Create tag"
        run: |
          git tag ${{ needs.version.outputs.version-fortag }}
          git push origin ${{ needs.version.outputs.version-fortag }}
      - name: "🚀 Create release"
        uses: actions/create-release@v1
        with:
          tag_name: ${{ needs.version.outputs.version-fortag }}
          release_name: Release ${{ needs.version.outputs.version-fortag }}
```

### With Docker Build

```yaml
jobs:
  version:
    uses: framinosona/github_actions/generate-version/workflow.yml@main
    with:
      major: "1"
      minor: "0"

  docker:
    needs: version
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: "🐳 Build Docker image"
        run: |
          docker build \
            --tag myapp:${{ needs.version.outputs.version-full }} \
            --tag myapp:latest \
            --build-arg VERSION=${{ needs.version.outputs.version-full }} \
            .
```

## 🛡️ Permissions

The workflow only requires basic permissions:

```yaml
permissions:
  contents: read  # Required for checkout and Git operations
```

For workflows that create tags or releases, additional permissions may be needed:

```yaml
permissions:
  contents: write  # Required for tag/release creation
```

## 🧪 Testing and Debugging

### Dry Run Mode

```yaml
jobs:
  test-version:
    uses: framinosona/github_actions/generate-version/workflow.yml@main
    with:
      major: "1"
      minor: "0"
      dry-run: true  # Generate versions without creating files
      show-summary: true
```

### Debug with Summary

```yaml
jobs:
  debug-version:
    uses: framinosona/github_actions/generate-version/workflow.yml@main
    with:
      major: "1"
      minor: "0"
      show-summary: true  # Shows detailed version information
      fetch-depth: "0"    # Ensures full Git history
```

## 📊 Comparison: Action vs Workflow Job

| Feature | Standalone Action | Reusable Workflow |
|---------|------------------|------------------|
| **Setup Required** | Manual checkout + action call | Single workflow call |
| **Artifact Handling** | Manual upload | Automatic upload |
| **Output Management** | Manual output mapping | Pre-configured outputs |
| **Summary Generation** | Optional | Automatic with rich formatting |
| **Flexibility** | Full control | Opinionated defaults |
| **Complexity** | Higher | Lower |
| **Best For** | Custom integrations | Standard CI/CD pipelines |

## 🔧 Requirements

- GitHub repository with Git history
- Either `config-file` OR both `major` and `minor` parameters
- `actions/checkout@v4` compatibility
- `actions/upload-artifact@v4` compatibility (for artifacts)

## 📝 Migration Guide

### From Standalone Action

**Before (using action directly):**

```yaml
steps:
  - uses: actions/checkout@v4
    with:
      fetch-depth: 0
  - name: "Generate version"
    id: version
    uses: framinosona/github_actions/generate-version@main
    with:
      major: "1"
      minor: "0"
  - name: "Upload artifacts"
    uses: actions/upload-artifact@v4
    with:
      name: version-files
      path: version.txt
```

**After (using reusable workflow):**

```yaml
jobs:
  version:
    uses: framinosona/github_actions/generate-version/workflow.yml@main
    with:
      major: "1"
      minor: "0"
```

## 📄 License

This reusable workflow is part of the GitHub Actions collection by Francois Raminosona.

---

> 💡 **Tip**: Use this reusable workflow for standardized version generation across multiple repositories while maintaining consistency and reducing boilerplate code.
