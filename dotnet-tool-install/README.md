# 🔧 .NET Tool Install Action

A comprehensive GitHub Action for installing and managing .NET tools with support for global, local, and manifest-based installations. Includes version management, restoration, update capabilities, and advanced tool configuration options.

## ✨ Features

- 🌐 **Multiple Installation Modes** - Global, local, and tool manifest installations
- 📦 **Flexible Tool Management** - Install specific versions, restore from manifests, or update existing tools
- 🎯 **Source Configuration** - Support for custom NuGet sources and package feeds
- 🚀 **Performance Optimization** - Tool existence checking and conditional installations
- 🔧 **Advanced Configuration** - Custom tool paths, verbosity control, and architecture specification
- 📊 **Rich Action Summaries** - Detailed installation reports with tool inventory and statistics
- 🔄 **Bulk Operations** - Install multiple tools from manifests or batch configurations
- 🔍 **Tool Discovery** - Automatic detection of existing tools and version conflicts

## 🚀 Basic Usage

Install a global .NET tool:

```yaml
- name: "Install Entity Framework tools"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-ef"
```

```yaml
- name: "Install specific version"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-sonarscanner"
    version: "5.7.2"
```

```yaml
- name: "Install local tool"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-format"
    global: "false"
```

## 🔧 Advanced Usage

Complete tool installation with custom configuration:

```yaml
- name: "Advanced tool installation"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-sonarscanner"
    version: "5.7.2"
    global: "true"
    source: "https://api.nuget.org/v3/index.json"
    tool-path: "/usr/local/share/dotnet-tools"
    verbosity: "normal"
    prerelease: "false"
    architecture: "x64"
    skip-if-exists: "true"
    show-summary: "true"
```

## 🔐 Permissions Required

This action requires standard repository permissions:

```yaml
permissions:
  contents: read  # Required to checkout repository code
```

For tool manifest modifications:

```yaml
permissions:
  contents: write  # Required to update tool manifests
```

## 🏗️ CI/CD Example

Complete workflow for .NET tool management:

```yaml
name: ".NET Tool Management"

on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["main"]

permissions:
  contents: write

jobs:
  setup-tools:
    runs-on: ubuntu-latest

    steps:
      - name: "📥 Checkout repository"
        uses: actions/checkout@v4

      - name: "🔧 Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: "🔧 Install Entity Framework CLI"
        id: ef-tools
        uses: framinosona/github_actions/dotnet-tool-install@main
        with:
          package-name: "dotnet-ef"
          global: "true"
          skip-if-exists: "true"
          show-summary: "true"

      - name: "📊 Install SonarScanner"
        uses: framinosona/github_actions/dotnet-tool-install@main
        with:
          package-name: "dotnet-sonarscanner"
          version: "5.7.2"
          global: "true"
          skip-if-exists: "true"

      - name: "🎨 Install Code Formatter"
        uses: framinosona/github_actions/dotnet-tool-install@main
        with:
          package-name: "dotnet-format"
          global: "false"
          tool-path: "./tools"

      - name: "📈 Install Coverage Tools"
        uses: framinosona/github_actions/dotnet-tool-install@main
        with:
          package-name: "dotnet-reportgenerator-globaltool"
          global: "true"
          prerelease: "false"

      - name: "🔍 Install Security Scanner"
        uses: framinosona/github_actions/dotnet-tool-install@main
        with:
          package-name: "security-scan"
          source: "https://myget.org/F/security-tools/api/v3/index.json"
          global: "true"
          verbosity: "detailed"

      - name: "📦 Restore tool manifest tools"
        if: hashFiles('./.config/dotnet-tools.json') != ''
        run: dotnet tool restore

      - name: "🧪 Run Entity Framework migrations"
        if: steps.ef-tools.outputs.installed == 'true'
        run: dotnet ef database update
        working-directory: ./src/MyProject

      - name: "🎨 Format code"
        run: ./tools/dotnet-format --verify-no-changes
        continue-on-error: true

      - name: "📊 Run SonarScanner"
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        run: |
          dotnet sonarscanner begin /k:"project-key" /d:sonar.login="$SONAR_TOKEN"
          dotnet build --no-restore
          dotnet sonarscanner end /d:sonar.login="$SONAR_TOKEN"

  cross-platform-tools:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        include:
          - os: ubuntu-latest
            tool-path: "/usr/local/share/dotnet-tools"
          - os: windows-latest
            tool-path: "C:\\Tools\\dotnet"
          - os: macos-latest
            tool-path: "/usr/local/share/dotnet-tools"

    runs-on: ${{ matrix.os }}

    steps:
      - name: "📥 Checkout repository"
        uses: actions/checkout@v4

      - name: "🔧 Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: "🔧 Install cross-platform tools"
        uses: framinosona/github_actions/dotnet-tool-install@main
        with:
          package-name: "dotnet-ef"
          global: "true"
          tool-path: ${{ matrix.tool-path }}
          architecture: "x64"
          skip-if-exists: "true"
          show-summary: "true"

      - name: "✅ Verify tool installation"
        run: dotnet ef --version
```

## 📋 Inputs

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `package-name` | Name of the .NET tool package to install | ✅ Yes | - | `dotnet-ef`, `dotnet-format`, `dotnet-sonarscanner` |
| `version` | Specific version of the tool to install | ❌ No | `latest` | `5.7.2`, `3.1.0`, `6.0.0-preview.1` |
| `global` | Install tool globally (true) or locally (false) | ❌ No | `true` | `true`, `false` |
| `source` | NuGet source URL for package installation | ❌ No | `''` | `https://api.nuget.org/v3/index.json` |
| `tool-path` | Custom path for tool installation | ❌ No | `''` | `./tools`, `/usr/local/share/dotnet-tools` |
| `verbosity` | Verbosity level for installation | ❌ No | `minimal` | `quiet`, `minimal`, `normal`, `detailed`, `diagnostic` |
| `prerelease` | Allow prerelease versions | ❌ No | `false` | `true`, `false` |
| `architecture` | Target architecture for tool | ❌ No | `''` | `x86`, `x64`, `arm`, `arm64` |
| `skip-if-exists` | Skip installation if tool already exists | ❌ No | `false` | `true`, `false` |
| `show-summary` | Show detailed action summary | ❌ No | `false` | `true`, `false` |

## 📤 Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `installed` | Whether the tool was successfully installed | `true`, `false` |
| `skipped` | Whether installation was skipped (tool exists) | `true`, `false` |
| `version` | Version of the installed tool | `7.0.5`, `6.0.2` |
| `tool-path` | Path where the tool was installed | `/home/runner/.dotnet/tools` |
| `global` | Whether the tool was installed globally | `true`, `false` |
| `execution-time` | Time taken for installation in seconds | `12.34` |

## 🔗 Related Actions

| Action | Purpose | Repository |
|--------|---------|------------|
| 🔨 **dotnet** | Build .NET projects | `framinosona/github_actions/dotnet` |
| 🧪 **dotnet-test** | Run .NET tests | `framinosona/github_actions/dotnet-test` |
| 📦 **dotnet-nuget-upload** | Publish NuGet packages | `framinosona/github_actions/dotnet-nuget-upload` |
| 🔧 **dotnet-nuget-feed-setup** | Configure NuGet feeds | `framinosona/github_actions/dotnet-nuget-feed-setup` |

## 💡 Examples

### Popular .NET Tools

```yaml
# Entity Framework CLI tools
- name: "Install EF Core CLI"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-ef"
    global: "true"

# Code formatting tools
- name: "Install dotnet-format"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-format"
    global: "true"

# SonarScanner for code analysis
- name: "Install SonarScanner"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-sonarscanner"
    version: "5.7.2"
    global: "true"

# Report Generator for coverage
- name: "Install ReportGenerator"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-reportgenerator-globaltool"
    global: "true"
```

### Version-Specific Installations

```yaml
# Install specific version
- name: "Install specific EF version"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-ef"
    version: "7.0.5"
    global: "true"

# Install prerelease version
- name: "Install prerelease tool"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-format"
    version: "6.0.0-preview.1"
    prerelease: "true"
    global: "true"

# Install latest stable
- name: "Install latest stable"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-sonarscanner"
    global: "true"
```

### Local Tool Installations

```yaml
# Install to specific directory
- name: "Install to custom path"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-format"
    global: "false"
    tool-path: "./build-tools"

# Install for local use only
- name: "Install local tool"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-ef"
    global: "false"
```

### Custom Source Installations

```yaml
# Install from custom NuGet source
- name: "Install from MyGet"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "custom-analyzer"
    source: "https://www.myget.org/F/mycompany/api/v3/index.json"
    global: "true"

# Install from Azure Artifacts
- name: "Install from Azure Artifacts"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "internal-tool"
    source: "https://pkgs.dev.azure.com/myorg/_packaging/myFeed/nuget/v3/index.json"
    global: "true"
  env:
    NUGET_AUTH_TOKEN: ${{ secrets.AZURE_ARTIFACTS_TOKEN }}
```

### Conditional Installations

```yaml
# Skip if tool already exists
- name: "Install if not exists"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-ef"
    global: "true"
    skip-if-exists: "true"

# Install based on file existence
- name: "Install EF if migrations exist"
  if: hashFiles('**/Migrations/*.cs') != ''
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-ef"
    global: "true"

# Install based on project type
- name: "Install Web API tools"
  if: contains(steps.detect-project.outputs.type, 'web')
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-aspnet-codegenerator"
    global: "true"
```

### Architecture-Specific Installations

```yaml
# Install for specific architecture
- name: "Install x64 tool"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "performance-profiler"
    architecture: "x64"
    global: "true"

# Install ARM64 tool for Apple Silicon
- name: "Install ARM64 tool"
  if: runner.arch == 'ARM64'
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "native-analyzer"
    architecture: "arm64"
    global: "true"
```

### Batch Tool Installation

```yaml
strategy:
  matrix:
    tool:
      - { name: "dotnet-ef", version: "latest" }
      - { name: "dotnet-format", version: "5.1.250801" }
      - { name: "dotnet-sonarscanner", version: "5.7.2" }
      - { name: "dotnet-reportgenerator-globaltool", version: "latest" }

steps:
  - name: "Install ${{ matrix.tool.name }}"
    uses: framinosona/github_actions/dotnet-tool-install@main
    with:
      package-name: ${{ matrix.tool.name }}
      version: ${{ matrix.tool.version }}
      global: "true"
      skip-if-exists: "true"
      show-summary: "true"
```

## 🔧 Tool Manifest Management

### Working with .NET Tool Manifests

The action integrates with .NET tool manifests (`.config/dotnet-tools.json`):

#### Create Tool Manifest

```yaml
- name: "Create tool manifest"
  run: dotnet new tool-manifest

- name: "Install tool to manifest"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-ef"
    global: "false"
```

#### Restore from Manifest

```yaml
- name: "Restore tools from manifest"
  if: hashFiles('./.config/dotnet-tools.json') != ''
  run: dotnet tool restore

- name: "Install additional tool"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-format"
    global: "false"
```

#### Example Tool Manifest (`.config/dotnet-tools.json`)

```json
{
  "version": 1,
  "isRoot": true,
  "tools": {
    "dotnet-ef": {
      "version": "7.0.5",
      "commands": ["dotnet-ef"]
    },
    "dotnet-format": {
      "version": "5.1.250801",
      "commands": ["dotnet-format"]
    }
  }
}
```

## 🖥️ Requirements

- .NET SDK 6.0 or later installed on the runner
- Internet access to download tools from NuGet sources
- Appropriate permissions for tool installation location
- PowerShell Core (for Windows runners) or Bash (for Unix runners)

## 🐛 Troubleshooting

### Common Issues

#### Tool Installation Fails

**Problem**: Installation fails with permission or path errors

**Solution**: Check installation path and permissions:

```yaml
- name: "Debug tool installation"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-ef"
    global: "true"
    verbosity: "detailed"
    show-summary: "true"

- name: "Check tool path permissions"
  run: |
    echo "User: $(whoami)"
    echo "Tool path: ${{ steps.install.outputs.tool-path }}"
    ls -la ${{ steps.install.outputs.tool-path }} || echo "Path does not exist"
```

#### Version Conflicts

**Problem**: Tool version conflicts with existing installations

**Solution**: Use specific versions and check existing tools:

```yaml
- name: "List existing tools"
  run: dotnet tool list --global

- name: "Install specific version"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-ef"
    version: "7.0.5"
    global: "true"
    skip-if-exists: "false"  # Force reinstall
```

#### Custom Source Authentication

**Problem**: Authentication fails for private NuGet sources

**Solution**: Configure authentication properly:

```yaml
- name: "Configure NuGet authentication"
  run: |
    dotnet nuget add source "https://nuget.example.com/v3/index.json" \
      --name "CustomSource" \
      --username "${{ secrets.NUGET_USERNAME }}" \
      --password "${{ secrets.NUGET_PASSWORD }}" \
      --store-password-in-clear-text

- name: "Install from authenticated source"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "private-tool"
    source: "https://nuget.example.com/v3/index.json"
    global: "true"
```

#### Tool Not Found After Installation

**Problem**: Tool command not available after installation

**Solution**: Verify PATH configuration:

```yaml
- name: "Install tool"
  id: install
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-ef"
    global: "true"
    show-summary: "true"

- name: "Verify tool availability"
  run: |
    echo "Tool path: ${{ steps.install.outputs.tool-path }}"
    echo "PATH: $PATH"
    which dotnet-ef || echo "Tool not in PATH"
    dotnet tool list --global | grep dotnet-ef
```

### Debug Mode

Enable comprehensive debugging:

```yaml
- name: "Debug tool installation"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-ef"
    global: "true"
    verbosity: "diagnostic"
    show-summary: "true"
  env:
    ACTIONS_STEP_DEBUG: true
    DOTNET_CLI_TELEMETRY_OPTOUT: true
```

## 🔧 Advanced Features

### Performance Optimization

```yaml
# Cache tool installations
- name: "Cache .NET tools"
  uses: actions/cache@v3
  with:
    path: ~/.dotnet/tools
    key: dotnet-tools-${{ hashFiles('.config/dotnet-tools.json') }}

- name: "Install tools with cache"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-ef"
    global: "true"
    skip-if-exists: "true"
```

### Tool Version Management

```yaml
# Update tool to latest version
- name: "Update tool"
  run: dotnet tool update --global dotnet-ef

# Uninstall and reinstall
- name: "Reinstall tool"
  run: |
    dotnet tool uninstall --global dotnet-ef || true

- name: "Install fresh tool"
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-ef"
    global: "true"
```

### Tool Validation

```yaml
- name: "Install and validate tool"
  id: install
  uses: framinosona/github_actions/dotnet-tool-install@main
  with:
    package-name: "dotnet-ef"
    global: "true"
    show-summary: "true"

- name: "Validate tool installation"
  run: |
    if [ "${{ steps.install.outputs.installed }}" = "true" ]; then
      echo "✅ Tool installed successfully"
      dotnet ef --version
    else
      echo "❌ Tool installation failed"
      exit 1
    fi
```

## 📄 License

This action is part of the GitHub Actions collection by Francois Raminosona.

---

> 💡 **Tip**: Use this action to standardize .NET tool management across your development workflow and ensure consistent tooling in all environments.
