# 🔗 .NET NuGet Feed Setup Action

A comprehensive GitHub Action for configuring NuGet package sources with support for authentication, custom configurations, and enterprise feed management.

## ✨ Features

- 🔗 **Multiple Source Types** - Support for public and private NuGet feeds
- 🔐 **Secure Authentication** - Username/password, PAT, and API key authentication with credential masking
- ⚙️ **Custom Configuration** - Support for custom NuGet.config files and configuration paths
- 🔍 **Source Verification** - Automatic validation and connectivity testing after setup
- 🌐 **Enterprise Ready** - Support for Azure DevOps, GitHub Packages, Artifactory, and custom feeds
- 📊 **Comprehensive Validation** - Input validation, source validation, and detailed error handling
- 🛡️ **Security Features** - Credential encryption and secure storage options
- 🚀 **Performance Optimization** - Efficient source configuration and batch operations

## 🚀 Basic Usage

Add a public NuGet source:

```yaml
- name: "Add MyGet feed"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "MyGet"
    source: "https://www.myget.org/F/myfeed/api/v3/index.json"
```

```yaml
- name: "Add GitHub Packages"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "github"
    source: "https://nuget.pkg.github.com/myorg/index.json"
    username: "${{ github.actor }}"
    password: ${{ secrets.GITHUB_TOKEN }}
```

```yaml
- name: "Add Azure DevOps feed"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "AzureDevOps"
    source: "https://pkgs.dev.azure.com/myorg/_packaging/myfeed/nuget/v3/index.json"
    username: "PAT"
    password: ${{ secrets.AZURE_DEVOPS_PAT }}
```

## 🔧 Advanced Usage

Complete feed setup with advanced authentication and configuration:

```yaml
- name: "Enterprise feed setup"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "EnterpriseFeed"
    source: "https://nuget.company.com/v3/index.json"
    username: "${{ secrets.ENTERPRISE_NUGET_USER }}"
    password: ${{ secrets.ENTERPRISE_NUGET_TOKEN }}
    store-password-in-clear-text: "false"
    valid-authentication-types: "basic,negotiate"
    configfile: "./config/nuget.config"
    working-directory: "./src"
    verbosity: "normal"
    show-summary: "true"
```

## 🔐 Permissions Required

This action requires standard repository permissions:

```yaml
permissions:
  contents: read  # Required to checkout repository code
```

For modifying configuration files in repository:

```yaml
permissions:
  contents: write  # Required to update configuration files
```

## 🏗️ CI/CD Example

Complete workflow for multi-source NuGet configuration:

```yaml
name: "Setup Development Environment"

on:
  push:
    branches: ["main", "develop"]
  pull_request:
    branches: ["main"]

permissions:
  contents: read

jobs:
  setup-nuget-sources:
    runs-on: ubuntu-latest

    steps:
      - name: "📥 Checkout repository"
        uses: actions/checkout@v4

      - name: "🔧 Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: "🔗 Add company private feed"
        id: company-feed
        uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
        with:
          name: "CompanyPrivate"
          source: "https://nuget.company.com/v3/index.json"
          username: "${{ secrets.COMPANY_NUGET_USER }}"
          password: ${{ secrets.COMPANY_NUGET_TOKEN }}
          show-summary: "true"

      - name: "🔗 Add prerelease feed"
        uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
        with:
          name: "Prerelease"
          source: "https://prerelease.nuget.company.com/v3/index.json"
          username: "${{ secrets.COMPANY_NUGET_USER }}"
          password: ${{ secrets.COMPANY_NUGET_TOKEN }}
          valid-authentication-types: "basic"

      - name: "🔗 Add GitHub Packages"
        uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
        with:
          name: "GitHub"
          source: "https://nuget.pkg.github.com/${{ github.repository_owner }}/index.json"
          username: "${{ github.actor }}"
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: "🔗 Add Azure DevOps artifacts"
        if: github.ref == 'refs/heads/main'
        uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
        with:
          name: "AzureArtifacts"
          source: "https://pkgs.dev.azure.com/myorg/_packaging/production/nuget/v3/index.json"
          username: "AzureDevOps"
          password: ${{ secrets.AZURE_DEVOPS_PAT }}
          store-password-in-clear-text: "false"

      - name: "📋 List configured sources"
        run: dotnet nuget list source --format detailed

      - name: "📦 Restore packages"
        run: dotnet restore --verbosity normal

      - name: "🔨 Build solution"
        run: dotnet build --configuration Release --no-restore

      - name: "🧪 Run tests"
        uses: laerdal/github_actions/dotnet-test@main
        with:
          projects: "**/*Tests.csproj"
          configuration: "Release"
          no-build: "true"

  environment-specific-setup:
    strategy:
      matrix:
        environment: [development, staging, production]
        include:
          - environment: development
            feed-url: "https://dev-nuget.company.com/v3/index.json"
            secret-prefix: "DEV"
          - environment: staging
            feed-url: "https://staging-nuget.company.com/v3/index.json"
            secret-prefix: "STAGING"
          - environment: production
            feed-url: "https://prod-nuget.company.com/v3/index.json"
            secret-prefix: "PROD"

    runs-on: ubuntu-latest
    environment: ${{ matrix.environment }}

    steps:
      - name: "📥 Checkout repository"
        uses: actions/checkout@v4

      - name: "🔧 Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: "🔗 Setup ${{ matrix.environment }} feed"
        uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
        with:
          name: "${{ matrix.environment }}"
          source: ${{ matrix.feed-url }}
          username: "${{ secrets[format('{0}_NUGET_USER', matrix.secret-prefix)] }}"
          password: ${{ secrets[format('{0}_NUGET_TOKEN', matrix.secret-prefix)] }}
          configfile: "./configs/${{ matrix.environment }}.nuget.config"
          show-summary: "true"

      - name: "✅ Verify feed connectivity"
        run: |
          dotnet nuget list source --configfile "./configs/${{ matrix.environment }}.nuget.config"
          dotnet restore --configfile "./configs/${{ matrix.environment }}.nuget.config" --verbosity minimal
```

## 📋 Inputs

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `name` | Unique name for the NuGet source | ✅ Yes | - | `CompanyFeed`, `MyGet`, `GitHub` |
| `source` | URL of the NuGet package source | ✅ Yes | - | `https://api.nuget.org/v3/index.json` |
| `username` | Username for authenticated feeds | ❌ No | `''` | `${{ github.actor }}`, `PAT` |
| `password` | Password/token for authentication | ❌ No | `''` | `${{ secrets.NUGET_TOKEN }}` |
| `store-password-in-clear-text` | Store password in clear text | ❌ No | `false` | `true`, `false` |
| `valid-authentication-types` | Valid authentication types | ❌ No | `''` | `basic`, `negotiate`, `basic,negotiate` |
| `configfile` | NuGet configuration file path | ❌ No | `''` | `./nuget.config`, `./configs/dev.config` |
| `working-directory` | Working directory for operations | ❌ No | `.` | `./src`, `./packages` |
| `verbosity` | Verbosity level | ❌ No | `''` | `quiet`, `minimal`, `normal`, `detailed`, `diagnostic` |
| `show-summary` | Show detailed action summary | ❌ No | `true` | `true`, `false` |

## 📤 Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `exit-code` | Exit code of the add source command | `0`, `1` |
| `executed-command` | Command executed (credentials masked) | `dotnet nuget add source ...` |
| `source-added` | Whether source was successfully added | `true`, `false` |

## 🔗 Related Actions

| Action | Purpose | Repository |
|--------|---------|------------|
| 📦 **dotnet-nuget-upload** | Upload NuGet packages | `laerdal/github_actions/dotnet-nuget-upload` |
| 🔨 **dotnet** | Build .NET projects | `laerdal/github_actions/dotnet` |
| 🧪 **dotnet-test** | Run .NET tests | `laerdal/github_actions/dotnet-test` |
| 🔧 **dotnet-tool-install** | Install .NET tools | `laerdal/github_actions/dotnet-tool-install` |

## 💡 Examples

### Popular NuGet Sources

```yaml
# NuGet.org (public - no auth needed)
- name: "Add NuGet.org"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "nuget.org"
    source: "https://api.nuget.org/v3/index.json"

# GitHub Packages
- name: "Add GitHub Packages"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "github"
    source: "https://nuget.pkg.github.com/myorg/index.json"
    username: "${{ github.actor }}"
    password: ${{ secrets.GITHUB_TOKEN }}

# Azure DevOps Artifacts
- name: "Add Azure DevOps"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "azure-artifacts"
    source: "https://pkgs.dev.azure.com/myorg/_packaging/myfeed/nuget/v3/index.json"
    username: "AzureDevOps"
    password: ${{ secrets.AZURE_DEVOPS_PAT }}

# MyGet Feed
- name: "Add MyGet"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "myget"
    source: "https://www.myget.org/F/myfeed/api/v3/index.json"
    username: "${{ secrets.MYGET_USERNAME }}"
    password: ${{ secrets.MYGET_API_KEY }}
```

### Authentication Methods

```yaml
# Basic authentication
- name: "Basic auth feed"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "basic-feed"
    source: "https://nuget.company.com/v3/index.json"
    username: "${{ secrets.NUGET_USERNAME }}"
    password: ${{ secrets.NUGET_PASSWORD }}"
    valid-authentication-types: "basic"

# Windows integrated authentication
- name: "Windows auth feed"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "windows-feed"
    source: "https://internal.company.com/nuget"
    username: "DOMAIN\\${{ secrets.DOMAIN_USER }}"
    password: ${{ secrets.DOMAIN_PASSWORD }}
    valid-authentication-types: "negotiate"

# API Key authentication
- name: "API key feed"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "api-key-feed"
    source: "https://artifactory.company.com/api/nuget/nuget-repo"
    username: "${{ secrets.ARTIFACTORY_USER }}"
    password: ${{ secrets.ARTIFACTORY_API_KEY }}
```

### Custom Configuration Files

```yaml
# Create custom config directory
- name: "Create config directory"
  run: mkdir -p ./config

# Setup with custom config file
- name: "Setup with custom config"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "custom-feed"
    source: "https://custom.company.com/v3/index.json"
    username: "${{ secrets.CUSTOM_USER }}"
    password: ${{ secrets.CUSTOM_TOKEN }}"
    configfile: "./config/nuget.config"
    store-password-in-clear-text: "false"

# Use config file for restore
- name: "Restore with custom config"
  run: dotnet restore --configfile ./config/nuget.config
```

### Conditional Feed Setup

```yaml
# Development vs Production feeds
- name: "Setup development feed"
  if: github.ref == 'refs/heads/develop'
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "development"
    source: "https://dev-nuget.company.com/v3/index.json"
    username: "${{ secrets.DEV_NUGET_USER }}"
    password: ${{ secrets.DEV_NUGET_TOKEN }}

- name: "Setup production feed"
  if: github.ref == 'refs/heads/main'
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "production"
    source: "https://prod-nuget.company.com/v3/index.json"
    username: "${{ secrets.PROD_NUGET_USER }}"
    password: ${{ secrets.PROD_NUGET_TOKEN }}

# Feature branch specific feeds
- name: "Setup feature feed"
  if: startsWith(github.ref, 'refs/heads/feature/')
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "feature-preview"
    source: "https://preview.company.com/v3/index.json"
    username: "${{ secrets.PREVIEW_USER }}"
    password: ${{ secrets.PREVIEW_TOKEN }}
```

### Batch Feed Configuration

```yaml
strategy:
  matrix:
    feed:
      - name: "github"
        source: "https://nuget.pkg.github.com/myorg/index.json"
        username: "${{ github.actor }}"
        password: "GITHUB_TOKEN"
      - name: "azure"
        source: "https://pkgs.dev.azure.com/myorg/_packaging/feed/nuget/v3/index.json"
        username: "PAT"
        password: "AZURE_DEVOPS_PAT"
      - name: "artifactory"
        source: "https://company.jfrog.io/artifactory/api/nuget/nuget-repo"
        username: "artifactory-user"
        password: "ARTIFACTORY_TOKEN"

steps:
  - name: "Setup ${{ matrix.feed.name }} feed"
    uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
    with:
      name: ${{ matrix.feed.name }}
      source: ${{ matrix.feed.source }}
      username: ${{ matrix.feed.username }}
      password: ${{ secrets[matrix.feed.password] }}
      show-summary: "true"
```

## 🔗 Common NuGet Sources

| Provider | URL Pattern | Authentication Type |
|----------|-------------|-------------------|
| **NuGet.org** | `https://api.nuget.org/v3/index.json` | None (public) |
| **GitHub Packages** | `https://nuget.pkg.github.com/OWNER/index.json` | Username + PAT |
| **Azure DevOps** | `https://pkgs.dev.azure.com/ORG/_packaging/FEED/nuget/v3/index.json` | Username + PAT |
| **MyGet** | `https://www.myget.org/F/FEED/api/v3/index.json` | Username + API Key |
| **Artifactory** | `https://COMPANY.jfrog.io/artifactory/api/nuget/REPO` | Username + API Key |
| **Nexus** | `https://nexus.company.com/repository/nuget-hosted/` | Username + Password |
| **ProGet** | `https://proget.company.com/nuget/FEED` | Username + API Key |

## 🔐 Security Best Practices

### Credential Management

```yaml
# ✅ Best Practices
secrets:
  COMPANY_NUGET_USER: "service-account@company.com"
  COMPANY_NUGET_TOKEN: "secure-token-here"
  AZURE_DEVOPS_PAT: "basic-auth-token"
  GITHUB_TOKEN: "${{ secrets.GITHUB_TOKEN }}"

# ❌ Avoid
username: "myuser@company.com"      # Hardcoded
password: "mypassword123"           # Hardcoded
```

### Authentication Types

```yaml
# Basic HTTP authentication (most common)
valid-authentication-types: "basic"

# Windows integrated authentication
valid-authentication-types: "negotiate"

# Multiple auth types (fallback)
valid-authentication-types: "basic,negotiate"

# Digest authentication (legacy)
valid-authentication-types: "digest"
```

### Password Storage Options

```yaml
# Encrypted storage (recommended)
store-password-in-clear-text: "false"

# Clear text (only when required)
store-password-in-clear-text: "true"
```

## 🖥️ Requirements

- .NET SDK 6.0 or later installed on the runner
- Valid NuGet source URLs with appropriate access
- Proper authentication credentials for private feeds
- Network connectivity to target sources
- PowerShell Core (Windows) or Bash (Unix) shell

## 🐛 Troubleshooting

### Common Issues

#### Source Already Exists

**Problem**: "error: Source with Name 'MyFeed' already exists"

**Solution**: Use unique names or remove existing source:

```yaml
- name: "Remove existing source"
  run: dotnet nuget remove source "MyFeed" || echo "Source not found"
  continue-on-error: true

- name: "Add source"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "MyFeed"
    source: "https://example.com/v3/index.json"
```

#### Authentication Failed

**Problem**: "Unable to access feed - 401 Unauthorized"

**Solution**: Verify credentials and test connectivity:

```yaml
- name: "Debug authentication"
  run: |
    echo "Testing connectivity to feed..."
    curl -I "${{ inputs.source }}" || echo "Feed not accessible"

    echo "Checking credential format..."
    if [ ! -z "${{ secrets.NUGET_TOKEN }}" ]; then
      echo "✅ Token is set"
    else
      echo "❌ Token is missing"
    fi

- name: "Setup with debug"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "debug-feed"
    source: "https://example.com/v3/index.json"
    username: "${{ secrets.NUGET_USER }}"
    password: ${{ secrets.NUGET_TOKEN }}
    verbosity: "detailed"
    show-summary: "true"
```

#### Invalid URL or Network Issues

**Problem**: "Invalid URI" or "hostname could not be parsed"

**Solution**: Validate URL format and connectivity:

```yaml
- name: "Validate feed URL"
  run: |
    echo "Validating URL format..."
    url="${{ inputs.source }}"
    if [[ $url =~ ^https?:// ]]; then
      echo "✅ URL format is valid"
    else
      echo "❌ Invalid URL format: $url"
      exit 1
    fi

    echo "Testing connectivity..."
    curl -sSf "$url" > /dev/null && echo "✅ Feed is accessible" || echo "❌ Feed is not accessible"

- name: "Setup validated feed"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "validated-feed"
    source: "${{ inputs.source }}"
    username: "${{ secrets.NUGET_USER }}"
    password: ${{ secrets.NUGET_TOKEN }}"
```

#### Configuration File Issues

**Problem**: "Access to the path is denied" or configuration errors

**Solution**: Check permissions and file paths:

```yaml
- name: "Prepare config directory"
  run: |
    mkdir -p $(dirname "${{ inputs.configfile }}")
    chmod 755 $(dirname "${{ inputs.configfile }}")

- name: "Setup with custom config"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "custom-feed"
    source: "https://example.com/v3/index.json"
    configfile: "${{ inputs.configfile }}"
    verbosity: "normal"

- name: "Verify config file"
  run: |
    if [ -f "${{ inputs.configfile }}" ]; then
      echo "✅ Config file created successfully"
      cat "${{ inputs.configfile }}"
    else
      echo "❌ Config file not found"
    fi
```

### Debug Mode

Enable comprehensive debugging:

```yaml
- name: "Debug feed setup"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "debug-feed"
    source: "https://example.com/v3/index.json"
    username: "${{ secrets.NUGET_USER }}"
    password: ${{ secrets.NUGET_TOKEN }}
    verbosity: "diagnostic"
    show-summary: "true"
  env:
    ACTIONS_STEP_DEBUG: true
    DOTNET_CLI_TELEMETRY_OPTOUT: true
```

### Configuration Inspection

```yaml
- name: "Inspect NuGet configuration"
  run: |
    echo "=== Global NuGet Config ==="
    dotnet nuget list source --format detailed

    echo "=== Global Config File ==="
    cat ~/.nuget/NuGet/NuGet.Config 2>/dev/null || echo "No global config found"

    echo "=== Project Config File ==="
    cat ./nuget.config 2>/dev/null || echo "No project config found"

    echo "=== Custom Config File ==="
    cat "${{ inputs.configfile }}" 2>/dev/null || echo "No custom config found"
```

## 🔧 Advanced Features

### Multi-Environment Configuration

```yaml
- name: "Setup environment-specific feeds"
  run: |
    # Create environment-specific config files
    envs=("development" "staging" "production")

    for env in "${envs[@]}"; do
      mkdir -p "./configs/$env"
      echo "Setting up $env environment..."
    done

- name: "Development feed"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "dev-feed"
    source: "https://dev-nuget.company.com/v3/index.json"
    username: "${{ secrets.DEV_NUGET_USER }}"
    password: ${{ secrets.DEV_NUGET_TOKEN }}
    configfile: "./configs/development/nuget.config"

- name: "Production feed"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "prod-feed"
    source: "https://prod-nuget.company.com/v3/index.json"
    username: "${{ secrets.PROD_NUGET_USER }}"
    password: ${{ secrets.PROD_NUGET_TOKEN }}
    configfile: "./configs/production/nuget.config"
```

### Feed Health Monitoring

```yaml
- name: "Setup and monitor feeds"
  id: setup
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "monitored-feed"
    source: "https://example.com/v3/index.json"
    username: "${{ secrets.NUGET_USER }}"
    password: ${{ secrets.NUGET_TOKEN }}"
    show-summary: "true"

- name: "Test feed health"
  if: steps.setup.outputs.source-added == 'true'
  run: |
    echo "Testing feed health..."
    timeout 30s dotnet restore --dry-run || echo "Feed health check failed"

    echo "Listing available packages (sample)..."
    timeout 10s dotnet search Microsoft.Extensions.Logging --source "monitored-feed" || echo "Search test failed"
```

### Credential Rotation Workflow

```yaml
- name: "Rotate feed credentials"
  run: |
    # Remove old source
    dotnet nuget remove source "rotating-feed" || echo "Source not found"

    # Add with new credentials
- name: "Setup with new credentials"
  uses: laerdal/github_actions/dotnet-nuget-feed-setup@main
  with:
    name: "rotating-feed"
    source: "https://example.com/v3/index.json"
    username: "${{ secrets.NEW_NUGET_USER }}"
    password: ${{ secrets.NEW_NUGET_TOKEN }}"
    store-password-in-clear-text: "false"
```

## 📄 License

This action is part of the GitHub Actions collection by Francois Raminosona.

---

> 💡 **Tip**: Always validate feed connectivity after setup and use environment-specific configuration files for better security and management.
