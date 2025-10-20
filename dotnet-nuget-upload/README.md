# 📦 .NET NuGet Upload Action

A comprehensive GitHub Action for uploading NuGet packages to various feeds with support for symbols, custom sources, authentication, and advanced package management features.

## ✨ Features

- 📦 **Multiple Package Types** - Support for .nupkg and .snupkg packages
- 🔐 **Secure Authentication** - API key handling with automatic masking and secure storage
- 🔗 **Flexible Sources** - Support for NuGet.org, GitHub Packages, Azure DevOps, and custom feeds
- ⏱️ **Advanced Configuration** - Timeout control, retry handling, and skip duplicate options
- 🌍 **Internationalization** - Force English output for consistent parsing across locales
- 📊 **Rich Reporting** - Package information extraction and detailed action summaries
- ✅ **Comprehensive Validation** - Input validation, package verification, and error handling
- 🚀 **Performance Optimization** - Conditional uploads and efficient package processing

## 🚀 Basic Usage

Upload to NuGet.org:

```yaml
- name: "Upload to NuGet.org"
  uses: framinosona/github_actions/dotnet-nuget-upload@main
  with:
    package-path: "./artifacts/MyPackage.1.0.0.nupkg"
    api-key: ${{ secrets.NUGET_API_KEY }}
```

```yaml
- name: "Upload to GitHub Packages"
  uses: framinosona/github_actions/dotnet-nuget-upload@main
  with:
    package-path: "./artifacts/MyPackage.1.0.0.nupkg"
    source: "https://nuget.pkg.github.com/myorg/index.json"
    api-key: ${{ secrets.GITHUB_TOKEN }}
```

```yaml
- name: "Upload symbols package"
  uses: framinosona/github_actions/dotnet-nuget-upload@main
  with:
    package-path: "./artifacts/MyPackage.1.0.0.snupkg"
    symbol-source: "https://nuget.smbsrc.net/"
    symbol-api-key: ${{ secrets.SYMBOL_SERVER_API_KEY }}
```

## 🔧 Advanced Usage

Complete package upload with all configuration options:

```yaml
- name: "Advanced package upload"
  uses: framinosona/github_actions/dotnet-nuget-upload@main
  with:
    package-path: "./artifacts/MyPackage.1.0.0.nupkg"
    source: "https://api.nuget.org/v3/index.json"
    api-key: ${{ secrets.NUGET_API_KEY }}
    symbol-source: "https://nuget.smbsrc.net/"
    symbol-api-key: ${{ secrets.SYMBOL_SERVER_API_KEY }}
    timeout: "600"
    skip-duplicate: "true"
    no-symbols: "false"
    force-english-output: "true"
    working-directory: "./packages"
    verbosity: "detailed"
    show-summary: "true"
```

## 🔐 Permissions Required

This action requires standard repository permissions:

```yaml
permissions:
  contents: read    # Required to checkout repository code
  packages: read    # Required for GitHub Packages (if used)
```

For GitHub Packages publishing:

```yaml
permissions:
  contents: read
  packages: write   # Required to publish to GitHub Packages
```

## 🏗️ CI/CD Example

Complete workflow for building and publishing NuGet packages:

```yaml
name: "Build and Publish NuGet Package"

on:
  push:
    tags: ["v*"]
  release:
    types: [published]

permissions:
  contents: read
  packages: write

jobs:
  build-and-publish:
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
        run: dotnet restore

      - name: "🔨 Build solution"
        run: dotnet build --configuration Release --no-restore

      - name: "🧪 Run tests"
        uses: framinosona/github_actions/dotnet-test@main
        with:
          projects: "**/*Tests.csproj"
          configuration: "Release"
          no-build: "true"

      - name: "📦 Create packages"
        run: |
          dotnet pack --configuration Release --no-build --output ./artifacts \
            --include-symbols --include-source

      - name: "📤 Upload to NuGet.org"
        id: nuget-upload
        if: github.event_name == 'release'
        uses: framinosona/github_actions/dotnet-nuget-upload@main
        with:
          package-path: "./artifacts/*.nupkg"
          api-key: ${{ secrets.NUGET_API_KEY }}
          skip-duplicate: "true"
          timeout: "600"
          show-summary: "true"

      - name: "📤 Upload to GitHub Packages"
        if: github.event_name == 'push' && startsWith(github.ref, 'refs/tags/')
        uses: framinosona/github_actions/dotnet-nuget-upload@main
        with:
          package-path: "./artifacts/*.nupkg"
          source: "https://nuget.pkg.github.com/${{ github.repository_owner }}/index.json"
          api-key: ${{ secrets.GITHUB_TOKEN }}
          skip-duplicate: "true"

      - name: "📤 Upload symbols"
        if: steps.nuget-upload.outputs.exit-code == '0'
        uses: framinosona/github_actions/dotnet-nuget-upload@main
        with:
          package-path: "./artifacts/*.snupkg"
          symbol-source: "https://nuget.smbsrc.net/"
          symbol-api-key: ${{ secrets.SYMBOL_SERVER_API_KEY }}
          skip-duplicate: "true"

      - name: "🏷️ Generate success badge"
        if: success()
        uses: framinosona/github_actions/generate-badge@main
        with:
          label: "nuget"
          message: "${{ steps.nuget-upload.outputs.package-version }}"
          color: "blue"
          style: "flat-square"
          logo: "nuget"

      - name: "📊 Upload artifacts"
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: "nuget-packages"
          path: "./artifacts/"
          retention-days: 30
```

## 📋 Inputs

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `package-path` | Path to NuGet package (.nupkg/.snupkg) | ✅ Yes | - | `./artifacts/MyPackage.1.0.0.nupkg` |
| `source` | NuGet server URL or source name | ❌ No | `''` | `https://api.nuget.org/v3/index.json` |
| `api-key` | API key for the NuGet server | ❌ No | `''` | `${{ secrets.NUGET_API_KEY }}` |
| `symbol-source` | Symbol server URL | ❌ No | `''` | `https://nuget.smbsrc.net/` |
| `symbol-api-key` | API key for symbol server | ❌ No | `''` | `${{ secrets.SYMBOL_SERVER_API_KEY }}` |
| `timeout` | Timeout in seconds | ❌ No | `300` | `600`, `1200` |
| `skip-duplicate` | Skip duplicate packages | ❌ No | `false` | `true`, `false` |
| `no-symbols` | Do not push symbols | ❌ No | `false` | `true`, `false` |
| `force-english-output` | Force English output | ❌ No | `true` | `true`, `false` |
| `working-directory` | Working directory | ❌ No | `.` | `./packages`, `./artifacts` |
| `verbosity` | Verbosity level | ❌ No | `''` | `quiet`, `minimal`, `normal`, `detailed`, `diagnostic` |
| `show-summary` | Show action summary | ❌ No | `true` | `true`, `false` |

## 📤 Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `exit-code` | Exit code of the push command | `0`, `1` |
| `executed-command` | Command that was executed (masked) | `dotnet nuget push MyPackage.1.0.0.nupkg --source ...` |
| `package-name` | Name of uploaded package | `MyCompany.MyPackage` |
| `package-version` | Version of uploaded package | `1.0.0`, `2.1.0-preview.1` |

## 🔗 Related Actions

| Action | Purpose | Repository |
|--------|---------|------------|
| 🔧 **dotnet-nuget-feed-setup** | Configure NuGet sources | `framinosona/github_actions/dotnet-nuget-feed-setup` |
| 🔨 **dotnet** | Build .NET projects | `framinosona/github_actions/dotnet` |
| 🧪 **dotnet-test** | Run .NET tests | `framinosona/github_actions/dotnet-test` |
| 🔢 **generate-version** | Generate version numbers | `framinosona/github_actions/generate-version` |

## 💡 Examples

### Multi-Feed Publishing Strategy

```yaml
strategy:
  matrix:
    feed:
      - name: "NuGet.org"
        source: "https://api.nuget.org/v3/index.json"
        api-key: "NUGET_API_KEY"
        condition: "github.event_name == 'release'"
      - name: "GitHub Packages"
        source: "https://nuget.pkg.github.com/myorg/index.json"
        api-key: "GITHUB_TOKEN"
        condition: "always()"
      - name: "Azure DevOps"
        source: "https://pkgs.dev.azure.com/myorg/_packaging/MyFeed/nuget/v3/index.json"
        api-key: "AZURE_DEVOPS_PAT"
        condition: "github.ref == 'refs/heads/main'"

steps:
  - name: "Upload to ${{ matrix.feed.name }}"
    if: ${{ matrix.feed.condition }}
    uses: framinosona/github_actions/dotnet-nuget-upload@main
    with:
      package-path: "./artifacts/*.nupkg"
      source: ${{ matrix.feed.source }}
      api-key: ${{ secrets[matrix.feed.api-key] }}
      skip-duplicate: "true"
      timeout: "600"
```

### Environment-Based Publishing

```yaml
# Production releases
- name: "Upload to production feed"
  if: github.event_name == 'release' && !github.event.release.prerelease
  uses: framinosona/github_actions/dotnet-nuget-upload@main
  with:
    package-path: "./artifacts/*.nupkg"
    source: "https://api.nuget.org/v3/index.json"
    api-key: ${{ secrets.NUGET_API_KEY }}
    timeout: "600"

# Pre-release packages
- name: "Upload to preview feed"
  if: github.event_name == 'release' && github.event.release.prerelease
  uses: framinosona/github_actions/dotnet-nuget-upload@main
  with:
    package-path: "./artifacts/*.nupkg"
    source: "https://preview.nuget.org/v3/index.json"
    api-key: ${{ secrets.NUGET_PREVIEW_API_KEY }}
    timeout: "600"

# Development builds
- name: "Upload to development feed"
  if: github.ref == 'refs/heads/develop'
  uses: framinosona/github_actions/dotnet-nuget-upload@main
  with:
    package-path: "./artifacts/*.nupkg"
    source: "https://dev-nuget.company.com/v3/index.json"
    api-key: ${{ secrets.DEV_NUGET_API_KEY }}
    skip-duplicate: "true"
```

### Batch Package Upload

```yaml
- name: "Find all packages"
  id: packages
  run: |
    packages=$(find ./artifacts -name "*.nupkg" -type f | tr '\n' ' ')
    echo "packages=$packages" >> $GITHUB_OUTPUT

- name: "Upload packages individually"
  if: steps.packages.outputs.packages != ''
  run: |
    for package in ${{ steps.packages.outputs.packages }}; do
      echo "Uploading $package"
    done

- name: "Upload main packages"
  uses: framinosona/github_actions/dotnet-nuget-upload@main
  with:
    package-path: "./artifacts/*.nupkg"
    api-key: ${{ secrets.NUGET_API_KEY }}
    skip-duplicate: "true"
    no-symbols: "true"
    show-summary: "true"

- name: "Upload symbol packages"
  uses: framinosona/github_actions/dotnet-nuget-upload@main
  with:
    package-path: "./artifacts/*.snupkg"
    symbol-source: "https://nuget.smbsrc.net/"
    symbol-api-key: ${{ secrets.SYMBOL_SERVER_API_KEY }}
    skip-duplicate: "true"
```

### Conditional Upload with Validation

```yaml
- name: "Validate package before upload"
  run: |
    # Check if package exists
    if [ ! -f "./artifacts/MyPackage.*.nupkg" ]; then
      echo "❌ Package not found"
      exit 1
    fi

    # Validate package contents
    dotnet nuget verify ./artifacts/*.nupkg

    # Check package size
    size=$(stat -f%z ./artifacts/*.nupkg)
    if [ $size -gt 104857600 ]; then  # 100MB
      echo "⚠️ Package is very large: ${size} bytes"
    fi

- name: "Upload with conditions"
  id: upload
  uses: framinosona/github_actions/dotnet-nuget-upload@main
  with:
    package-path: "./artifacts/*.nupkg"
    api-key: ${{ secrets.NUGET_API_KEY }}
    skip-duplicate: "true"
    timeout: "900"
    verbosity: "normal"
    show-summary: "true"

- name: "Verify upload success"
  if: steps.upload.outputs.exit-code == '0'
  run: |
    echo "✅ Package uploaded successfully"
    echo "Package: ${{ steps.upload.outputs.package-name }}"
    echo "Version: ${{ steps.upload.outputs.package-version }}"
```

## 🔗 Common NuGet Sources

| Provider | URL Template | Authentication |
|----------|--------------|----------------|
| **NuGet.org** | `https://api.nuget.org/v3/index.json` | API Key |
| **GitHub Packages** | `https://nuget.pkg.github.com/OWNER/index.json` | GitHub Token |
| **Azure DevOps** | `https://pkgs.dev.azure.com/ORG/_packaging/FEED/nuget/v3/index.json` | PAT |
| **MyGet** | `https://www.myget.org/F/FEED/api/v3/index.json` | API Key |
| **Artifactory** | `https://COMPANY.jfrog.io/artifactory/api/nuget/REPO` | API Key |
| **Nexus** | `https://nexus.company.com/repository/nuget-hosted/` | Username/Password |

## 🔐 Security Best Practices

### API Key Management

```yaml
# ✅ Best Practices
secrets:
  NUGET_API_KEY: "oy2..."              # Production NuGet.org
  NUGET_PREVIEW_API_KEY: "oy3..."      # Preview feed
  GITHUB_TOKEN: "${{ secrets.GITHUB_TOKEN }}" # GitHub Packages
  AZURE_DEVOPS_PAT: "Basic base64..."  # Azure DevOps

# ❌ Avoid
api-key: "oy2lki5j3k4l6j7k8l9m0n1p2q3r4s5t"  # Hardcoded
```

### Package Security

```yaml
# Sign packages (recommended)
- name: "Sign package"
  run: |
    dotnet nuget sign ./artifacts/*.nupkg \
      --certificate-path ${{ secrets.CERTIFICATE_PATH }} \
      --certificate-password ${{ secrets.CERTIFICATE_PASSWORD }}

# Verify package integrity
- name: "Verify package"
  run: |
    dotnet nuget verify ./artifacts/*.nupkg \
      --certificate-fingerprint ${{ secrets.CERTIFICATE_FINGERPRINT }}
```

## 🖥️ Requirements

- .NET SDK 6.0 or later installed on the runner
- Valid NuGet package files (.nupkg or .snupkg)
- Internet access to target NuGet feeds
- Appropriate API keys with push permissions
- PowerShell Core (Windows) or Bash (Unix) shell

## 🐛 Troubleshooting

### Common Issues

#### Package Already Exists (409 Conflict)

**Problem**: Upload fails with "Response status code does not indicate success: 409 (Conflict)"

**Solution**: Use skip-duplicate or increment version:

```yaml
- name: "Upload with duplicate handling"
  uses: framinosona/github_actions/dotnet-nuget-upload@main
  with:
    package-path: "./artifacts/MyPackage.1.0.0.nupkg"
    api-key: ${{ secrets.NUGET_API_KEY }}
    skip-duplicate: "true"  # Skip if already exists
    show-summary: "true"
```

#### Authentication Failed (401 Unauthorized)

**Problem**: "Response status code does not indicate success: 401 (Unauthorized)"

**Solution**: Verify API key and permissions:

```yaml
- name: "Debug authentication"
  run: |
    echo "Checking API key format..."
    if [[ "${{ secrets.NUGET_API_KEY }}" =~ ^oy2[a-z0-9]{43}$ ]]; then
      echo "✅ API key format looks correct"
    else
      echo "❌ API key format may be incorrect"
    fi

- name: "Test with verbose output"
  uses: framinosona/github_actions/dotnet-nuget-upload@main
  with:
    package-path: "./artifacts/MyPackage.1.0.0.nupkg"
    api-key: ${{ secrets.NUGET_API_KEY }}
    verbosity: "detailed"
    show-summary: "true"
```

#### Network Timeout

**Problem**: "The operation was canceled" or timeout errors

**Solution**: Increase timeout and check connectivity:

```yaml
- name: "Upload with extended timeout"
  uses: framinosona/github_actions/dotnet-nuget-upload@main
  with:
    package-path: "./artifacts/MyPackage.1.0.0.nupkg"
    api-key: ${{ secrets.NUGET_API_KEY }}
    timeout: "1200"  # 20 minutes
    verbosity: "normal"
```

#### Package Validation Failed

**Problem**: Server-side package validation errors

**Solution**: Validate package locally first:

```yaml
- name: "Pre-upload validation"
  run: |
    # Check package metadata
    dotnet nuget list source

    # Validate package structure
    unzip -l "./artifacts/MyPackage.1.0.0.nupkg" | head -20

    # Check for required metadata
    dotnet nuget verify "./artifacts/MyPackage.1.0.0.nupkg" || echo "Package verification failed"

- name: "Upload validated package"
  uses: framinosona/github_actions/dotnet-nuget-upload@main
  with:
    package-path: "./artifacts/MyPackage.1.0.0.nupkg"
    api-key: ${{ secrets.NUGET_API_KEY }}
    verbosity: "detailed"
    show-summary: "true"
```

### Debug Mode

Enable comprehensive debugging:

```yaml
- name: "Debug package upload"
  uses: framinosona/github_actions/dotnet-nuget-upload@main
  with:
    package-path: "./artifacts/MyPackage.1.0.0.nupkg"
    api-key: ${{ secrets.NUGET_API_KEY }}
    verbosity: "diagnostic"
    show-summary: "true"
  env:
    ACTIONS_STEP_DEBUG: true
    DOTNET_CLI_TELEMETRY_OPTOUT: true
```

### Package Analysis

```yaml
- name: "Analyze package before upload"
  run: |
    echo "=== Package Analysis ==="
    for pkg in ./artifacts/*.nupkg; do
      echo "📦 Package: $(basename $pkg)"
      echo "📊 Size: $(stat -f%z $pkg 2>/dev/null || stat -c%s $pkg) bytes"
      echo "📋 Contents:"
      unzip -l "$pkg" | grep -E '\.(dll|exe|xml|json)$' | head -10
      echo "---"
    done
```

## 🔧 Advanced Features

### Package Metadata Extraction

```yaml
- name: "Extract package information"
  id: package-info
  run: |
    # Extract package ID and version from .nupkg filename
    for pkg in ./artifacts/*.nupkg; do
      filename=$(basename "$pkg" .nupkg)
      # Assuming format: PackageId.Version.nupkg
      version=$(echo "$filename" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+.*$')
      package_id=$(echo "$filename" | sed "s/\.$version//")
      echo "package-id=$package_id" >> $GITHUB_OUTPUT
      echo "version=$version" >> $GITHUB_OUTPUT
      break
    done

- name: "Upload with extracted metadata"
  uses: framinosona/github_actions/dotnet-nuget-upload@main
  with:
    package-path: "./artifacts/${{ steps.package-info.outputs.package-id }}.${{ steps.package-info.outputs.version }}.nupkg"
    api-key: ${{ secrets.NUGET_API_KEY }}
    skip-duplicate: "true"
```

### Retry Logic

```yaml
- name: "Upload with retry"
  uses: nick-fields/retry@v2
  with:
    timeout_minutes: 10
    max_attempts: 3
    retry_wait_seconds: 30
    command: |
      # Use the action with retries
      ${{ github.action_path }}/dotnet-nuget-upload \
        --package-path "./artifacts/*.nupkg" \
        --api-key "${{ secrets.NUGET_API_KEY }}" \
        --timeout 600 \
        --skip-duplicate true
```

### Conditional Symbol Upload

```yaml
- name: "Check for symbols"
  id: symbols
  run: |
    if ls ./artifacts/*.snupkg 1> /dev/null 2>&1; then
      echo "symbols-exist=true" >> $GITHUB_OUTPUT
    else
      echo "symbols-exist=false" >> $GITHUB_OUTPUT
    fi

- name: "Upload symbols if available"
  if: steps.symbols.outputs.symbols-exist == 'true'
  uses: framinosona/github_actions/dotnet-nuget-upload@main
  with:
    package-path: "./artifacts/*.snupkg"
    symbol-source: "https://nuget.smbsrc.net/"
    symbol-api-key: ${{ secrets.SYMBOL_SERVER_API_KEY }}
    skip-duplicate: "true"
```

## 📄 License

This action is part of the GitHub Actions collection by Francois Raminosona.

---

> 💡 **Tip**: Always test package uploads to a staging feed before publishing to production, and use semantic versioning for consistent package management.
