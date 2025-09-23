# 📄 DocFX PDF Generation Action

Generate PDF documentation from DocFX projects using the DocFX .NET Global Tool.

## Features

- 📄 **PDF Generation** - Convert DocFX documentation projects to PDF format
- 📊 **Comprehensive Logging** - Multiple log levels with optional structured JSON output
- 🔧 **Flexible Configuration** - Support for custom docfx.json configurations
- 📈 **Detailed Analytics** - PDF counts, sizes, and execution metrics
- ✅ **Input Validation** - Comprehensive validation of all parameters

## Usage

### Basic Usage

Generate PDF from default `docfx.json` configuration:

```yaml
- name: Generate PDF Documentation
  uses: ./dotnet-docfx-pdf
  with:
    config: 'docfx.json'
```

### Advanced Usage

```yaml
- name: Generate PDF with Custom Settings
  uses: ./dotnet-docfx-pdf
  with:
    config: 'docs/docfx.json'
    output: 'pdf-output'
    log-level: 'verbose'
    warnings-as-errors: 'true'
    log-file: 'docfx-pdf.log.json'
```

## Inputs

| Input | Description | Default | Example |
|-------|-------------|---------|---------|
| `config` | Path to the docfx configuration file | `docfx.json` | `docs/docfx.json` |
| `output` | Output base directory for PDF files | `_site` | `pdf-output` |
| `log-level` | Log level (error, warning, info, verbose, diagnostic) | `info` | `verbose` |
| `log-file` | Save structured JSON log to specified file | `''` | `docfx.log.json` |
| `verbose` | Enable verbose logging | `false` | `true` |
| `warnings-as-errors` | Treat warnings as errors | `false` | `true` |
| `docfx-version` | Specific DocFX version to install | `''` | `2.70.0` |
| `show-summary` | Show action summary | `true` | `false` |

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `output-path` | Full path to generated PDF output directory | `/path/to/pdf-output` |
| `config-path` | Path to DocFX configuration file used | `/path/to/docfx.json` |
| `pdf-files` | Number of PDF files generated | `3` |
| `output-size` | Total output directory size in bytes | `2048576` |
| `execution-time` | Generation time in seconds | `45` |

## Examples

### Simple PDF Generation

```yaml
name: Generate PDF Documentation

on:
  push:
    branches: [ main ]

jobs:
  pdf:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '8.0.x'

    - name: Generate PDF Documentation
      uses: ./dotnet-docfx-pdf
      with:
        config: 'docfx.json'
        output: 'pdf-docs'

    - name: Upload PDF Artifacts
      uses: actions/upload-artifact@v4
      with:
        name: pdf-documentation
        path: pdf-docs/
```

### Production PDF Build

```yaml
- name: Generate Production PDF
  id: pdf
  uses: ./dotnet-docfx-pdf
  with:
    config: 'docfx.json'
    output: 'production-pdf'
    warnings-as-errors: 'true'
    log-level: 'warning'
    log-file: 'pdf-generation.log.json'

- name: Report PDF Generation
  run: |
    echo "Generated ${{ steps.pdf.outputs.pdf-files }} PDF files"
    echo "Total size: ${{ steps.pdf.outputs.output-size }} bytes"
    echo "Execution time: ${{ steps.pdf.outputs.execution-time }} seconds"
```

## Requirements

### Prerequisites

- .NET SDK (any supported version)
- DocFX-compatible project structure
- Valid `docfx.json` configuration file with PDF settings

### Dependencies

- **DocFX Global Tool** - Automatically installed by the action

### Supported Platforms

- ✅ Linux (ubuntu-latest)
- ✅ macOS (macos-latest)
- ✅ Windows (windows-latest)

## Configuration

### DocFX Configuration for PDF

Your `docfx.json` should include PDF-specific configuration:

```json
{
  "build": {
    "content": [
      {
        "files": ["articles/**.md", "*.md"]
      }
    ],
    "output": "_site",
    "template": ["default", "modern"]
  },
  "pdf": {
    "content": [
      {
        "files": ["articles/**.md", "*.md"]
      }
    ],
    "output": "./pdf",
    "template": ["pdf.default"]
  }
}
```

## Troubleshooting

### Common Issues

#### ❌ Configuration File Not Found

```
Error: DocFX configuration file not found: docfx.json
```

**Solution:** Ensure your `docfx.json` file exists and includes PDF configuration.

#### ❌ PDF Generation Failures

```
Error: PDF generation failed
```

**Solutions:**
1. Enable verbose logging:
   ```yaml
   log-level: 'verbose'
   verbose: 'true'
   ```

2. Check your PDF template configuration in `docfx.json`

3. Ensure all referenced content files exist

#### ❌ No PDF Files Generated

**Solutions:**
1. Verify your `docfx.json` includes a `pdf` section
2. Check that content files are properly referenced
3. Ensure PDF templates are available

### Debug Mode

Enable comprehensive debugging:

```yaml
- name: Generate PDF with Debug Info
  uses: ./dotnet-docfx-pdf
  with:
    config: 'docfx.json'
    log-level: 'diagnostic'
    log-file: 'pdf-debug.log.json'
    verbose: 'true'
```

## Contributing

When contributing to this action:

1. Follow the [Actions Guidelines](../.github/copilot-instructions.md)
2. Test with various DocFX PDF configurations
3. Ensure cross-platform compatibility
4. Update documentation for new features

## License

This action is distributed under the same license as the repository.

## Support

For issues related to:
- **DocFX PDF functionality:** Check [DocFX PDF Documentation](https://dotnet.github.io/docfx/reference/docfx-cli-reference/docfx-pdf.html)
- **Action bugs:** Create an issue in this repository
- **GitHub Actions:** Check [GitHub Actions Documentation](https://docs.github.com/en/actions)
