# 🚀 GitHub Release Creation Action

A comprehensive GitHub Action for creating GitHub releases with asset uploads using GitHub CLI with flexible configuration, multiple release note options, and advanced targeting capabilities.

## ✨ Features

- 🚀 **Complete Release Management** - Full GitHub CLI feature support for release creation
- 📦 **Advanced Asset Upload** - Upload files, directories, or glob patterns with validation
- 📝 **Flexible Release Notes** - Manual, file-based, auto-generated, or tag-based release notes
- 🎯 **Advanced Targeting** - Target specific branches, commits, or repositories
- 🔧 **Draft & Prerelease Support** - Create drafts or mark releases as pre-releases
- 💬 **Discussion Integration** - Automatically start discussions with releases
- 📊 **Comprehensive Outputs** - Detailed release information and metrics
- 🔍 **Asset Validation** - Automatic file existence and format validation

## 🚀 Basic Usage

Create a simple release with a tag:

```yaml
- name: "Create Release"
  uses: laerdal/github_actions/github-release@main
  with:
    tag: "v1.0.0"
    title: "Version 1.0.0"
    notes: "Initial release with basic functionality"
```

```yaml
- name: "Create release with assets"
  uses: laerdal/github_actions/github-release@main
  with:
    tag: "v1.2.3"
    title: "Version 1.2.3 - Bug Fixes"
    generate-notes: "true"
    assets: |
      dist/app-linux-x64.tar.gz
      dist/app-windows-x64.zip
      dist/app-macos-x64.dmg
```

```yaml
- name: "Auto-generated release"
  uses: laerdal/github_actions/github-release@main
  with:
    tag: ${{ github.ref_name }}
    generate-notes: "true"
    assets-dir: "build/artifacts"
```

## 🔧 Advanced Usage

Full configuration with all available options:

```yaml
- name: "Advanced release creation"
  uses: laerdal/github_actions/github-release@main
  with:
    tag: "v1.2.3"
    title: "Release v1.2.3 - Major Update"
    notes: |
      ## What's New
      - Enhanced performance
      - New API endpoints
      - Bug fixes and improvements

      ## Breaking Changes
      - Deprecated endpoints removed
    assets: |
      dist/app-linux-x64.tar.gz
      dist/app-windows-x64.zip
      dist/app-macos-x64.dmg
      docs/user-guide.pdf
    draft: "false"
    pre-release: "false"
    latest: "true"
    target: "main"
    verify-tag: "true"
    discussion-category: "Announcements"
    fail-on-no-commits: "false"
    assets-dir: "build/artifacts"
    repo: "myorg/myrepo"
    github-token: ${{ secrets.GITHUB_TOKEN }}
    show-summary: "true"
```

## 🔐 Permissions Required

This action requires appropriate repository permissions:

```yaml
permissions:
  contents: write      # Required for creating releases
  discussions: write   # Required if using discussion-category
```

## 🏗️ CI/CD Example

Complete workflow for automated release creation:

```yaml
name: "Release Pipeline"

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write
  discussions: write

jobs:
  build-and-release:
    runs-on: ubuntu-latest

    steps:
      - name: "📥 Checkout repository"
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: "🔧 Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: "📦 Restore dependencies"
        uses: laerdal/github_actions/dotnet@main
        with:
          command: "restore"

      - name: "🔨 Build application"
        uses: laerdal/github_actions/dotnet@main
        with:
          command: "build"
          configuration: "Release"

      - name: "📦 Create packages"
        run: |
          mkdir -p dist
          # Linux build
          dotnet publish -c Release -r linux-x64 --self-contained -o ./publish/linux-x64
          tar -czf dist/app-linux-x64.tar.gz -C ./publish/linux-x64 .

          # Windows build
          dotnet publish -c Release -r win-x64 --self-contained -o ./publish/win-x64
          cd ./publish/win-x64 && zip -r ../../dist/app-windows-x64.zip . && cd ../..

          # macOS build
          dotnet publish -c Release -r osx-x64 --self-contained -o ./publish/osx-x64
          tar -czf dist/app-macos-x64.tar.gz -C ./publish/osx-x64 .

      - name: "🚀 Create GitHub Release"
        id: release
        uses: laerdal/github_actions/github-release@main
        with:
          tag: ${{ github.ref_name }}
          title: "Release ${{ github.ref_name }}"
          generate-notes: "true"
          assets: |
            dist/app-linux-x64.tar.gz
            dist/app-windows-x64.zip
            dist/app-macos-x64.tar.gz
          latest: "true"
          discussion-category: "Announcements"
          show-summary: "true"

      - name: "📊 Report release info"
        run: |
          echo "Release created: ${{ steps.release.outputs.release-url }}"
          echo "Assets uploaded: ${{ steps.release.outputs.assets-uploaded }}"
          echo "Release ID: ${{ steps.release.outputs.release-id }}"
```

## 📋 Inputs

### Optional Inputs (All inputs are optional with sensible defaults)

| Input | Description | Default | Example |
|-------|-------------|---------|---------|
| `tag` | Git tag for the release | `''` | `v1.0.0`, `2024.1.15` |
| `title` | Release title | `''` | `Version 1.0.0`, `Weekly Release` |
| `notes` | Release notes content | `''` | `Bug fixes and improvements` |
| `notes-file` | Path to file containing release notes | `''` | `CHANGELOG.md`, `RELEASE_NOTES.md` |
| `notes-from-tag` | Use tag annotation as release notes | `false` | `true`, `false` |
| `notes-start-tag` | Starting tag for generating notes | `''` | `v1.0.0` |
| `generate-notes` | Auto-generate notes via GitHub API | `false` | `true`, `false` |
| `draft` | Save as draft instead of publishing | `false` | `true`, `false` |
| `pre-release` | Mark as pre-release | `false` | `true`, `false` |
| `latest` | Mark as latest release | `auto` | `true`, `false`, `auto` |
| `target` | Target branch or commit SHA | `''` | `main`, `develop`, `abc123` |
| `verify-tag` | Abort if tag doesn't exist remotely | `false` | `true`, `false` |
| `discussion-category` | Start discussion in category | `''` | `General`, `Announcements` |
| `fail-on-no-commits` | Fail if no new commits since last release | `false` | `true`, `false` |
| `assets` | Assets to upload (newline-separated) | `''` | `dist/*.zip`, `build/app.exe` |
| `assets-dir` | Directory containing assets | `''` | `build/dist`, `artifacts` |
| `repo` | Target repository (OWNER/REPO) | `''` | `myorg/myrepo` |
| `github-token` | GitHub token for authentication | `${{ github.token }}` | `${{ secrets.GITHUB_TOKEN }}` |
| `show-summary` | Show action summary | `true` | `false` |

## 📤 Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `release-id` | ID of the created release | `12345678` |
| `release-url` | URL of the created release | `https://github.com/owner/repo/releases/tag/v1.0.0` |
| `release-tag` | Tag of the created release | `v1.0.0` |
| `release-name` | Name/title of the created release | `Version 1.0.0` |
| `assets-uploaded` | Number of assets uploaded | `3` |
| `upload-url` | Upload URL for the release | `https://uploads.github.com/repos/...` |

## 🔗 Related Actions

| Action | Purpose | Repository |
|--------|---------|------------|
| 🔢 **generate-version** | Generate semantic versions | `laerdal/github_actions/generate-version` |
| 🏷️ **git-tag** | Create and manage Git tags | `laerdal/github_actions/git-tag` |
| 🚀 **dotnet** | Build .NET applications | `laerdal/github_actions/dotnet` |
| 🎯 **generate-badge** | Generate release badges | `laerdal/github_actions/generate-badge` |

## 💡 Examples

### Complete CI/CD Release Pipeline

```yaml
- name: "Generate version"
  id: version
  uses: laerdal/github_actions/generate-version@main
  with:
    major: "1"
    minor: "0"

- name: "Create tag"
  uses: laerdal/github_actions/git-tag@main
  with:
    tag: ${{ steps.version.outputs.version }}
    prefix: "v"
    message: "Release ${{ steps.version.outputs.version }}"

- name: "Build application"
  run: |
    # Your build commands here
    mkdir -p dist
    echo "Built app" > dist/app.txt

- name: "Create release"
  uses: laerdal/github_actions/github-release@main
  with:
    tag: "v${{ steps.version.outputs.version }}"
    title: "Release ${{ steps.version.outputs.version }}"
    generate-notes: "true"
    assets: "dist/*"
```

### Draft Release for Testing

```yaml
- name: "Create draft release"
  uses: laerdal/github_actions/github-release@main
  with:
    tag: "v2.0.0-beta.1"
    title: "Beta Release 2.0.0"
    notes: |
      🚧 **This is a beta release for testing purposes**

      ## New Features
      - Feature A
      - Feature B

      ## Breaking Changes
      - Changed API endpoint structure
    draft: "true"
    pre-release: "true"
    assets-dir: "beta-builds"
```

### Release with Discussion

```yaml
- name: "Release with community discussion"
  uses: laerdal/github_actions/github-release@main
  with:
    tag: "v1.5.0"
    title: "Community Release v1.5.0"
    generate-notes: "true"
    discussion-category: "Announcements"
    assets: |
      binaries/*.tar.gz
      docs/user-guide.pdf
```

### Conditional Release Creation

```yaml
- name: "Create release on main branch"
  if: github.ref == 'refs/heads/main'
  uses: laerdal/github_actions/github-release@main
  with:
    tag: "nightly-${{ github.run_number }}"
    title: "Nightly Build ${{ github.run_number }}"
    notes: "Automated nightly build from main branch"
    pre-release: "true"
    latest: "false"
    fail-on-no-commits: "true"
    assets-dir: "nightly-builds"
```

### Cross-Repository Release

```yaml
- name: "Create release in different repository"
  uses: laerdal/github_actions/github-release@main
  with:
    repo: "myorg/releases-repo"
    tag: "app-v${{ env.VERSION }}"
    title: "Application Release v${{ env.VERSION }}"
    notes-file: "RELEASE_NOTES.md"
    assets: |
      dist/app-linux.tar.gz
      dist/app-windows.zip
      dist/app-macos.dmg
    github-token: ${{ secrets.RELEASES_TOKEN }}
```

### Release with Custom Notes from Tag

```yaml
- name: "Release from annotated tag"
  uses: laerdal/github_actions/github-release@main
  with:
    tag: ${{ github.ref_name }}
    notes-from-tag: "true"
    verify-tag: "true"
    assets: "dist/*"
```

## 📦 Asset Management

### Asset Upload Formats

The `assets` input supports multiple formats:

#### Newline-Separated Format

```yaml
assets: |
  dist/app.zip
  docs/user-guide.pdf
  build/artifacts/installer.exe
```

#### YAML List Format

```yaml
assets: |
  - dist/app.zip
  - docs/user-guide.pdf
  - "files with spaces.txt"
  - build/artifacts/installer.exe
```

#### Single Line Format

```yaml
assets: "dist/*.zip"
```

#### Assets with Display Labels

```yaml
assets: |
  dist/app-linux.tar.gz#Linux Application
  dist/app-windows.zip#Windows Application
  dist/app-macos.dmg#macOS Application
```

### Asset Features

- ✅ **Automatic Format Detection** - Detects YAML list vs. newline-separated automatically
- ✅ **Quoted File Support** - Handles files with spaces using quotes
- ✅ **File Validation** - Validates that all specified files exist before upload
- ✅ **Glob Pattern Support** - Use wildcards to match multiple files
- ✅ **Display Labels** - Add custom labels for better asset presentation

## 📝 Release Notes Options

### 1. Manual Notes

```yaml
notes: |
  ## What's Changed
  - Fixed critical bug in authentication
  - Added new API endpoints
  - Improved performance by 25%

  ## Breaking Changes
  - Removed deprecated `/old-api` endpoint
```

### 2. Notes from File

```yaml
notes-file: "CHANGELOG.md"
```

### 3. Auto-Generated Notes

```yaml
generate-notes: "true"
notes-start-tag: "v1.0.0"  # Optional: specify starting point
```

### 4. Notes from Tag Annotation

```yaml
notes-from-tag: "true"
verify-tag: "true"
```

## 🖥️ Requirements

### Prerequisites

- **GitHub CLI** - Pre-installed on GitHub Actions runners
- **GitHub Token** - For authentication (automatic via `github.token`)
- **Git Repository** - Valid Git repository with appropriate permissions

### Dependencies

- **GitHub CLI (gh)** - Automatically available on GitHub Actions runners
- **jq** - For JSON processing (pre-installed on runners)

### Supported Platforms

- ✅ Linux (ubuntu-latest)
- ✅ macOS (macos-latest)
- ✅ Windows (windows-latest)

## 🐛 Troubleshooting

### Common Issues

#### Authentication Failed

**Problem**: GitHub CLI authentication failed

**Solutions:**

1. Ensure `github-token` is properly set
2. Check token permissions include `contents: write`
3. Verify repository access rights

```yaml
permissions:
  contents: write  # Required for creating releases
  discussions: write  # Required if using discussion-category
```

#### Tag Already Exists

**Problem**: tag already exists

**Solutions:**

1. Use `verify-tag: true` to check existing tags
2. Choose a different tag name
3. Delete existing tag if appropriate

```yaml
- name: "Check existing tags"
  run: git tag --list | grep "v1.0.0" || echo "Tag not found"
```

#### No Assets Found

**Problem**: Asset files not found

**Solutions:**

1. Verify file paths are correct
2. Check build artifacts were created
3. Use absolute paths if relative paths fail

```yaml
- name: "List available files"
  run: find . -name "*.zip" -o -name "*.tar.gz" | head -10
```

#### Release Creation Failed

**Problem**: Release creation failed

**Solutions:**

1. Check repository permissions
2. Verify tag format is valid
3. Ensure required fields are provided

### Debug Mode

Enable debug output:

```yaml
- name: "Debug release creation"
  uses: laerdal/github_actions/github-release@main
  with:
    tag: "debug-v1.0.0"
    title: "Debug Release"
    notes: "Testing release creation"
    show-summary: "true"
  env:
    ACTIONS_STEP_DEBUG: true
```

### Manual Verification

Verify release creation:

```yaml
- name: "Verify release"
  run: |
    gh release view ${{ steps.release.outputs.release-tag }}
    gh release download ${{ steps.release.outputs.release-tag }} --dir ./downloads
```

## 🔧 Advanced Configuration

### Automatic Releases on Tag Push

```yaml
name: "Auto Release"

on:
  push:
    tags:
      - 'v[0-9]+.[0-9]+.[0-9]+'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: "Create release"
        uses: laerdal/github_actions/github-release@main
        with:
          tag: ${{ github.ref_name }}
          generate-notes: "true"
          assets-dir: "dist"
```

### Manual Release Workflow

```yaml
name: "Manual Release"

on:
  workflow_dispatch:
    inputs:
      version:
        description: "Release version"
        required: true
        default: "v1.0.0"
      pre-release:
        description: "Mark as pre-release"
        type: boolean
        default: false

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: "Create release"
        uses: laerdal/github_actions/github-release@main
        with:
          tag: ${{ github.event.inputs.version }}
          title: "Release ${{ github.event.inputs.version }}"
          generate-notes: "true"
          pre-release: ${{ github.event.inputs.pre-release }}
```

### Matrix Releases

```yaml
strategy:
  matrix:
    include:
      - os: ubuntu-latest
        asset: linux-x64
      - os: windows-latest
        asset: windows-x64
      - os: macos-latest
        asset: macos-x64

steps:
  - name: "Create platform release"
    uses: laerdal/github_actions/github-release@main
    with:
      tag: "v1.0.0"
      title: "Multi-platform Release"
      assets: "dist/app-${{ matrix.asset }}.*"
```

## 📄 License

This action is part of the GitHub Actions collection by Francois Raminosona.

---

> 💡 **Tip**: Use this action with our version generation and tagging actions for complete automated release workflows.
