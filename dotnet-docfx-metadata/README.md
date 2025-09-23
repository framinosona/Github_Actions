# 📖 DocFX Generate Metadata Action

Generates YAML metadata files from source code using DocFX .NET Global Tool. This action extracts API documentation metadata from .NET projects and generates structured YAML files that can be used for documentation generation.

## Features

- 📋 Generates metadata from .NET source code
- ⚙️ Supports multiple output formats (mref, markdown, apiPage)
- 🔧 Configurable namespace and member layouts
- 📊 Comprehensive logging and error handling
- 🌐 Git integration support
- 🔍 Advanced filtering capabilities
- 📄 MSBuild property integration

## Usage

### Basic Usage

```yaml
steps:
  - name: Generate API metadata
    uses: ./dotnet-docfx-metadata
    with:
      config: 'docfx.json'
      output: 'api'
```

### Advanced Usage

```yaml
steps:
  - name: Generate API metadata with custom settings
    uses: ./dotnet-docfx-metadata
    with:
      config: 'docs/docfx.json'
      output: 'generated/api'
      output-format: 'markdown'
      namespace-layout: 'Nested'
      member-layout: 'SeparatePages'
      log-level: 'verbose'
      warnings-as-errors: 'true'
      disable-default-filter: 'false'
      property: '{"Configuration":"Release","Platform":"Any CPU"}'
      docfx-version: '2.70.0'
      show-summary: 'true'
```

### With Custom Filter

```yaml
steps:
  - name: Generate filtered metadata
    uses: ./dotnet-docfx-metadata
    with:
      config: 'docfx.json'
      output: 'api'
      filter: 'filterConfig.yml'
      global-namespace-id: 'MyProject'
      use-clr-type-names: 'true'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `config` | Path to the docfx configuration file | false | `docfx.json` |
| `output` | Specify the output base directory | false | `api` |
| `log-level` | Set log level (error, warning, info, verbose, diagnostic) | false | `info` |
| `log-file` | Save log as structured JSON to the specified file | false | `` |
| `verbose` | Set log level to verbose | false | `false` |
| `warnings-as-errors` | Treats warnings as errors | false | `false` |
| `should-skip-markup` | Skip to markup the triple slash comments | false | `false` |
| `output-format` | Specify the output type (mref, markdown, apiPage) | false | `mref` |
| `filter` | Specify the filter config file | false | `` |
| `global-namespace-id` | Specify the name to use for the global namespace | false | `` |
| `property` | MSBuild properties in JSON format | false | `` |
| `disable-git-features` | Disable fetching Git related information for articles | false | `false` |
| `disable-default-filter` | Disable the default API filter | false | `false` |
| `no-restore` | Do not run dotnet restore before building the projects | false | `false` |
| `namespace-layout` | Determines the namespace layout (Flattened, Nested) | false | `Flattened` |
| `member-layout` | Determines the member page layout (SamePage, SeparatePages) | false | `SamePage` |
| `use-clr-type-names` | Use CLR type names or language aliases | false | `false` |
| `docfx-version` | Version of DocFX tool to install | false | `` |
| `show-summary` | Whether to show the action summary | false | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `output-path` | Full path to the generated metadata output directory |
| `config-path` | Path to the DocFX configuration file used |
| `files-count` | Number of metadata files generated |
| `output-size` | Total size of the output directory in bytes |
| `output-format` | Output format used for metadata generation |

## Examples

### Basic .NET Library Documentation

```yaml
name: Generate API Documentation

on:
  push:
    branches: [ main ]

jobs:
  generate-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Generate metadata
        uses: ./dotnet-docfx-metadata
        with:
          config: 'docfx.json'
          output: 'api'
          show-summary: 'true'

      - name: Upload metadata artifacts
        uses: actions/upload-artifact@v3
        with:
          name: api-metadata
          path: api/
```

### Multi-Project Solution with Custom Settings

```yaml
name: Documentation Generation

on:
  workflow_dispatch:
    inputs:
      output-format:
        description: 'Output format'
        required: false
        default: 'mref'
        type: choice
        options:
          - mref
          - markdown
          - apiPage

jobs:
  generate-metadata:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'

      - name: Generate API metadata
        id: generate
        uses: ./dotnet-docfx-metadata
        with:
          config: 'docs/docfx.json'
          output: 'generated/api'
          output-format: ${{ github.event.inputs.output-format || 'mref' }}
          namespace-layout: 'Nested'
          member-layout: 'SeparatePages'
          log-level: 'info'
          property: '{"Configuration":"Release","TargetFramework":"net8.0"}'
          warnings-as-errors: 'true'
          show-summary: 'true'

      - name: Display results
        run: |
          echo "Generated ${{ steps.generate.outputs.files-count }} files"
          echo "Output size: ${{ steps.generate.outputs.output-size }} bytes"
          echo "Output path: ${{ steps.generate.outputs.output-path }}"
```

### With Custom Filter Configuration

```yaml
steps:
  - name: Generate filtered metadata
    uses: ./dotnet-docfx-metadata
    with:
      config: 'docfx.json'
      output: 'api'
      filter: 'docs/filterConfig.yml'
      global-namespace-id: 'MyCompany.MyProduct'
      disable-default-filter: 'true'
      use-clr-type-names: 'false'
      namespace-layout: 'Flattened'
      member-layout: 'SamePage'
```

## Requirements

- **.NET SDK**: The action requires .NET SDK to be available for building projects
- **DocFX Configuration**: A valid `docfx.json` configuration file
- **Source Code**: .NET projects with XML documentation comments
- **Git Repository**: For Git-related features (optional)

## Output Formats

### MREF Format (Default)
- Generates `.yml` and `.yaml` files
- Standard DocFX metadata format
- Used by DocFX for further processing

### Markdown Format
- Generates `.md` files
- Human-readable documentation
- Can be used directly or processed further

### API Page Format
- Generates `.json` files
- Structured API information
- Suitable for custom documentation tools

## Filter Configuration

You can use a filter configuration file to control which APIs are included:

```yaml
# filterConfig.yml
apiRules:
  - exclude:
      uidRegex: ^System\.
  - include:
      uidRegex: ^MyCompany\.
```

## MSBuild Properties

Pass MSBuild properties as JSON to control the build process:

```yaml
property: |
  {
    "Configuration": "Release",
    "Platform": "Any CPU",
    "TargetFramework": "net8.0",
    "DefineConstants": "RELEASE;DOCS"
  }
```

## Troubleshooting

### Common Issues

**Configuration file not found**
```
❌ Error: DocFX configuration file not found: docfx.json
```
- Ensure the `config` path is correct relative to the repository root
- Verify the file exists and has the correct name

**Build failures**
```
❌ Error: Failed to build project
```
- Check that all dependencies are restored (`no-restore: 'false'`)
- Verify MSBuild properties are correctly formatted
- Ensure the .NET SDK version is compatible

**No metadata generated**
```
⚠️ No metadata files were generated
```
- Check that projects have XML documentation enabled
- Verify the filter configuration isn't too restrictive
- Ensure source files contain documented APIs

**Memory issues with large projects**
- Use `log-level: 'error'` to reduce output
- Consider filtering to include only necessary APIs
- Split large solutions into multiple runs

### Debugging Tips

1. **Enable verbose logging**:
   ```yaml
   verbose: 'true'
   log-level: 'diagnostic'
   ```

2. **Save logs to file**:
   ```yaml
   log-file: 'docfx-metadata.log'
   ```

3. **Check generated files**:
   ```yaml
   show-summary: 'true'
   ```

4. **Validate configuration**:
   ```bash
   dotnet tool install -g docfx
   docfx metadata docfx.json --dry-run
   ```

## Related Actions

- **dotnet-docfx-build**: Build complete documentation sites
- **dotnet-docfx-pdf**: Generate PDF documentation
- **dotnet-tool-install**: Install .NET tools
- **dotnet**: Execute .NET CLI commands

## License

This action is part of the GitHub Actions collection by Francois Raminosona.
