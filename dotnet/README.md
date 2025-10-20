# 🚀 .NET Command Action

A comprehensive GitHub Action for executing .NET CLI commands with intelligent argument parsing, automatic verbosity handling, and cross-platform support.

## ✨ Features

- 🎯 **Smart Command Execution** - Automatic detection of supported options per .NET command
- 🔧 **Auto-Verbosity Detection** - Adjusts verbosity based on debug settings
- 📋 **Flexible Arguments** - String and YAML array support for complex scenarios
- ✅ **Comprehensive Validation** - Input validation with helpful error messages
- ⚡ **Performance Optimized** - Cached command support maps
- 🛡️ **Cross-Platform** - Works on Windows, Linux, and macOS runners
- 📊 **Detailed Reporting** - Rich summaries with execution metrics

## 🚀 Basic Usage

Minimal configuration to get started:

```yaml
- name: "Build project"
  uses: framinosona/github_actions/dotnet@main
  with:
    command: "build"
```

```yaml
- name: "Run tests"
  uses: framinosona/github_actions/dotnet@main
  with:
    command: "test"
```

```yaml
- name: "Restore packages"
  uses: framinosona/github_actions/dotnet@main
  with:
    command: "restore"
```

## 🔧 Advanced Usage

Full configuration with all available options:

```yaml
- name: "Advanced .NET build and publish"
  uses: framinosona/github_actions/dotnet@main
  with:
    command: "publish"
    path: "./src/MyApp/MyApp.csproj"
    working-directory: "./backend"
    configuration: "Release"
    framework: "net8.0"
    runtime: "linux-x64"
    arch: "x64"
    output: "./dist"
    verbosity: "detailed"
    nologo: "true"
    no-restore: "false"
    no-build: "false"
    show-summary: "true"
    arguments: |
      --self-contained
      --no-dependencies
      /p:PublishSingleFile=true
      /p:IncludeNativeLibrariesForSelfExtract=true
```

## 🔐 Permissions Required

This action requires standard repository permissions:

```yaml
permissions:
  contents: read  # Required to checkout repository code
```

> **Note**: No additional permissions are required as this action only executes .NET CLI commands on the runner.

## 🏗️ CI/CD Example

Complete workflow for .NET application:

```yaml
name: "CI/CD Pipeline"

on:
  push:
    branches: ["main", "develop"]
  pull_request:
    branches: ["main"]

permissions:
  contents: read

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
      - name: "📥 Checkout repository"
        uses: actions/checkout@v4

      - name: "🔧 Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: "📦 Restore dependencies"
        uses: framinosona/github_actions/dotnet@main
        with:
          command: "restore"
          verbosity: "minimal"

      - name: "🏗️ Build solution"
        uses: framinosona/github_actions/dotnet@main
        with:
          command: "build"
          configuration: "Release"
          no-restore: "true"
          show-summary: "true"

      - name: "🧪 Run tests"
        uses: framinosona/github_actions/dotnet@main
        with:
          command: "test"
          configuration: "Release"
          no-build: "true"
          arguments: "--collect:\"XPlat Code Coverage\" --logger trx"

      - name: "🚀 Publish application"
        if: github.ref == 'refs/heads/main'
        uses: framinosona/github_actions/dotnet@main
        with:
          command: "publish"
          path: "./src/WebApp/WebApp.csproj"
          configuration: "Release"
          runtime: "linux-x64"
          output: "./publish"
          arguments: "--self-contained"
```

## 📋 Inputs

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `command` | .NET command to execute | ✅ Yes | - | `build`, `test`, `restore`, `publish` |
| `path` | Path to project/solution file or directory | ❌ No | `""` | `./src/MyProject.csproj` |
| `arguments` | Additional command arguments | ❌ No | `""` | `--no-dependencies` |
| `working-directory` | Working directory for command execution | ❌ No | `"."` | `./backend` |
| `verbosity` | Force specific verbosity level | ❌ No | `""` | `quiet`, `minimal`, `normal`, `detailed`, `diagnostic` |
| `nologo` | Suppress Microsoft logo and startup info | ❌ No | `"true"` | `true`, `false` |
| `no-restore` | Skip automatic restore | ❌ No | `"false"` | `true`, `false` |
| `no-build` | Skip building before running | ❌ No | `"false"` | `true`, `false` |
| `configuration` | Build configuration | ❌ No | `"Release"` | `Debug`, `Release` |
| `framework` | Target framework | ❌ No | `""` | `net8.0`, `net6.0` |
| `runtime` | Target runtime identifier | ❌ No | `""` | `win-x64`, `linux-x64`, `osx-arm64` |
| `arch` | Target architecture | ❌ No | `""` | `x86`, `x64`, `arm`, `arm64` |
| `output` | Output directory path | ❌ No | `""` | `./bin`, `./publish` |
| `show-summary` | Display action summary | ❌ No | `"false"` | `true`, `false` |

## 📤 Outputs

| Output | Description | Type | Example |
|--------|-------------|------|---------|
| `exit-code` | Exit code of the executed command | `string` | `0`, `1` |
| `executed-command` | Full command that was executed | `string` | `dotnet build --configuration Release` |

## 🔗 Related Actions

| Action | Purpose | Repository |
|--------|---------|------------|
| 🧪 **dotnet-test** | Enhanced .NET testing with coverage | `framinosona/github_actions/dotnet-test` |
| 🔧 **dotnet-tool-install** | Install .NET tools | `framinosona/github_actions/dotnet-tool-install` |
| 📦 **dotnet-nuget-upload** | Upload NuGet packages | `framinosona/github_actions/dotnet-nuget-upload` |
| 📚 **dotnet-docfx-build** | Generate documentation | `framinosona/github_actions/dotnet-docfx-build` |
| 🔍 **dotnet-cyclonedx** | Generate SBOM files | `framinosona/github_actions/dotnet-cyclonedx` |

## 💡 Examples

### Building Multiple Configurations

```yaml
- name: "Build Debug"
  uses: framinosona/github_actions/dotnet@main
  with:
    command: "build"
    configuration: "Debug"

- name: "Build Release"
  uses: framinosona/github_actions/dotnet@main
  with:
    command: "build"
    configuration: "Release"
```

### Multi-Framework Testing

```yaml
strategy:
  matrix:
    framework: ["net6.0", "net8.0"]

steps:
  - name: "Test ${{ matrix.framework }}"
    uses: framinosona/github_actions/dotnet@main
    with:
      command: "test"
      framework: ${{ matrix.framework }}
```

### Cross-Platform Publishing

```yaml
strategy:
  matrix:
    runtime: ["win-x64", "linux-x64", "osx-arm64"]

steps:
  - name: "Publish for ${{ matrix.runtime }}"
    uses: framinosona/github_actions/dotnet@main
    with:
      command: "publish"
      runtime: ${{ matrix.runtime }}
      output: "./dist/${{ matrix.runtime }}"
```

### Complex Arguments with YAML

```yaml
- name: "Create NuGet package"
  uses: framinosona/github_actions/dotnet@main
  with:
    command: "pack"
    path: "./src/MyLibrary/MyLibrary.csproj"
    configuration: "Release"
    output: "./packages"
    arguments: |
      --include-symbols
      --include-source
      /p:PackageVersion=1.0.0
      /p:Authors="Framinosona"
```

## 🔧 Command Support Matrix

| Command | Verbosity | Configuration | Framework | Runtime | No-Restore | No-Build | Output |
|---------|-----------|---------------|-----------|---------|------------|----------|--------|
| `build` | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ |
| `restore` | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| `test` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| `publish` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `pack` | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ |
| `run` | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| `clean` | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

## 🐛 Troubleshooting

### Common Issues

#### .NET SDK Not Found

**Problem**: `dotnet` command not available

**Solution**: Add .NET setup before this action:

```yaml
- name: "Setup .NET"
  uses: actions/setup-dotnet@v4
  with:
    dotnet-version: "8.0.x"
```

#### Invalid Path Error

**Problem**: Specified path does not exist

**Solution**: Verify file/directory exists:

```yaml
- name: "Check path exists"
  run: ls -la ./src/MyProject.csproj
```

#### Build Failures

**Problem**: Build errors with complex arguments

**Solution**: Use YAML array format for complex arguments:

```yaml
arguments: |
  --configuration Release
  --runtime linux-x64
  --self-contained
```

### Debug Tips

1. **Enable Debug Mode**: Set `ACTIONS_STEP_DEBUG: true`
2. **Use Diagnostic Verbosity**: Set `verbosity: "diagnostic"`
3. **Check Executed Command**: Use the `executed-command` output
4. **Enable Summary**: Set `show-summary: "true"`

## 📝 Requirements

- GitHub Actions runner (Windows, Linux, or macOS)
- .NET SDK installed (use `actions/setup-dotnet`)
- Valid .NET project or solution structure
- Bash shell (available on all runners)

## 📄 License

This action is part of the GitHub Actions collection by Francois Raminosona.

---

> 💡 **Tip**: For more complex .NET workflows, check out our specialized actions in the [Related Actions](#-related-actions) section.
