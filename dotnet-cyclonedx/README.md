# 📄 CycloneDX SBOM Generator Action

A comprehensive GitHub Action for generating Software Bill of Materials (SBOM) files using the CycloneDX .NET Global Tool with extensive configuration options and cross-platform support.

## ✨ Features

- 📄 **SBOM Generation** - Creates CycloneDX-compliant Software Bill of Materials
- 🔧 **Multiple Formats** - Supports XML, JSON, and UnsafeJSON output formats
- 🎯 **Smart Detection** - Handles .sln, .csproj, packages.config, and directory scanning
- 🔍 **GitHub Integration** - License resolution using GitHub API
- 📦 **Dependency Management** - Excludes dev/test dependencies with filtering options
- 🛡️ **Security-First** - Automatic masking of sensitive tokens and passwords
- ⚡ **Performance Optimized** - Configurable timeouts and restore options
- 🌐 **Cross-Platform** - Works on Windows, Linux, and macOS runners

## 🚀 Basic Usage

Minimal configuration to generate an SBOM:

```yaml
- name: "Generate SBOM"
  uses: framinosona/github_actions/dotnet-cyclonedx@main
  with:
    path: "./src/MyProject.csproj"
```

```yaml
- name: "Generate JSON SBOM"
  uses: framinosona/github_actions/dotnet-cyclonedx@main
  with:
    path: "./MySolution.sln"
    output-format: "Json"
```

```yaml
- name: "Generate SBOM for entire directory"
  uses: framinosona/github_actions/dotnet-cyclonedx@main
  with:
    working-directory: "./src"
    recursive: "true"
```

## 🔧 Advanced Usage

Full configuration with all available options:

```yaml
- name: "Advanced SBOM generation"
  uses: framinosona/github_actions/dotnet-cyclonedx@main
  with:
    path: "./src/MyApp/MyApp.csproj"
    working-directory: "./backend"
    framework: "net8.0"
    runtime: "linux-x64"
    output: "./sbom"
    filename: "software-bom.json"
    output-format: "Json"
    exclude-dev: "true"
    exclude-test-projects: "true"
    recursive: "true"
    enable-github-licenses: "true"
    github-bearer-token: "${{ secrets.GITHUB_TOKEN }}"
    set-name: "MyApplication"
    set-version: "1.2.3"
    set-type: "Application"
    exclude-filter: "TestFramework@1.0.0,MockLibrary@2.1.0"
    dotnet-command-timeout: "600000"
    global: "true"
    show-summary: "true"
```

## 🔐 Permissions Required

This action requires standard repository permissions:

```yaml
permissions:
  contents: read  # Required to checkout repository code
```

For GitHub license resolution, add:

```yaml
permissions:
  contents: read
  metadata: read  # Optional: for enhanced GitHub license resolution
```

> **Note**: When using `github-bearer-token`, the `GITHUB_TOKEN` secret provides sufficient permissions for license resolution.

## 🏗️ CI/CD Example

Complete workflow for .NET SBOM generation:

```yaml
name: "SBOM Generation Pipeline"

on:
  push:
    branches: ["main", "develop"]
  pull_request:
    branches: ["main"]

permissions:
  contents: read
  metadata: read

jobs:
  generate-sbom:
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

      - name: "📄 Generate SBOM"
        id: generate-sbom
        uses: framinosona/github_actions/dotnet-cyclonedx@main
        with:
          path: "./src/MyApp.sln"
          output: "./artifacts/sbom"
          output-format: "Json"
          filename: "software-bill-of-materials.json"
          exclude-dev: "true"
          exclude-test-projects: "true"
          enable-github-licenses: "true"
          github-bearer-token: "${{ secrets.GITHUB_TOKEN }}"
          set-name: "${{ github.repository }}"
          set-version: "${{ github.ref_name }}"
          show-summary: "true"

      - name: "📤 Upload SBOM artifact"
        uses: actions/upload-artifact@v4
        with:
          name: "software-bill-of-materials"
          path: ${{ steps.generate-sbom.outputs.sbom-path }}

      - name: "🔍 Validate SBOM generation"
        run: |
          echo "SBOM generated: ${{ steps.generate-sbom.outputs.is-sbom-generated }}"
          echo "SBOM location: ${{ steps.generate-sbom.outputs.sbom-path }}"
          ls -la ${{ steps.generate-sbom.outputs.sbom-path }}
```

## 📋 Inputs

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `path` | Path to .sln, .csproj, packages.config file or directory | ❌ No | `""` | `./src/MyProject.csproj` |
| `working-directory` | Working directory for command execution | ❌ No | `"."` | `./backend` |
| `framework` | Target framework to use | ❌ No | `""` | `net8.0`, `net6.0` |
| `runtime` | Target runtime identifier | ❌ No | `""` | `win-x64`, `linux-x64` |
| `output` | Directory to write the SBOM | ❌ No | `""` | `./sbom`, `./artifacts` |
| `filename` | Custom filename for the SBOM | ❌ No | `""` | `software-bom.xml`, `app-sbom.json` |
| `output-format` | SBOM output format | ❌ No | `"Auto"` | `Auto`, `Json`, `UnsafeJson`, `Xml` |
| `exclude-dev` | Exclude development dependencies | ❌ No | `"false"` | `true`, `false` |
| `exclude-test-projects` | Exclude test projects | ❌ No | `"false"` | `true`, `false` |
| `recursive` | Recursively scan project references | ❌ No | `"false"` | `true`, `false` |
| `no-serial-number` | Omit serial number from SBOM | ❌ No | `"false"` | `true`, `false` |
| `enable-github-licenses` | Enable GitHub license resolution | ❌ No | `"false"` | `true`, `false` |
| `github-username` | GitHub username for license resolution | ❌ No | `""` | `myusername` |
| `github-token` | GitHub personal access token | ❌ No | `""` | `${{ secrets.GITHUB_TOKEN }}` |
| `github-bearer-token` | GitHub bearer token (recommended) | ❌ No | `""` | `${{ secrets.GITHUB_TOKEN }}` |
| `url` | Alternative NuGet repository URL | ❌ No | `""` | `https://nuget.example.com/v3/index.json` |
| `baseUrlUsername` | Alternative NuGet repository username | ❌ No | `""` | `nuget-user` |
| `baseUrlUserPassword` | Alternative NuGet repository password | ❌ No | `""` | `${{ secrets.NUGET_PASSWORD }}` |
| `isBaseUrlPasswordClearText` | NuGet password is cleartext | ❌ No | `"false"` | `true`, `false` |
| `disable-package-restore` | Disable package restore | ❌ No | `"false"` | `true`, `false` |
| `disable-hash-computation` | Disable hash computation | ❌ No | `"false"` | `true`, `false` |
| `dotnet-command-timeout` | Command timeout in milliseconds | ❌ No | `"300000"` | `600000`, `900000` |
| `include-project-references` | Include project references as components | ❌ No | `"false"` | `true`, `false` |
| `set-name` | Override BOM component name | ❌ No | `""` | `MyApplication` |
| `set-version` | Override BOM component version | ❌ No | `""` | `1.0.0`, `2.1.3` |
| `set-type` | Override BOM component type | ❌ No | `"Application"` | `Library`, `Framework` |
| `set-nuget-purl` | Override BOM ref and PURL as NuGet package | ❌ No | `"false"` | `true`, `false` |
| `exclude-filter` | Dependencies to exclude (name@version) | ❌ No | `""` | `TestLib@1.0.0,MockFramework@2.0.0` |
| `base-intermediate-output-path` | Custom build environment folder | ❌ No | `""` | `./custom-obj` |
| `import-metadata-path` | Metadata template file path | ❌ No | `""` | `./templates/metadata.json` |
| `global` | Install CycloneDX global tool if needed | ❌ No | `"true"` | `true`, `false` |
| `show-summary` | Display action summary | ❌ No | `"false"` | `true`, `false` |

## 📤 Outputs

| Output | Description | Type | Example |
|--------|-------------|------|---------|
| `exit-code` | Exit code of the CycloneDX command | `string` | `0`, `1` |
| `executed-command` | Full command that was executed | `string` | `dotnet tool run CycloneDX ./src --output-format Json` |
| `sbom-path` | Path to the generated SBOM file | `string` | `./sbom/bom.json` |
| `is-sbom-generated` | Whether SBOM was successfully generated | `string` | `true`, `false` |

## 🔗 Related Actions

| Action | Purpose | Repository |
|--------|---------|------------|
| 🚀 **dotnet** | Execute .NET CLI commands | `framinosona/github_actions/dotnet` |
| 🔧 **dotnet-tool-install** | Install .NET global tools | `framinosona/github_actions/dotnet-tool-install` |
| 🧪 **dotnet-test** | Enhanced .NET testing | `framinosona/github_actions/dotnet-test` |

## 💡 Examples

### Different Output Formats

```yaml
- name: "Generate XML SBOM"
  uses: framinosona/github_actions/dotnet-cyclonedx@main
  with:
    path: "./src/MyApp.csproj"
    output-format: "Xml"
    filename: "software-bom.xml"

- name: "Generate JSON SBOM"
  uses: framinosona/github_actions/dotnet-cyclonedx@main
  with:
    path: "./src/MyApp.csproj"
    output-format: "Json"
    filename: "software-bom.json"
```

### Multi-Project Solution

```yaml
- name: "Generate SBOM for entire solution"
  uses: framinosona/github_actions/dotnet-cyclonedx@main
  with:
    path: "./MySolution.sln"
    exclude-test-projects: "true"
    exclude-dev: "true"
    recursive: "true"
    output: "./artifacts/sbom"
```

### Framework-Specific SBOM

```yaml
strategy:
  matrix:
    framework: ["net6.0", "net8.0"]

steps:
  - name: "Generate SBOM for ${{ matrix.framework }}"
    uses: framinosona/github_actions/dotnet-cyclonedx@main
    with:
      path: "./src/MultiTarget.csproj"
      framework: ${{ matrix.framework }}
      filename: "sbom-${{ matrix.framework }}.json"
      output-format: "Json"
```

### GitHub License Resolution

```yaml
- name: "Generate SBOM with license information"
  uses: framinosona/github_actions/dotnet-cyclonedx@main
  with:
    path: "./src/MyApp.csproj"
    enable-github-licenses: "true"
    github-bearer-token: "${{ secrets.GITHUB_TOKEN }}"
    output-format: "Json"
```

### Custom NuGet Repository

```yaml
- name: "Generate SBOM from private NuGet"
  uses: framinosona/github_actions/dotnet-cyclonedx@main
  with:
    path: "./src/MyApp.csproj"
    url: "https://nuget.company.com/v3/index.json"
    baseUrlUsername: "${{ secrets.NUGET_USERNAME }}"
    baseUrlUserPassword: "${{ secrets.NUGET_PASSWORD }}"
    isBaseUrlPasswordClearText: "false"
```

### Dependency Filtering

```yaml
- name: "Generate filtered SBOM"
  uses: framinosona/github_actions/dotnet-cyclonedx@main
  with:
    path: "./src/MyApp.csproj"
    exclude-dev: "true"
    exclude-test-projects: "true"
    exclude-filter: "Microsoft.AspNetCore.App@8.0.0,System.Text.Json@7.0.0"
    output-format: "Json"
```

## 🔧 Output Format Support

| Format | Description | File Extension | Use Case |
|--------|-------------|----------------|----------|
| `Auto` | Automatically detects based on filename | `.xml` or `.json` | Default, flexible |
| `Xml` | CycloneDX XML format | `.xml` | Standards compliance |
| `Json` | CycloneDX JSON format | `.json` | API integration |
| `UnsafeJson` | JSON with relaxed escaping | `.json` | Special characters |

## 🎯 Component Types

| Type | Description | Example Use Case |
|------|-------------|------------------|
| `Application` | Standalone application | Web apps, desktop apps |
| `Library` | Reusable library | NuGet packages, class libraries |
| `Framework` | Development framework | ASP.NET Core, Entity Framework |
| `Container` | Container image | Docker containers |
| `Operating_System` | OS components | Linux distributions |
| `Device` | Hardware device | IoT devices |
| `Firmware` | Device firmware | Embedded systems |

## 🐛 Troubleshooting

### Common Issues

#### CycloneDX Tool Not Found

**Problem**: CycloneDX global tool is not installed

**Solution**: Ensure `global: "true"` (default) or install manually:

```yaml
- name: "Install CycloneDX"
  run: dotnet tool install --global CycloneDX
```

#### Project File Not Found

**Problem**: Specified path does not exist

**Solution**: Verify the path and file existence:

```yaml
- name: "Check project file"
  run: ls -la ./src/MyProject.csproj
```

#### GitHub API Rate Limiting

**Problem**: License resolution fails due to rate limits

**Solution**: Provide authentication token:

```yaml
github-bearer-token: "${{ secrets.GITHUB_TOKEN }}"
enable-github-licenses: "true"
```

#### Large Project Timeouts

**Problem**: Command times out on large solutions

**Solution**: Increase timeout value:

```yaml
dotnet-command-timeout: "900000"  # 15 minutes
```

#### Missing Dependencies in SBOM

**Problem**: Some dependencies not included

**Solution**: Ensure proper restore and disable selective restore:

```yaml
disable-package-restore: "false"
recursive: "true"
```

### Debug Tips

1. **Enable Summary**: Set `show-summary: "true"` for detailed information
2. **Check Outputs**: Use the `sbom-path` output to verify file location
3. **Validate Format**: Ensure the generated SBOM is valid CycloneDX
4. **Review Exclusions**: Check if dependencies are excluded by filters

## 📝 Requirements

- GitHub Actions runner (Windows, Linux, or macOS)
- .NET SDK installed (use `actions/setup-dotnet`)
- Valid .NET project, solution, or packages.config structure
- CycloneDX global tool (auto-installed by default)

## 🔒 Security Considerations

- **Token Masking**: Sensitive tokens are automatically masked in logs
- **Private Repositories**: Use appropriate authentication for private NuGet feeds
- **License Data**: GitHub license resolution requires minimal read permissions
- **SBOM Content**: Review generated SBOMs before publishing to ensure no sensitive data

## 📋 SBOM Standards Compliance

This action generates CycloneDX-compliant SBOMs that meet:

- **CycloneDX Specification**: Follows official CycloneDX schema
- **SPDX Compatibility**: Can be converted to SPDX format
- **NTIA Minimum Elements**: Includes required SBOM components
- **Supply Chain Security**: Supports vulnerability scanning integration

## 📄 License

This action is part of the GitHub Actions collection by Francois Raminosona.

---

> 💡 **Tip**: For complete SBOM workflows, combine this action with our signing and publishing actions in the [Related Actions](#-related-actions) section.
