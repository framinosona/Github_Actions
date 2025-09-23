# 🚀 GitHub Release Action

Create GitHub releases with assets using the GitHub CLI (`gh release create`).

## Features

- 🚀 **Complete Release Management** - Create releases with full GitHub CLI feature support
- 📦 **Asset Upload Support** - Upload files, directories, or glob patterns as release assets
- 📝 **Flexible Release Notes** - Multiple options for release notes (manual, file, auto-generated, from tags)
- 🎯 **Advanced Targeting** - Target specific branches, commits, or repositories
- 🔧 **Draft & Prerelease Support** - Create drafts or mark releases as prereleases
- 💬 **Discussion Integration** - Start discussions with releases
- 📊 **Comprehensive Outputs** - Detailed release information for downstream actions

## Usage

### Basic Usage

Create a simple release with a tag:

```yaml
- name: Create Release
  uses: ./github-release
  with:
    tag: 'v1.0.0'
    title: 'Version 1.0.0'
    notes: 'Initial release with basic functionality'
```

### Advanced Usage with Assets

```yaml
- name: Create Release with Assets
  uses: ./github-release
  with:
    tag: 'v1.2.3'
    title: 'Version 1.2.3 - Bug Fixes'
    generate-notes: 'true'
    assets: |
      dist/app-linux-x64.tar.gz
      dist/app-windows-x64.zip
      dist/app-macos-x64.dmg
    prerelease: 'false'
    latest: 'true'
```

### Auto-Generated Release

```yaml
- name: Auto-Generated Release
  uses: ./github-release
  with:
    tag: ${{ github.ref_name }}
    generate-notes: 'true'
    assets-dir: 'build/artifacts'
```

## Inputs

### Required Inputs

None. All inputs are optional with sensible defaults.

### Optional Inputs

| Input | Description | Default | Example |
|-------|-------------|---------|---------|
| `tag` | Git tag for the release | `''` | `v1.0.0` |
| `title` | Release title | `''` | `Version 1.0.0` |
| `notes` | Release notes content | `''` | `Bug fixes and improvements` |
| `notes-file` | Path to file containing release notes | `''` | `CHANGELOG.md` |
| `notes-from-tag` | Use tag annotation as release notes | `false` | `true` |
| `notes-start-tag` | Starting tag for generating notes | `''` | `v1.0.0` |
| `generate-notes` | Auto-generate notes via GitHub API | `false` | `true` |
| `draft` | Save as draft instead of publishing | `false` | `true` |
| `prerelease` | Mark as prerelease | `false` | `true` |
| `latest` | Mark as latest release | `auto` | `true`/`false`/`auto` |
| `target` | Target branch or commit SHA | `''` | `main` |
| `verify-tag` | Abort if tag doesn't exist remotely | `false` | `true` |
| `discussion-category` | Start discussion in category | `''` | `General` |
| `fail-on-no-commits` | Fail if no new commits since last release | `false` | `true` |
| `assets` | Assets to upload (newline-separated) | `''` | `dist/*.zip` |
| `assets-dir` | Directory containing assets | `''` | `build/dist` |
| `repo` | Target repository (OWNER/REPO) | `''` | `myorg/myrepo` |
| `github-token` | GitHub token for authentication | `${{ github.token }}` | `${{ secrets.GITHUB_TOKEN }}` |
| `show-summary` | Show action summary | `true` | `false` |

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `release-id` | ID of the created release | `12345678` |
| `release-url` | URL of the created release | `https://github.com/owner/repo/releases/tag/v1.0.0` |
| `release-tag` | Tag of the created release | `v1.0.0` |
| `release-name` | Name/title of the created release | `Version 1.0.0` |
| `assets-uploaded` | Number of assets uploaded | `3` |
| `upload-url` | Upload URL for the release | `https://uploads.github.com/repos/...` |

## Examples

### Complete CI/CD Release Pipeline

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Build Application
      run: |
        # Your build commands here
        mkdir -p dist
        echo "Built app" > dist/app.txt
        tar -czf dist/app-linux-x64.tar.gz dist/app.txt

    - name: Create Release
      id: release
      uses: ./github-release
      with:
        tag: ${{ github.ref_name }}
        title: 'Release ${{ github.ref_name }}'
        generate-notes: 'true'
        assets: |
          dist/app-linux-x64.tar.gz
          dist/*.zip
        latest: 'true'

    - name: Report Release
      run: |
        echo "Created release: ${{ steps.release.outputs.release-url }}"
        echo "Uploaded ${{ steps.release.outputs.assets-uploaded }} assets"
```

### Draft Release for Testing

```yaml
- name: Create Draft Release
  uses: ./github-release
  with:
    tag: 'v2.0.0-beta.1'
    title: 'Beta Release 2.0.0'
    notes: |
      🚧 **This is a beta release for testing purposes**

      ## New Features
      - Feature A
      - Feature B

      ## Breaking Changes
      - Changed API endpoint structure
    draft: 'true'
    prerelease: 'true'
    assets-dir: 'beta-builds'
```

### Release with Discussion

```yaml
- name: Release with Community Discussion
  uses: ./github-release
  with:
    tag: 'v1.5.0'
    title: 'Community Release v1.5.0'
    generate-notes: 'true'
    discussion-category: 'Announcements'
    assets: |
      binaries/*.tar.gz
      docs/user-guide.pdf
```

### Conditional Release Creation

```yaml
- name: Create Release on Main Branch
  if: github.ref == 'refs/heads/main'
  uses: ./github-release
  with:
    tag: 'nightly-${{ github.run_number }}'
    title: 'Nightly Build ${{ github.run_number }}'
    notes: 'Automated nightly build from main branch'
    prerelease: 'true'
    latest: 'false'
    fail-on-no-commits: 'true'
    assets-dir: 'nightly-builds'
```

### Cross-Repository Release

```yaml
- name: Create Release in Different Repository
  uses: ./github-release
  with:
    repo: 'myorg/releases-repo'
    tag: 'app-v${{ env.VERSION }}'
    title: 'Application Release v${{ env.VERSION }}'
    notes-file: 'RELEASE_NOTES.md'
    assets: |
      dist/app-linux.tar.gz
      dist/app-windows.zip
      dist/app-macos.dmg
    github-token: ${{ secrets.RELEASES_TOKEN }}
```

### Release with Custom Notes from Tag

```yaml
- name: Release from Annotated Tag
  uses: ./github-release
  with:
    tag: ${{ github.ref_name }}
    notes-from-tag: 'true'
    verify-tag: 'true'  # Ensure tag exists before creating release
    assets: 'dist/*'
```

### Versioned Asset Upload

```yaml
- name: Create Release with Versioned Assets
  uses: ./github-release
  with:
    tag: 'v${{ env.VERSION }}'
    title: 'Release v${{ env.VERSION }}'
    generate-notes: 'true'
    assets: |
      dist/myapp-v${{ env.VERSION }}-linux.tar.gz#Linux Binary
      dist/myapp-v${{ env.VERSION }}-windows.zip#Windows Binary
      dist/myapp-v${{ env.VERSION }}-macos.dmg#macOS Application
```

## Requirements

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

## Asset Management

### Asset Upload Options

1. **Individual Files:**
   ```yaml
   assets: |
     dist/app.tar.gz
     docs/manual.pdf
     config/settings.json
   ```

2. **Glob Patterns:**
   ```yaml
   assets: |
     dist/*.tar.gz
     binaries/**/*.exe
     docs/*.pdf
   ```

3. **Directory Upload:**
   ```yaml
   assets-dir: 'release-artifacts'
   ```

4. **Assets with Display Labels:**
   ```yaml
   assets: |
     dist/app-linux.tar.gz#Linux Application
     dist/app-windows.zip#Windows Application
   ```

### Asset Naming Best Practices

- Use descriptive filenames with version numbers
- Include platform/architecture in names
- Use consistent naming conventions
- Consider file size limitations (2GB per file)

## Release Notes Options

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
notes-file: 'CHANGELOG.md'
```

### 3. Auto-Generated Notes

```yaml
generate-notes: 'true'
notes-start-tag: 'v1.0.0'  # Optional: specify starting point
```

### 4. Notes from Tag Annotation

```yaml
notes-from-tag: 'true'
verify-tag: 'true'
```

## Troubleshooting

### Common Issues

#### ❌ Authentication Failed

```
Error: GitHub CLI authentication failed
```

**Solutions:**
1. Ensure `github-token` is properly set
2. Check token permissions include `contents: write`
3. Verify repository access rights

#### ❌ Tag Already Exists

```
Error: tag already exists
```

**Solutions:**
1. Use `verify-tag: true` to check existing tags
2. Choose a different tag name
3. Delete existing tag if appropriate

#### ❌ No Assets Found

```
Warning: Asset not found
```

**Solutions:**
1. Verify file paths are correct
2. Check build artifacts were created
3. Use absolute paths if relative paths fail

#### ❌ Release Creation Failed

```
Error: Release creation failed
```

**Solutions:**
1. Check repository permissions
2. Verify tag format is valid
3. Ensure required fields are provided

### Debug Mode

Enable debug output:

```yaml
- name: Debug Release Creation
  uses: ./github-release
  with:
    tag: 'debug-v1.0.0'
    title: 'Debug Release'
    notes: 'Testing release creation'
  env:
    ACTIONS_STEP_DEBUG: true
```

### Manual Verification

Verify release creation:

```yaml
- name: Verify Release
  run: |
    gh release view ${{ steps.release.outputs.release-tag }}
    gh release download ${{ steps.release.outputs.release-tag }} --dir ./downloads
```

## Advanced Configuration

### Release Workflows

#### Automatic Releases on Tag Push

```yaml
name: Auto Release

on:
  push:
    tags:
      - 'v[0-9]+.[0-9]+.[0-9]+'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Create Release
      uses: ./github-release
      with:
        tag: ${{ github.ref_name }}
        generate-notes: 'true'
        assets-dir: 'dist'
```

#### Manual Release Workflow

```yaml
name: Manual Release

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Release version'
        required: true
        default: 'v1.0.0'
      prerelease:
        description: 'Mark as prerelease'
        type: boolean
        default: false

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Create Release
      uses: ./github-release
      with:
        tag: ${{ github.event.inputs.version }}
        title: 'Release ${{ github.event.inputs.version }}'
        generate-notes: 'true'
        prerelease: ${{ github.event.inputs.prerelease }}
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
- name: Create Release Asset
  uses: ./github-release
  with:
    tag: 'v1.0.0'
    title: 'Multi-platform Release'
    assets: 'dist/app-${{ matrix.asset }}.*'
```

## Security Considerations

### Token Permissions

Ensure your GitHub token has appropriate permissions:

```yaml
permissions:
  contents: write  # Required for creating releases
  discussions: write  # Required if using discussion-category
```

### Sensitive Assets

For private repositories or sensitive assets:

```yaml
- name: Secure Release
  uses: ./github-release
  with:
    tag: 'private-v1.0.0'
    title: 'Private Release'
    notes: 'Internal release - do not distribute'
    assets-dir: 'secure-build'
    github-token: ${{ secrets.PRIVATE_RELEASE_TOKEN }}
```

## Contributing

When contributing to this action:

1. Follow the [Actions Guidelines](../.github/copilot-instructions.md)
2. Test with various release configurations
3. Ensure cross-platform compatibility
4. Update documentation for new features
5. Test with different asset types and sizes

## License

This action is distributed under the same license as the repository.

## Support

For issues related to:
- **GitHub CLI:** Check [GitHub CLI Documentation](https://cli.github.com/manual/)
- **GitHub Releases:** Check [GitHub Releases Documentation](https://docs.github.com/en/repositories/releasing-projects-on-github)
- **Action bugs:** Create an issue in this repository
- **GitHub Actions:** Check [GitHub Actions Documentation](https://docs.github.com/en/actions)
