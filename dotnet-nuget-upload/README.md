# 📦 Upload NuGet Package Action

Uploads a NuGet package to a specified feed using `dotnet nuget push` with comprehensive validation and security features.

## Features

- 📦 Upload .nupkg and .snupkg packages
- 🔐 Secure API key handling with masking
- 🔗 Support for custom NuGet sources and symbol servers
- ⏱️ Configurable timeout and retry handling
- 🚫 Skip duplicate package uploads
- 🌍 Force English output for consistent parsing
- 📊 Package information extraction and reporting
- ✅ Comprehensive input validation

## Usage

### Basic Usage - Upload to NuGet.org
```yaml
- name: Upload to NuGet.org
  uses: ./dotnet-nuget-upload
  with:
    package-path: './artifacts/MyPackage.1.0.0.nupkg'
    api-key: ${{ secrets.NUGET_API_KEY }}
```

### Upload to Custom Feed
```yaml
- name: Upload to private feed
  uses: ./dotnet-nuget-upload
  with:
    package-path: './artifacts/MyPackage.1.0.0.nupkg'
    source: 'https://my-nuget-feed.company.com/v3/index.json'
    api-key: ${{ secrets.PRIVATE_FEED_API_KEY }}
```

### Advanced Usage - With Symbols and Custom Options
```yaml
- name: Upload package with symbols
  uses: ./dotnet-nuget-upload
  with:
    package-path: './artifacts/MyPackage.1.0.0.nupkg'
    source: 'https://api.nuget.org/v3/index.json'
    api-key: ${{ secrets.NUGET_API_KEY }}
    symbol-source: 'https://nuget.smbsrc.net/'
    symbol-api-key: ${{ secrets.SYMBOL_SERVER_API_KEY }}
    timeout: '600'
    skip-duplicate: 'true'
    verbosity: 'detailed'
```

### Upload Symbols Package
```yaml
- name: Upload symbols package
  uses: ./dotnet-nuget-upload
  with:
    package-path: './artifacts/MyPackage.1.0.0.snupkg'
    source: 'https://nuget.smbsrc.net/'
    api-key: ${{ secrets.SYMBOL_SERVER_API_KEY }}
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `package-path` | Path to the NuGet package file (.nupkg or .snupkg) to upload | ✅ Yes | |
| `source` | NuGet server URL or source name to push to | ❌ No | `""` |
| `api-key` | API key for the NuGet server (use secrets for security) | ❌ No | `""` |
| `symbol-source` | Symbol server URL to push symbols to | ❌ No | `""` |
| `symbol-api-key` | API key for the symbol server (use secrets for security) | ❌ No | `""` |
| `timeout` | Timeout for the push operation in seconds | ❌ No | `"300"` |
| `skip-duplicate` | Skip duplicate packages (true/false) | ❌ No | `"false"` |
| `no-symbols` | Do not push symbols (true/false) | ❌ No | `"false"` |
| `force-english-output` | Force English output for consistent parsing | ❌ No | `"true"` |
| `working-directory` | Working directory for the push operation | ❌ No | `"."` |
| `verbosity` | Verbosity level (quiet, minimal, normal, detailed, diagnostic) | ❌ No | `""` |
| `show-summary` | Whether to show the action summary | ❌ No | `"true"` |

## Outputs

| Output | Description |
|--------|-------------|
| `exit-code` | Exit code of the nuget push command |
| `executed-command` | The actual command that was executed |
| `package-name` | Name of the package that was uploaded |
| `package-version` | Version of the package that was uploaded |

## Examples

### Example 1: Complete CI/CD Pipeline with Package Upload
```yaml
name: Build and Publish NuGet Package
on:
  push:
    tags: ['v*']

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Restore dependencies
        run: dotnet restore

      - name: Build
        run: dotnet build --configuration Release --no-restore

      - name: Pack
        run: dotnet pack --configuration Release --no-build --output ./artifacts

      - name: Upload to NuGet.org
        uses: ./dotnet-nuget-upload
        with:
          package-path: './artifacts/*.nupkg'
          api-key: ${{ secrets.NUGET_API_KEY }}
          skip-duplicate: 'true'
```

### Example 2: Multi-Target Package Upload
```yaml
name: Publish to Multiple Feeds
on:
  release:
    types: [published]

jobs:
  publish:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        feed:
          - name: 'NuGet.org'
            source: 'https://api.nuget.org/v3/index.json'
            api-key: 'NUGET_API_KEY'
          - name: 'GitHub Packages'
            source: 'https://nuget.pkg.github.com/myorg/index.json'
            api-key: 'GITHUB_TOKEN'
          - name: 'Private Feed'
            source: 'https://my-feed.company.com/v3/index.json'
            api-key: 'PRIVATE_FEED_KEY'

    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Build and Pack
        run: |
          dotnet restore
          dotnet build --configuration Release --no-restore
          dotnet pack --configuration Release --no-build --output ./artifacts

      - name: Upload to ${{ matrix.feed.name }}
        uses: ./dotnet-nuget-upload
        with:
          package-path: './artifacts/*.nupkg'
          source: ${{ matrix.feed.source }}
          api-key: ${{ secrets[matrix.feed.api-key] }}
          skip-duplicate: 'true'
          timeout: '600'
```

### Example 3: Conditional Upload Based on Branch
```yaml
name: Conditional Package Upload
on: [push, pull_request]

jobs:
  build-and-publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Build and Pack
        run: |
          dotnet restore
          dotnet build --configuration Release
          dotnet pack --configuration Release --output ./artifacts

      - name: Upload to NuGet.org (Release)
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        uses: ./dotnet-nuget-upload
        with:
          package-path: './artifacts/*.nupkg'
          api-key: ${{ secrets.NUGET_API_KEY }}
          skip-duplicate: 'true'

      - name: Upload to Pre-release Feed (Development)
        if: github.ref == 'refs/heads/develop' && github.event_name == 'push'
        uses: ./dotnet-nuget-upload
        with:
          package-path: './artifacts/*.nupkg'
          source: 'https://prerelease-feed.company.com/v3/index.json'
          api-key: ${{ secrets.PRERELEASE_FEED_API_KEY }}
          skip-duplicate: 'true'
```

### Example 4: Upload with Symbol Packages
```yaml
name: Publish with Debug Symbols
on:
  release:
    types: [published]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Build with symbols
        run: |
          dotnet restore
          dotnet build --configuration Release
          dotnet pack --configuration Release --include-symbols --include-source --output ./artifacts

      - name: Upload main package
        uses: ./dotnet-nuget-upload
        with:
          package-path: './artifacts/*.nupkg'
          api-key: ${{ secrets.NUGET_API_KEY }}
          no-symbols: 'true'
          skip-duplicate: 'true'

      - name: Upload symbols package
        uses: ./dotnet-nuget-upload
        with:
          package-path: './artifacts/*.snupkg'
          symbol-source: 'https://nuget.smbsrc.net/'
          symbol-api-key: ${{ secrets.SYMBOL_SERVER_API_KEY }}
          skip-duplicate: 'true'
```

## Requirements

- ✅ .NET SDK must be installed (use `actions/setup-dotnet`)
- ✅ Valid NuGet package file (.nupkg or .snupkg)
- ✅ Appropriate API keys stored in secrets
- ✅ Network access to target NuGet feeds

## Security Best Practices

### 🔐 API Key Management
- **Never hardcode API keys** in workflow files
- **Use GitHub Secrets** to store sensitive information
- **Use different API keys** for different environments
- **Rotate API keys regularly** for security

```yaml
# ✅ Good - Using secrets
api-key: ${{ secrets.NUGET_API_KEY }}

# ❌ Bad - Hardcoded key
api-key: 'oy2lki5j3k4l6j7k8l9m0n1p2q3r4s5t'
```

### 🔍 Package Validation
- **Verify package contents** before upload
- **Use signed packages** when possible
- **Validate package metadata** and dependencies
- **Test packages** in staging environments first

## Common NuGet Sources

| Source | URL | Description |
|--------|-----|-------------|
| **NuGet.org** | `https://api.nuget.org/v3/index.json` | Official public NuGet repository |
| **GitHub Packages** | `https://nuget.pkg.github.com/OWNER/index.json` | GitHub's package registry |
| **Azure DevOps** | `https://pkgs.dev.azure.com/ORGANIZATION/_packaging/FEED/nuget/v3/index.json` | Azure DevOps artifact feeds |
| **MyGet** | `https://www.myget.org/F/FEED/api/v3/index.json` | MyGet hosted feeds |

## Error Handling

The action includes comprehensive error handling for common scenarios:

### 🔍 **Validation Errors**
- Missing or invalid package files
- Invalid package extensions
- Missing required parameters
- Invalid timeout values

### 📦 **Upload Errors**
- Network connectivity issues
- Authentication failures
- Duplicate package uploads (when not skipped)
- Server-side validation failures

### 🚨 **Common Issues**

1. **Package Already Exists**
   ```
   Response status code does not indicate success: 409 (Conflict).
   ```
   - **Solution**: Use `skip-duplicate: 'true'` or increment package version

2. **Authentication Failed**
   ```
   Response status code does not indicate success: 401 (Unauthorized).
   ```
   - **Solution**: Verify API key is correct and has push permissions

3. **Network Timeout**
   ```
   The operation was canceled.
   ```
   - **Solution**: Increase `timeout` value or check network connectivity

4. **Invalid Package**
   ```
   Package validation failed.
   ```
   - **Solution**: Verify package is properly built and contains valid metadata

## Troubleshooting

### Debug Mode

Enable detailed logging by setting verbosity:

```yaml
- name: Upload with debug output
  uses: ./dotnet-nuget-upload
  with:
    package-path: './artifacts/MyPackage.1.0.0.nupkg'
    api-key: ${{ secrets.NUGET_API_KEY }}
    verbosity: 'detailed'
```

Or enable GitHub Actions debug logging:

```yaml
env:
  ACTIONS_STEP_DEBUG: true
```

### Testing Package Upload

Test package upload to a staging feed first:

```yaml
- name: Test upload to staging
  uses: ./dotnet-nuget-upload
  with:
    package-path: './artifacts/MyPackage.1.0.0-preview.nupkg'
    source: 'https://staging-feed.company.com/v3/index.json'
    api-key: ${{ secrets.STAGING_API_KEY }}
    skip-duplicate: 'true'
```

### Validate Package Contents

Use dotnet CLI to inspect package contents before upload:

```yaml
- name: Validate package
  run: |
    dotnet nuget verify ./artifacts/*.nupkg
    unzip -l ./artifacts/*.nupkg
```

## Version Compatibility

| .NET Version | Supported |
|--------------|-----------|
| .NET 8.0 | ✅ Full Support |
| .NET 7.0 | ✅ Full Support |
| .NET 6.0 | ✅ Full Support |
| .NET 5.0 | ✅ Full Support |
| .NET Core 3.1 | ✅ Full Support |

## Contributing

When contributing to this action, please ensure:

- ✅ Follow the Actions structure principles
- 🧪 Test with both .nupkg and .snupkg packages
- 📝 Update documentation for new features
- 🔐 Handle sensitive information securely
- 🔍 Validate all inputs thoroughly
- 📊 Maintain comprehensive summary reporting
