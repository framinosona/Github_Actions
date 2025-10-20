# 📦 Pack .NET Project Action

A GitHub Action for packing .NET projects into NuGet packages with comprehensive configuration options and automatic package discovery.

## ✨ Features

- 📦 **NuGet Package Creation** - Pack projects and solutions into NuGet packages
- 🔍 **Automatic Package Discovery** - Automatically finds and reports generated packages
- 🎯 **Flexible Output Options** - Support for custom output directories and artifacts paths
- 🔧 **Symbol & Source Support** - Include symbol packages and source files
- 🏗️ **Build Integration** - Configurable build and restore behavior
- 📊 **Comprehensive Reporting** - Detailed summaries with package information
- 🛡️ **Cross-Platform** - Works on Windows, Linux, and macOS runners
- 📋 **Input Validation** - Thorough validation of all input parameters

## 🚀 Basic Usage

Pack a project with default settings:

```yaml
- name: "Pack project"
  id: pack
  uses: framinosona/github_actions/dotnet-pack@main
  with:
    path: "./src/MyProject.csproj"
```

Pack with custom output directory:

```yaml
- name: "Pack to directory"
  id: pack
  uses: framinosona/github_actions/dotnet-pack@main
  with:
    path: "./src/MyProject.csproj"
    output: "./packages"
```

Pack with symbols and source:

```yaml
- name: "Pack with symbols"
  id: pack
  uses: framinosona/github_actions/dotnet-pack@main
  with:
    path: "./src/MyProject.csproj"
    include-symbols: "true"
    include-source: "true"
```

## 🔧 Advanced Usage

Full configuration with all available options:

```yaml
- name: "Advanced pack"
  id: pack
  uses: framinosona/github_actions/dotnet-pack@main
  with:
    path: "./src/MyProject.csproj"
    arguments: "--property:PackageIcon=icon.png"
    working-directory: "./src"
    verbosity: "normal"
    nologo: "false"
    no-restore: "false"
    no-build: "false"
    configuration: "Release"
    output: "./packages"
    artifacts-path: "./artifacts"
    include-symbols: "true"
    include-source: "true"
    serviceable: "true"
    version-suffix: "preview"
    disable-build-servers: "false"
    use-current-runtime: "false"
    show-summary: "true"
```

## 🔐 Permissions Required

Basic permissions for packing:

```yaml
permissions:
  contents: read  # Required to checkout repository and read project files
```

## 🏗️ CI/CD Example

Complete workflow with build, pack, and upload:

```yaml
name: "Build and Pack"

on:
  push:
    branches: ["main", "release/*"]
  pull_request:
    branches: ["main"]

permissions:
  contents: read

jobs:
  build-and-pack:
    runs-on: ubuntu-latest

    steps:
      - name: "📥 Checkout repository"
        uses: actions/checkout@v4

      - name: "🔧 Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: "🔨 Build project"
        uses: framinosona/github_actions/dotnet@main
        with:
          command: "build"
          configuration: "Release"
          verbosity: "minimal"

      - name: "🧪 Run tests"
        uses: framinosona/github_actions/dotnet-test@main
        with:
          configuration: "Release"
          verbosity: "minimal"

      - name: "📦 Pack project"
        id: pack
        uses: framinosona/github_actions/dotnet-pack@main
        with:
          path: "./src/MyProject.csproj"
          configuration: "Release"
          output: "./packages"
          include-symbols: "true"
          include-source: "true"
          version-suffix: ${{ github.ref != 'refs/heads/main' && 'preview' || '' }}
          show-summary: "true"

      - name: "📤 Upload packages"
        if: steps.pack.outputs.package-count > '0'
        uses: actions/upload-artifact@v4
        with:
          name: nuget-packages
          path: ${{ steps.pack.outputs.packages }}
          retention-days: 7

      - name: "🚀 Push to NuGet"
        if: github.ref == 'refs/heads/main' && steps.pack.outputs.package-count > '0'
        uses: framinosona/github_actions/dotnet-nuget-upload@main
        with:
          packages: ${{ steps.pack.outputs.packages }}
          api-key: ${{ secrets.NUGET_API_KEY }}
```

## 📋 Inputs

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `path` | Path to the project file, solution file, or directory | ❌ No | `""` | `./src/MyProject.csproj`, `./MySolution.sln` |
| `arguments` | Additional arguments to pass to the dotnet command | ❌ No | `""` | `--property:PackageIcon=icon.png` |
| `working-directory` | Working directory for the command | ❌ No | `"."` | `./src`, `./projects` |
| `verbosity` | Force a specific verbosity level | ❌ No | `""` | `quiet`, `minimal`, `normal`, `detailed` |
| `nologo` | Suppress the Microsoft logo and startup information | ❌ No | `"true"` | `true`, `false` |
| `no-restore` | Skip automatic restore | ❌ No | `"false"` | `true`, `false` |
| `no-build` | Skip building the project before packing | ❌ No | `"false"` | `true`, `false` |
| `configuration` | Build configuration to use | ❌ No | `"Release"` | `Debug`, `Release`, `Custom` |
| `output` | Output directory to place built packages in | ❌ No | `""` | `./packages`, `./dist` |
| `artifacts-path` | The artifacts path for all output | ❌ No | `""` | `./artifacts` |
| `include-symbols` | Include packages with symbols | ❌ No | `"false"` | `true`, `false` |
| `include-source` | Include PDBs and source files | ❌ No | `"false"` | `true`, `false` |
| `serviceable` | Set the serviceable flag in the package | ❌ No | `"false"` | `true`, `false` |
| `version-suffix` | Set the $(VersionSuffix) property | ❌ No | `""` | `preview`, `beta`, `alpha` |
| `disable-build-servers` | Force ignoring persistent build servers | ❌ No | `"false"` | `true`, `false` |
| `use-current-runtime` | Use current runtime as target runtime | ❌ No | `"false"` | `true`, `false` |
| `show-summary` | Whether to show the action summary | ❌ No | `"false"` | `true`, `false` |

## 📤 Outputs

| Output | Description | Type | Example |
|--------|-------------|------|---------|
| `exit-code` | Exit code of the dotnet pack command | `string` | `0`, `1` |
| `executed-command` | The actual command that was executed | `string` | `dotnet pack --configuration Release` |
| `packages` | Semicolon-separated list of generated package files | `string` | `./packages/MyProject.1.0.0.nupkg;./packages/MyProject.1.0.0.symbols.nupkg` |
| `package-count` | Number of packages generated | `string` | `2`, `0` |
| `output-directory` | Directory where packages were generated | `string` | `./packages`, `./artifacts` |

## 🔗 Related Actions

| Action | Purpose | Repository |
|--------|---------|------------|
| 🔧 **dotnet** | Core .NET command execution | `framinosona/github_actions/dotnet` |
| 🧪 **dotnet-test** | Run .NET tests | `framinosona/github_actions/dotnet-test` |
| 📤 **dotnet-nuget-upload** | Upload packages to NuGet | `framinosona/github_actions/dotnet-nuget-upload` |
| 🔢 **generate-version** | Generate version numbers | `framinosona/github_actions/generate-version` |

## 💡 Examples

### Simple Project Pack

```yaml
- name: "Pack project"
  uses: framinosona/github_actions/dotnet-pack@main
  with:
    path: "./src/MyLibrary.csproj"
    configuration: "Release"
```

### Solution Pack with Symbols

```yaml
- name: "Pack solution with symbols"
  uses: framinosona/github_actions/dotnet-pack@main
  with:
    path: "./MySolution.sln"
    configuration: "Release"
    output: "./packages"
    include-symbols: "true"
    include-source: "true"
```

### Prerelease Package

```yaml
- name: "Pack prerelease"
  uses: framinosona/github_actions/dotnet-pack@main
  with:
    path: "./src/MyProject.csproj"
    version-suffix: "preview-${{ github.run_number }}"
    output: "./packages"
```

### Multiple Projects

```yaml
- name: "Pack multiple projects"
  strategy:
    matrix:
      project: ["./src/Core", "./src/Extensions", "./src/Tools"]
  uses: framinosona/github_actions/dotnet-pack@main
  with:
    path: ${{ matrix.project }}
    configuration: "Release"
    output: "./packages"
```

### Custom Package Properties

```yaml
- name: "Pack with custom properties"
  uses: framinosona/github_actions/dotnet-pack@main
  with:
    path: "./src/MyProject.csproj"
    arguments: |
      --property:PackageIcon=icon.png
      --property:PackageReadmeFile=README.md
      --property:RepositoryUrl=${{ github.server_url }}/${{ github.repository }}
    output: "./packages"
```

## 🎯 Package Discovery

The action automatically discovers generated packages using the following logic:

1. **Search Directory Priority**:
   - If `output` is specified, search in that directory
   - If `artifacts-path` is specified, search in that directory
   - Otherwise, search in the `working-directory`

2. **Package Types Found**:
   - Regular packages (`.nupkg`)
   - Symbol packages (`.symbols.nupkg`)
   - Source packages (with source files included)

3. **Recursive Search**: The action searches recursively in subdirectories to find all packages

## 🐛 Troubleshooting

### Common Issues

#### No Packages Generated

**Problem**: `package-count` is 0 despite successful execution

**Solutions**:

- Check if the project is packable (`<IsPackable>true</IsPackable>`)
- Verify the output directory is correct
- Ensure the project builds successfully first
- Check for MSBuild warnings about packaging

#### Missing Symbol Packages

**Problem**: Symbol packages not generated when `include-symbols: "true"`

**Solutions**:

- Ensure the project generates PDB files
- Check if the project has `<DebugType>portable</DebugType>`
- Verify the configuration supports debug symbols

#### Version Issues

**Problem**: Incorrect version in generated packages

**Solutions**:

- Use `version-suffix` for prerelease versions
- Set version properties in the project file
- Use the `generate-version` action to manage versions consistently

#### Output Directory Issues

**Problem**: Packages not found in expected location

**Solutions**:

- Verify the output directory exists and is writable
- Check if `artifacts-path` overrides `output`
- Ensure the directory path is relative to `working-directory`

## 📊 Package Analysis

The action provides detailed information about generated packages:

- **Package Count**: Total number of packages created
- **Package List**: Full paths to all generated packages
- **Output Directory**: Location where packages were created
- **Package Types**: Regular and symbol packages are identified

## 📋 Best Practices

1. **Version Management**: Use consistent versioning with the `generate-version` action
2. **Symbol Packages**: Include symbols for debugging in non-production environments
3. **Output Organization**: Use dedicated output directories for easy artifact management
4. **Build Optimization**: Skip build with `no-build: "true"` if already built
5. **Configuration Consistency**: Use the same configuration for build and pack operations

## 📝 Requirements

- GitHub Actions runner (Windows, Linux, or macOS)
- .NET SDK installed (via `actions/setup-dotnet` or pre-installed)
- Valid .NET project or solution file
- Proper project configuration for packaging

## 📄 License

This action is part of the GitHub Actions collection by Francois Raminosona.

---

> 💡 **Tip**: Combine this action with `dotnet-test` and `dotnet-nuget-upload` for complete package workflows.
