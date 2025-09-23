# 🔗 Setup NuGet Feed Action

Adds a NuGet package source using `dotnet nuget add source` with comprehensive authentication support and validation.

## Features

- 🔗 Add public and private NuGet sources
- 🔐 Secure authentication with username/password
- ⚙️ Custom configuration file support
- 🔍 Source verification after addition
- 🌐 Support for various authentication types
- 📊 Comprehensive validation and error handling
- 🛡️ Credential masking for security

## Usage

### Basic Usage - Add Public Source
```yaml
- name: Add MyGet feed
  uses: ./dotnet-nuget-feed-setup
  with:
    name: 'MyGet'
    source: 'https://www.myget.org/F/myfeed/api/v3/index.json'
```

### Add Private Feed with Authentication
```yaml
- name: Add private company feed
  uses: ./dotnet-nuget-feed-setup
  with:
    name: 'CompanyFeed'
    source: 'https://nuget.company.com/v3/index.json'
    username: ${{ secrets.NUGET_USERNAME }}
    password: ${{ secrets.NUGET_PASSWORD }}
```

### Advanced Usage - GitHub Packages
```yaml
- name: Setup GitHub Packages
  uses: ./dotnet-nuget-feed-setup
  with:
    name: 'github'
    source: 'https://nuget.pkg.github.com/myorg/index.json'
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

### Enterprise Setup - Azure DevOps with Custom Config
```yaml
- name: Setup Azure DevOps feed
  uses: ./dotnet-nuget-feed-setup
  with:
    name: 'AzureDevOps'
    source: 'https://pkgs.dev.azure.com/myorg/_packaging/myfeed/nuget/v3/index.json'
    username: 'PAT'
    password: ${{ secrets.AZURE_DEVOPS_PAT }}
    configfile: './nuget.config'
    valid-authentication-types: 'basic'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `name` | Name for the NuGet source (must be unique) | ✅ Yes | |
| `source` | URL of the NuGet package source | ✅ Yes | |
| `username` | Username for authenticated feeds | ❌ No | `""` |
| `password` | Password or token for authenticated feeds (use secrets for security) | ❌ No | `""` |
| `store-password-in-clear-text` | Store password in clear text instead of encrypted (true/false) | ❌ No | `"false"` |
| `valid-authentication-types` | Valid authentication types for this source (basic, negotiate, etc.) | ❌ No | `""` |
| `configfile` | NuGet configuration file to modify | ❌ No | `""` |
| `working-directory` | Working directory for the operation | ❌ No | `"."` |
| `verbosity` | Verbosity level (quiet, minimal, normal, detailed, diagnostic) | ❌ No | `""` |
| `show-summary` | Whether to show the action summary | ❌ No | `"true"` |

## Outputs

| Output | Description |
|--------|-------------|
| `exit-code` | Exit code of the nuget add source command |
| `executed-command` | The actual command that was executed (credentials masked) |
| `source-added` | Whether the source was successfully added (true/false) |

## Examples

### Example 1: Complete Setup for Multi-Source Project
```yaml
name: Setup NuGet Sources
on: [push, pull_request]

jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Add company private feed
        uses: ./dotnet-nuget-feed-setup
        with:
          name: 'CompanyPrivate'
          source: 'https://nuget.company.com/v3/index.json'
          username: ${{ secrets.COMPANY_NUGET_USER }}
          password: ${{ secrets.COMPANY_NUGET_TOKEN }}

      - name: Add prerelease feed
        uses: ./dotnet-nuget-feed-setup
        with:
          name: 'Prerelease'
          source: 'https://prerelease.nuget.company.com/v3/index.json'
          username: ${{ secrets.COMPANY_NUGET_USER }}
          password: ${{ secrets.COMPANY_NUGET_TOKEN }}

      - name: Restore packages
        run: dotnet restore

      - name: Build
        run: dotnet build --configuration Release
```

### Example 2: Matrix Setup for Multiple Feeds
```yaml
name: Setup Multiple NuGet Feeds
on: [push]

jobs:
  setup:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        feed:
          - name: 'GitHub'
            source: 'https://nuget.pkg.github.com/myorg/index.json'
            username: '${{ github.actor }}'
            password: 'GITHUB_TOKEN'
          - name: 'MyGet'
            source: 'https://www.myget.org/F/myfeed/api/v3/index.json'
            username: 'myget-user'
            password: 'MYGET_API_KEY'
          - name: 'Azure'
            source: 'https://pkgs.dev.azure.com/myorg/_packaging/myfeed/nuget/v3/index.json'
            username: 'PAT'
            password: 'AZURE_DEVOPS_PAT'

    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Setup ${{ matrix.feed.name }} feed
        uses: ./dotnet-nuget-feed-setup
        with:
          name: ${{ matrix.feed.name }}
          source: ${{ matrix.feed.source }}
          username: ${{ matrix.feed.username }}
          password: ${{ secrets[matrix.feed.password] }}

      - name: Test restore
        run: dotnet restore --verbosity detailed
```

### Example 3: Environment-Specific Feed Setup
```yaml
name: Environment-Specific Setup
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options:
          - development
          - staging
          - production

jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Setup development feed
        if: github.event.inputs.environment == 'development'
        uses: ./dotnet-nuget-feed-setup
        with:
          name: 'Development'
          source: 'https://dev-nuget.company.com/v3/index.json'
          username: ${{ secrets.DEV_NUGET_USER }}
          password: ${{ secrets.DEV_NUGET_TOKEN }}

      - name: Setup staging feed
        if: github.event.inputs.environment == 'staging'
        uses: ./dotnet-nuget-feed-setup
        with:
          name: 'Staging'
          source: 'https://staging-nuget.company.com/v3/index.json'
          username: ${{ secrets.STAGING_NUGET_USER }}
          password: ${{ secrets.STAGING_NUGET_TOKEN }}

      - name: Setup production feed
        if: github.event.inputs.environment == 'production'
        uses: ./dotnet-nuget-feed-setup
        with:
          name: 'Production'
          source: 'https://prod-nuget.company.com/v3/index.json'
          username: ${{ secrets.PROD_NUGET_USER }}
          password: ${{ secrets.PROD_NUGET_TOKEN }}
          valid-authentication-types: 'basic'
```

### Example 4: Custom Configuration File Management
```yaml
name: Custom NuGet Configuration
on: [push]

jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Create custom nuget.config directory
        run: mkdir -p ./config

      - name: Setup feed with custom config
        uses: ./dotnet-nuget-feed-setup
        with:
          name: 'CustomFeed'
          source: 'https://custom.nuget.company.com/v3/index.json'
          username: ${{ secrets.CUSTOM_NUGET_USER }}
          password: ${{ secrets.CUSTOM_NUGET_TOKEN }}
          configfile: './config/nuget.config'
          store-password-in-clear-text: 'false'

      - name: Verify configuration
        run: |
          cat ./config/nuget.config
          dotnet nuget list source --configfile ./config/nuget.config

      - name: Restore with custom config
        run: dotnet restore --configfile ./config/nuget.config
```

## Requirements

- ✅ .NET SDK must be installed (use `actions/setup-dotnet`)
- ✅ Valid NuGet source URL
- ✅ Appropriate credentials for private feeds
- ✅ Network access to target NuGet sources

## Common NuGet Sources

| Provider | URL Pattern | Authentication |
|----------|-------------|----------------|
| **NuGet.org** | `https://api.nuget.org/v3/index.json` | None (public) |
| **GitHub Packages** | `https://nuget.pkg.github.com/OWNER/index.json` | Username + PAT |
| **Azure DevOps** | `https://pkgs.dev.azure.com/ORG/_packaging/FEED/nuget/v3/index.json` | Username + PAT |
| **MyGet** | `https://www.myget.org/F/FEED/api/v3/index.json` | Username + API Key |
| **Artifactory** | `https://COMPANY.jfrog.io/artifactory/api/nuget/REPO` | Username + API Key |
| **Nexus** | `https://nexus.company.com/repository/nuget-hosted/` | Username + Password |

## Authentication Types

| Type | Description | Use Case |
|------|-------------|----------|
| `basic` | Basic HTTP authentication | Most private feeds |
| `negotiate` | Windows integrated authentication | Corporate NTLM/Kerberos |
| `digest` | Digest authentication | Legacy systems |

## Security Best Practices

### 🔐 Credential Management
- **Never hardcode credentials** in workflow files
- **Use GitHub Secrets** for sensitive information
- **Rotate credentials regularly**
- **Use least-privilege access** for feed accounts

```yaml
# ✅ Good - Using secrets
username: ${{ secrets.NUGET_USERNAME }}
password: ${{ secrets.NUGET_TOKEN }}

# ❌ Bad - Hardcoded credentials
username: 'myuser@company.com'
password: 'mypassword123'
```

### 🔒 Password Storage
- **Default encryption**: Passwords are encrypted by default
- **Clear text option**: Only use `store-password-in-clear-text: 'true'` when absolutely necessary
- **Environment isolation**: Use different credentials for different environments

### 🛡️ Network Security
- **HTTPS only**: Always use HTTPS URLs for sources
- **Validate certificates**: Ensure proper SSL/TLS validation
- **Network restrictions**: Use VPN or private networks when possible

## Error Handling

The action provides comprehensive error handling for common scenarios:

### 🔍 **Validation Errors**
- Invalid or missing source URLs
- Malformed authentication credentials
- Missing required parameters
- Invalid configuration files

### 🌐 **Network Errors**
- Unreachable source URLs
- DNS resolution failures
- SSL/TLS certificate issues
- Proxy configuration problems

### 🔐 **Authentication Errors**
- Invalid credentials
- Expired tokens
- Insufficient permissions
- Wrong authentication type

## Troubleshooting

### Common Issues

1. **Source Already Exists**
   ```
   error: Source with Name 'MyFeed' already exists.
   ```
   - **Solution**: Use a different name or remove the existing source first

2. **Authentication Failed**
   ```
   error: Unable to access feed - 401 Unauthorized
   ```
   - **Solution**: Verify credentials and permissions

3. **Invalid URL**
   ```
   error: Invalid URI: The hostname could not be parsed.
   ```
   - **Solution**: Check URL format and network connectivity

4. **Permission Denied**
   ```
   error: Access to the path is denied.
   ```
   - **Solution**: Check file permissions for configuration file

### Debug Mode

Enable detailed logging:

```yaml
- name: Setup feed with debug output
  uses: ./dotnet-nuget-feed-setup
  with:
    name: 'DebugFeed'
    source: 'https://debug.company.com/v3/index.json'
    username: ${{ secrets.DEBUG_USER }}
    password: ${{ secrets.DEBUG_TOKEN }}
    verbosity: 'detailed'
```

### Verify Configuration

Check added sources:

```yaml
- name: List all sources
  run: dotnet nuget list source --format detailed

- name: Test source connectivity
  run: dotnet restore --verbosity detailed
```

### Configuration File Inspection

Examine the generated configuration:

```yaml
- name: Show NuGet config
  run: |
    echo "=== Global Config ==="
    cat ~/.nuget/NuGet/NuGet.Config || echo "No global config found"
    echo "=== Project Config ==="
    cat ./nuget.config || echo "No project config found"
```

## Advanced Configuration

### Custom Authentication Types

For specialized authentication scenarios:

```yaml
- name: Setup with negotiate auth
  uses: ./dotnet-nuget-feed-setup
  with:
    name: 'Corporate'
    source: 'https://corporate.company.com/nuget'
    username: 'DOMAIN\user'
    password: ${{ secrets.DOMAIN_PASSWORD }}
    valid-authentication-types: 'negotiate,basic'
```

### Multiple Configuration Files

Managing multiple configuration contexts:

```yaml
- name: Setup development config
  uses: ./dotnet-nuget-feed-setup
  with:
    name: 'DevFeed'
    source: 'https://dev.company.com/nuget'
    configfile: './configs/dev.nuget.config'
    username: ${{ secrets.DEV_USER }}
    password: ${{ secrets.DEV_TOKEN }}

- name: Setup production config
  uses: ./dotnet-nuget-feed-setup
  with:
    name: 'ProdFeed'
    source: 'https://prod.company.com/nuget'
    configfile: './configs/prod.nuget.config'
    username: ${{ secrets.PROD_USER }}
    password: ${{ secrets.PROD_TOKEN }}
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
- 🧪 Test with various authentication methods
- 📝 Update documentation for new features
- 🔐 Handle credentials securely
- 🔍 Validate all inputs thoroughly
- 📊 Maintain comprehensive summary reporting
- 🌐 Test with different NuGet feed providers
