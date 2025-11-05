# 📖 DocFX Metadata Generation Action

A comprehensive GitHub Action for extracting API metadata from .NET source code using DocFX .NET Global Tool with automatic dependency management and extensive configuration options.

## ✨ Features

- 📖 **API Metadata Extraction** - Generate YAML metadata from .NET source code
- 🔧 **Automatic Tool Management** - Installs and manages DocFX global tool
- 📊 **Multi-Project Support** - Handle solutions and multiple projects
- 🎯 **Smart Configuration** - Flexible docfx.json configuration handling
- ⚡ **Performance Optimized** - Configurable filtering and processing options
- 🛡️ **Cross-Platform** - Works on Windows, Linux, and macOS runners
- 📋 **Comprehensive Validation** - Input validation with helpful error messages

## 🚀 Basic Usage

Generate metadata with default settings:

```yaml
- name: "Generate API metadata"
  uses: laerdal/github_actions/dotnet-docfx-metadata@main
  with:
    config: "docfx.json"
```

```yaml
- name: "Generate from specific projects"
  uses: laerdal/github_actions/dotnet-docfx-metadata@main
  with:
    config: "docs/docfx.json"
    projects: "./src/**/*.csproj"
```

```yaml
- name: "Generate with verbose output"
  uses: laerdal/github_actions/dotnet-docfx-metadata@main
  with:
    config: "docfx.json"
    log-level: "verbose"
```

## 🔧 Advanced Usage

Full configuration with all available options:

```yaml
- name: "Advanced metadata generation"
  uses: laerdal/github_actions/dotnet-docfx-metadata@main
  with:
    config: "docs/docfx.json"
    projects: "./src/**/*.csproj"
    output: "./docs/api"
    log-level: "detailed"
    log-file: "./logs/metadata.json"
    working-directory: "./documentation"
    global: "true"
    filter: "filterConfig.yml"
    force: "false"
    preserve-raw-inline-comments: "true"
    disable-git-features: "false"
    disable-default-filter: "false"
    name-for-cref: "NamespaceName"
    should-skip-markup: "false"
    raw: "false"
    show-summary: "true"
```

## 🔐 Permissions Required

This action requires standard repository permissions:

```yaml
permissions:
  contents: read  # Required to checkout repository code
```

## 🏗️ CI/CD Example

Complete workflow for API documentation generation:

```yaml
name: "API Documentation Pipeline"

on:
  push:
    branches: ["main"]
    paths: ["src/**/*.cs", "docs/**"]
  pull_request:
    branches: ["main"]

permissions:
  contents: read

jobs:
  generate-api-docs:
    runs-on: ubuntu-latest

    steps:
      - name: "📥 Checkout repository"
        uses: actions/checkout@v4

      - name: "🔧 Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: "📦 Restore dependencies"
        uses: laerdal/github_actions/dotnet@main
        with:
          command: "restore"

      - name: "📖 Generate API metadata"
        id: generate-metadata
        uses: laerdal/github_actions/dotnet-docfx-metadata@main
        with:
          config: "docs/docfx.json"
          projects: "./src/**/*.csproj"
          output: "./docs/api"
          log-level: "info"
          force: "true"
          preserve-raw-inline-comments: "true"
          show-summary: "true"

      - name: "📚 Build documentation site"
        uses: laerdal/github_actions/dotnet-docfx-build@main
        with:
          config: "docs/docfx.json"
          output: "./dist/docs"

      - name: "📤 Upload documentation artifact"
        uses: actions/upload-artifact@v4
        with:
          name: "api-documentation"
          path: ./dist/docs
```

## 📋 Inputs

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `config` | Path to DocFX configuration file | ❌ No | `"docfx.json"` | `docs/docfx.json`, `./config/docs.json` |
| `projects` | Glob pattern for project files | ❌ No | `""` | `./src/**/*.csproj`, `MyProject.csproj` |
| `output` | Output directory for metadata files | ❌ No | `"api"` | `./docs/api`, `./metadata` |
| `log-level` | Logging verbosity level | ❌ No | `"info"` | `quiet`, `minimal`, `info`, `verbose`, `diagnostic` |
| `log-file` | Path to save structured JSON logs | ❌ No | `""` | `./logs/metadata.json` |
| `working-directory` | Working directory for command execution | ❌ No | `"."` | `./docs`, `./documentation` |
| `global` | Install DocFX as global tool if needed | ❌ No | `"true"` | `true`, `false` |
| `filter` | Path to filter configuration file | ❌ No | `""` | `filterConfig.yml`, `api-filter.yml` |
| `force` | Force rebuild of metadata | ❌ No | `"false"` | `true`, `false` |
| `preserve-raw-inline-comments` | Preserve raw inline comments | ❌ No | `"false"` | `true`, `false` |
| `disable-git-features` | Disable Git-based features | ❌ No | `"false"` | `true`, `false` |
| `disable-default-filter` | Disable default API filters | ❌ No | `"false"` | `true`, `false` |
| `name-for-cref` | Name format for cross-references | ❌ No | `""` | `NamespaceName`, `Qualified` |
| `should-skip-markup` | Skip markup processing | ❌ No | `"false"` | `true`, `false` |
| `raw` | Output raw model data | ❌ No | `"false"` | `true`, `false` |
| `show-summary` | Display action summary | ❌ No | `"false"` | `true`, `false` |

## 📤 Outputs

| Output | Description | Type | Example |
|--------|-------------|------|---------|
| `exit-code` | Exit code of the DocFX command | `string` | `0`, `1` |
| `executed-command` | Full command that was executed | `string` | `dotnet tool run DocFX metadata docfx.json` |
| `output-path` | Path to the generated metadata | `string` | `./docs/api` |
| `files-generated` | Number of metadata files generated | `string` | `42` |
| `processing-time` | Processing duration in seconds | `string` | `12.5` |

## 🔗 Related Actions

| Action | Purpose | Repository |
|--------|---------|------------|
| 📚 **dotnet-docfx-build** | Build documentation sites | `laerdal/github_actions/dotnet-docfx-build` |
| 📄 **dotnet-docfx-pdf** | Generate PDF documentation | `laerdal/github_actions/dotnet-docfx-pdf` |
| 🔧 **dotnet-tool-install** | Install .NET tools | `laerdal/github_actions/dotnet-tool-install` |
| 🚀 **dotnet** | Execute .NET CLI commands | `laerdal/github_actions/dotnet` |

## 💡 Examples

### Multiple Project Processing

```yaml
- name: "Generate metadata for all projects"
  uses: laerdal/github_actions/dotnet-docfx-metadata@main
  with:
    config: "docfx.json"
    projects: "./src/**/*.csproj"
    output: "./api"

- name: "Generate metadata for specific project"
  uses: laerdal/github_actions/dotnet-docfx-metadata@main
  with:
    projects: "./src/MyLibrary/MyLibrary.csproj"
    output: "./docs/MyLibrary/api"
```

### Custom Filtering

```yaml
- name: "Generate filtered metadata"
  uses: laerdal/github_actions/dotnet-docfx-metadata@main
  with:
    config: "docfx.json"
    filter: "./docs/api-filter.yml"
    disable-default-filter: "true"
    preserve-raw-inline-comments: "true"
```

### Matrix Generation for Multiple Frameworks

```yaml
strategy:
  matrix:
    framework: ["net6.0", "net8.0"]

steps:
  - name: "Generate metadata for ${{ matrix.framework }}"
    uses: laerdal/github_actions/dotnet-docfx-metadata@main
    with:
      config: "docfx-${{ matrix.framework }}.json"
      output: "./api/${{ matrix.framework }}"
```

### Debug and Development

```yaml
- name: "Generate debug metadata"
  uses: laerdal/github_actions/dotnet-docfx-metadata@main
  with:
    config: "docfx.json"
    log-level: "diagnostic"
    log-file: "./debug/metadata-generation.json"
    raw: "true"
    force: "true"
```

## 📊 Log Levels

| Level | Description | Use Case |
|-------|-------------|----------|
| `quiet` | Minimal output | Production builds |
| `minimal` | Essential information only | CI/CD pipelines |
| `info` | Standard information | Default builds |
| `verbose` | Detailed processing information | Debugging |
| `diagnostic` | Maximum verbosity | Troubleshooting |

## 🔧 API Filter Configuration

### Filter Configuration File (api-filter.yml)

```yaml
apiRules:
- include:
    uidRegex: ^MyNamespace\.Public
- exclude:
    uidRegex: ^MyNamespace\.Internal
- exclude:
    hasAttribute:
      uid: System.ObsoleteAttribute

attributeRules:
- exclude:
    hasAttribute:
      uid: System.ComponentModel.EditorBrowsableAttribute
      ctorArguments:
      - System.ComponentModel.EditorBrowsableState.Never
```

### Common Filter Patterns

```yaml
# Exclude internal APIs
- exclude:
    uidRegex: \.Internal\.

# Include only public classes
- include:
    uidRegex: ^MyCompany\.MyProduct\..*
    type: Class

# Exclude test assemblies
- exclude:
    uidRegex: \.Tests?\.
```

## 🐛 Troubleshooting

### Common Issues

#### DocFX Tool Not Found

**Problem**: DocFX global tool is not installed

**Solution**: Ensure `global: "true"` (default) or install manually:

```yaml
- name: "Install DocFX"
  uses: laerdal/github_actions/dotnet-tool-install@main
  with:
    tool-name: "docfx"
    global: "true"
```

#### Project Files Not Found

**Problem**: Specified projects pattern doesn't match any files

**Solution**: Verify the project pattern:

```yaml
- name: "List matching projects"
  run: find . -name "*.csproj" -type f

- name: "Generate metadata"
  uses: laerdal/github_actions/dotnet-docfx-metadata@main
  with:
    projects: "./src/**/*.csproj"
```

#### Compilation Errors

**Problem**: Source code compilation fails during metadata extraction

**Solution**: Ensure projects can be built:

```yaml
- name: "Restore dependencies"
  uses: laerdal/github_actions/dotnet@main
  with:
    command: "restore"

- name: "Build projects"
  uses: laerdal/github_actions/dotnet@main
  with:
    command: "build"
    configuration: "Release"

- name: "Generate metadata"
  uses: laerdal/github_actions/dotnet-docfx-metadata@main
  with:
    config: "docfx.json"
```

#### Missing XML Documentation

**Problem**: Limited or no API documentation in metadata

**Solution**: Enable XML documentation generation:

```xml
<!-- In your .csproj file -->
<PropertyGroup>
  <GenerateDocumentationFile>true</GenerateDocumentationFile>
  <DocumentationFile>bin\$(Configuration)\$(TargetFramework)\$(AssemblyName).xml</DocumentationFile>
</PropertyGroup>
```

### Debug Tips

1. **Enable Diagnostic Logging**: Set `log-level: "diagnostic"`
2. **Save Processing Logs**: Use `log-file` to capture detailed logs
3. **Force Regeneration**: Use `force: "true"` to rebuild metadata
4. **Raw Output**: Use `raw: "true"` to see internal processing data

## 📝 Requirements

- GitHub Actions runner (Windows, Linux, or macOS)
- .NET SDK installed (use `actions/setup-dotnet`)
- Valid .NET projects with source code
- Optional: DocFX configuration file (docfx.json)

## 🔧 Advanced Features

### Custom Configuration

```yaml
- name: "Generate with custom config"
  uses: laerdal/github_actions/dotnet-docfx-metadata@main
  with:
    config: "custom-docfx.json"
    name-for-cref: "Qualified"
    preserve-raw-inline-comments: "true"
    disable-git-features: "true"
```

### Multi-Target Framework Support

```yaml
- name: "Generate metadata for multi-target"
  uses: laerdal/github_actions/dotnet-docfx-metadata@main
  with:
    projects: "./src/MultiTarget.csproj"
    output: "./docs/api/multitarget"
    force: "true"
```

## 📄 License

This action is part of the GitHub Actions collection by Francois Raminosona.

---

> 💡 **Tip**: For complete documentation workflows, combine this action with our build and PDF generation actions in the [Related Actions](#-related-actions) section.
