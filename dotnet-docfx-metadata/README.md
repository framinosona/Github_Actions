# 📋 DocFX Metadata Extraction Action

Extract YAML metadata files from .NET source code using the DocFX .NET Global Tool.

## Features

- 📋 **API Metadata Extraction** - Generate YAML files from .NET source code
- 🔍 **Flexible Filtering** - Support for custom API filters and configurations
- 📊 **Multiple Output Formats** - Support for mref, markdown, and apiPage formats
- 📂 **Layout Customization** - Configurable namespace and member layouts
- 🔧 **MSBuild Integration** - Support for MSBuild properties and project settings
- 📈 **Detailed Analytics** - API counts, file metrics, and execution statistics

## Usage

### Basic Usage

Extract metadata using default `docfx.json` configuration:

```yaml
- name: Extract API Metadata
  uses: ./dotnet-docfx-metadata
  with:
    config: 'docfx.json'
```

### Advanced Usage

```yaml
- name: Extract Metadata with Custom Settings
  uses: ./dotnet-docfx-metadata
  with:
    config: 'docs/docfx.json'
    output: 'api-metadata'
    output-format: 'markdown'
    namespace-layout: 'Nested'
    member-layout: 'SeparatePages'
    filter: 'api-filter.yml'
    property: 'Configuration=Release;Platform=AnyCPU'
    log-level: 'verbose'
```

## Inputs

| Input | Description | Default | Example |
|-------|-------------|---------|---------|
| `config` | Path to the docfx configuration file | `docfx.json` | `docs/docfx.json` |
| `output` | Output base directory | `api` | `api-metadata` |
| `log-level` | Log level (error, warning, info, verbose, diagnostic) | `info` | `verbose` |
| `log-file` | Save structured JSON log to specified file | `''` | `metadata.log.json` |
| `verbose` | Enable verbose logging | `false` | `true` |
| `warnings-as-errors` | Treat warnings as errors | `false` | `true` |
| `should-skip-markup` | Skip markup of triple slash comments | `false` | `true` |
| `output-format` | Output type (mref, markdown, apiPage) | `mref` | `markdown` |
| `filter` | Filter config file path | `''` | `api-filter.yml` |
| `global-namespace-id` | Name for the global namespace | `''` | `GlobalNamespace` |
| `property` | MSBuild properties (semicolon-separated) | `''` | `Configuration=Release;Platform=AnyCPU` |
| `disable-git-features` | Disable Git information fetching | `false` | `true` |
| `disable-default-filter` | Disable default API filter | `false` | `true` |
| `no-restore` | Skip dotnet restore | `false` | `true` |
| `namespace-layout` | Namespace layout (Flattened, Nested) | `Flattened` | `Nested` |
| `member-layout` | Member layout (SamePage, SeparatePages) | `SamePage` | `SeparatePages` |
| `use-clr-type-names` | Use CLR type names instead of language aliases | `false` | `true` |
| `docfx-version` | Specific DocFX version to install | `''` | `2.70.0` |
| `show-summary` | Show action summary | `true` | `false` |

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `output-path` | Full path to generated metadata directory | `/path/to/api-metadata` |
| `config-path` | Path to DocFX configuration file used | `/path/to/docfx.json` |
| `yaml-files` | Number of YAML files generated | `25` |
| `api-count` | Number of API items extracted | `150` |
| `output-size` | Total output directory size in bytes | `512000` |
| `execution-time` | Extraction time in seconds | `30` |

## Examples

### Complete API Documentation Pipeline

```yaml
name: Generate API Documentation

on:
  push:
    branches: [ main ]

jobs:
  api-docs:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '8.0.x'

    - name: Extract API Metadata
      id: metadata
      uses: ./dotnet-docfx-metadata
      with:
        config: 'docfx.json'
        output: 'api'
        output-format: 'mref'
        namespace-layout: 'Nested'
        member-layout: 'SeparatePages'

    - name: Build Documentation
      uses: ./dotnet-docfx-build
      with:
        config: 'docfx.json'
        output: 'docs-site'

    - name: Report Results
      run: |
        echo "Extracted ${{ steps.metadata.outputs.api-count }} API items"
        echo "Generated ${{ steps.metadata.outputs.yaml-files }} YAML files"
```

### Filtered API Extraction

```yaml
- name: Extract Public APIs Only
  uses: ./dotnet-docfx-metadata
  with:
    config: 'docfx.json'
    output: 'public-api'
    filter: 'public-api-filter.yml'
    disable-default-filter: 'false'  # Keep default public/protected filter
    should-skip-markup: 'false'      # Include XML doc comments
```

### Release Build Metadata

```yaml
- name: Extract Release Metadata
  uses: ./dotnet-docfx-metadata
  with:
    config: 'docfx.json'
    output: 'release-api'
    property: 'Configuration=Release;Platform=AnyCPU;DefineConstants=RELEASE'
    no-restore: 'false'
    warnings-as-errors: 'true'
    log-level: 'warning'
```

### Markdown Output for Wiki

```yaml
- name: Generate Wiki Documentation
  uses: ./dotnet-docfx-metadata
  with:
    config: 'docfx.json'
    output: 'wiki-docs'
    output-format: 'markdown'
    namespace-layout: 'Flattened'
    use-clr-type-names: 'false'  # Use language aliases (int vs Int32)
```

## Requirements

### Prerequisites

- .NET SDK (any supported version)
- .NET projects with XML documentation enabled
- Valid `docfx.json` configuration file

### Dependencies

- **DocFX Global Tool** - Automatically installed by the action

### Supported Platforms

- ✅ Linux (ubuntu-latest)
- ✅ macOS (macos-latest)
- ✅ Windows (windows-latest)

## Configuration

### DocFX Configuration for Metadata

Your `docfx.json` should include metadata configuration:

```json
{
  "metadata": [
    {
      "src": [
        {
          "files": ["**/*.csproj"],
          "exclude": ["**/bin/**", "**/obj/**", "Tests/**"]
        }
      ],
      "dest": "api",
      "properties": {
        "TargetFramework": "net8.0"
      },
      "disableGitFeatures": false,
      "disableDefaultFilter": false
    }
  ]
}
```

### API Filter Configuration

Create an `api-filter.yml` file to control which APIs are included:

```yaml
apiRules:
- include:
    uidRegex: ^MyNamespace\.Public
- exclude:
    uidRegex: ^MyNamespace\.Internal
- include:
    type: Class
    hasAttribute:
      uid: System.ComponentModel.PublicAPIAttribute
```

### Project Configuration

Enable XML documentation in your `.csproj` files:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
    <DocumentationFile>bin\$(Configuration)\$(TargetFramework)\$(AssemblyName).xml</DocumentationFile>
  </PropertyGroup>
</Project>
```

## Troubleshooting

### Common Issues

#### ❌ No Metadata Generated

```
0 YAML files generated, 0 API items extracted
```

**Solutions:**
1. Ensure your projects have XML documentation enabled
2. Check that project files are correctly referenced in `docfx.json`
3. Verify your filter configuration isn't too restrictive

#### ❌ Build Errors During Metadata Extraction

```
Error: Metadata extraction failed
```

**Solutions:**
1. Check MSBuild properties:
   ```yaml
   property: 'Configuration=Release;Platform=AnyCPU'
   ```

2. Ensure projects can build:
   ```yaml
   no-restore: 'false'  # Allow dotnet restore
   ```

3. Enable verbose logging:
   ```yaml
   log-level: 'verbose'
   verbose: 'true'
   ```

#### ❌ Filter Configuration Issues

**Solutions:**
1. Validate your filter YAML syntax
2. Test with default filters first:
   ```yaml
   disable-default-filter: 'false'
   ```

3. Use simpler UID patterns initially

#### ❌ Performance Issues

**Solutions:**
1. Disable Git features for large repos:
   ```yaml
   disable-git-features: 'true'
   ```

2. Use targeted project selection in `docfx.json`

### Debug Mode

Enable comprehensive debugging:

```yaml
- name: Debug Metadata Extraction
  uses: ./dotnet-docfx-metadata
  with:
    config: 'docfx.json'
    log-level: 'diagnostic'
    log-file: 'metadata-debug.log.json'
    verbose: 'true'
    disable-default-filter: 'true'  # See all APIs
```

### Validation

Validate extraction before building:

```yaml
- name: Validate Metadata Extraction
  id: validate
  uses: ./dotnet-docfx-metadata
  with:
    config: 'docfx.json'
    output: 'temp-api'
    log-level: 'verbose'

- name: Check Results
  run: |
    if [ "${{ steps.validate.outputs.api-count }}" -eq "0" ]; then
      echo "Warning: No APIs extracted!"
      exit 1
    fi
```

## Contributing

When contributing to this action:

1. Follow the [Actions Guidelines](../.github/copilot-instructions.md)
2. Test with various .NET project structures
3. Ensure cross-platform compatibility
4. Update documentation for new features

## License

This action is distributed under the same license as the repository.

## Support

For issues related to:
- **DocFX metadata functionality:** Check [DocFX Metadata Documentation](https://dotnet.github.io/docfx/reference/docfx-cli-reference/docfx-metadata.html)
- **Action bugs:** Create an issue in this repository
- **GitHub Actions:** Check [GitHub Actions Documentation](https://docs.github.com/en/actions)
