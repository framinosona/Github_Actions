# 📄 DocFX Generate PDF Action

Generates PDF documentation using DocFX .NET Global Tool. This action converts DocFX documentation projects into high-quality PDF documents suitable for offline distribution and archival purposes.

## Features

- 📋 Generates PDF from DocFX documentation projects
- ⚙️ Configurable output directory and logging
- 🔧 Support for custom DocFX configurations
- 📊 Comprehensive error handling and validation
- 🌐 Cross-platform compatibility (Windows, Linux, macOS)
- 📄 Detailed output analysis and reporting

## Usage

### Basic Usage

```yaml
steps:
  - name: Generate PDF documentation
    uses: ./dotnet-docfx-pdf
    with:
      config: 'docfx.json'
      output: '_site'
```

### Advanced Usage

```yaml
steps:
  - name: Generate PDF with custom settings
    uses: ./dotnet-docfx-pdf
    with:
      config: 'docs/docfx.json'
      output: 'pdf-output'
      log-level: 'verbose'
      warnings-as-errors: 'true'
      log-file: 'pdf-generation.log'
      docfx-version: '2.70.0'
      show-summary: 'true'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `config` | Path to the docfx configuration file | false | `docfx.json` |
| `output` | Specify the output base directory | false | `_site` |
| `log-level` | Set log level (error, warning, info, verbose, diagnostic) | false | `info` |
| `log-file` | Save log as structured JSON to the specified file | false | `` |
| `verbose` | Set log level to verbose | false | `false` |
| `warnings-as-errors` | Treats warnings as errors | false | `false` |
| `docfx-version` | Version of DocFX tool to install | false | `` |
| `show-summary` | Whether to show the action summary | false | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `output-path` | Full path to the generated PDF output directory |
| `config-path` | Path to the DocFX configuration file used |
| `pdf-files` | Comma-separated list of generated PDF files |
| `files-count` | Number of PDF files generated |
| `output-size` | Total size of the output directory in bytes |

## Examples

### Basic Documentation PDF Generation

```yaml
name: Generate PDF Documentation

on:
  push:
    branches: [ main ]
    paths: [ 'docs/**' ]

jobs:
  generate-pdf:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'

      - name: Generate PDF documentation
        uses: ./dotnet-docfx-pdf
        with:
          config: 'docfx.json'
          output: 'pdf-docs'
          show-summary: 'true'

      - name: Upload PDF artifacts
        uses: actions/upload-artifact@v3
        with:
          name: documentation-pdf
          path: pdf-docs/*.pdf
```

### Release Documentation Workflow

```yaml
name: Generate Release Documentation

on:
  release:
    types: [published]

jobs:
  generate-release-docs:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'

      - name: Generate API metadata
        uses: ./dotnet-docfx-metadata
        with:
          config: 'docs/docfx.json'
          output: 'docs/api'

      - name: Build documentation site
        uses: ./dotnet-docfx-build
        with:
          config: 'docs/docfx.json'
          output: 'docs/_site'

      - name: Generate PDF documentation
        id: pdf
        uses: ./dotnet-docfx-pdf
        with:
          config: 'docs/docfx.json'
          output: 'docs/pdf'
          log-level: 'info'
          warnings-as-errors: 'true'
          show-summary: 'true'

      - name: Attach PDF to release
        uses: actions/upload-release-asset@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          upload_url: ${{ github.event.release.upload_url }}
          asset_path: ${{ steps.pdf.outputs.pdf-files }}
          asset_name: documentation-${{ github.event.release.tag_name }}.pdf
          asset_content_type: application/pdf
```

### Multi-Version Documentation

```yaml
name: Generate Versioned PDF Documentation

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Documentation version'
        required: true
        default: 'latest'

jobs:
  generate-versioned-pdf:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Generate PDF for version
        id: generate
        uses: ./dotnet-docfx-pdf
        with:
          config: 'docs/docfx.json'
          output: 'versioned-docs/${{ github.event.inputs.version }}'
          log-level: 'verbose'
          log-file: 'pdf-${{ github.event.inputs.version }}.log'
          show-summary: 'true'

      - name: Display generation results
        run: |
          echo "Generated ${{ steps.generate.outputs.files-count }} PDF files"
          echo "Total size: ${{ steps.generate.outputs.output-size }} bytes"
          echo "Files: ${{ steps.generate.outputs.pdf-files }}"

      - name: Archive versioned documentation
        uses: actions/upload-artifact@v3
        with:
          name: docs-${{ github.event.inputs.version }}
          path: versioned-docs/${{ github.event.inputs.version }}/
          retention-days: 90
```

## Requirements

- **.NET SDK**: Required for DocFX tool installation and execution
- **DocFX Configuration**: A valid `docfx.json` configuration file
- **Documentation Content**: Existing documentation project (usually built with metadata and articles)
- **System Dependencies**: PDF generation may require additional system libraries on some platforms

## DocFX Configuration for PDF

Your `docfx.json` should include PDF-specific configuration:

```json
{
  "metadata": [
    {
      "src": [
        {
          "files": [ "**.csproj" ],
          "exclude": [ "**/bin/**", "**/obj/**" ]
        }
      ],
      "dest": "api"
    }
  ],
  "build": {
    "content": [
      {
        "files": [ "api/**.yml", "api/index.md" ]
      },
      {
        "files": [ "articles/**.md", "articles/**/toc.yml", "toc.yml", "*.md" ]
      }
    ],
    "resource": [
      {
        "files": [ "images/**" ]
      }
    ],
    "dest": "_site",
    "globalMetadataFiles": [],
    "fileMetadataFiles": [],
    "template": [
      "default",
      "modern"
    ],
    "globalMetadata": {
      "_appTitle": "My Documentation",
      "_appFooter": "© 2024 My Company"
    }
  },
  "pdf": {
    "content": [
      {
        "files": [ "articles/toc.yml" ],
        "tocFilter": "excludeUnreferencedPages"
      },
      {
        "files": [ "api/toc.yml" ],
        "tocFilter": "excludeUnreferencedPages"
      }
    ],
    "dest": "_pdf"
  }
}
```

## Troubleshooting

### Common Issues

#### Configuration file not found

```text
❌ Error: DocFX configuration file not found: docfx.json
```

**Solution:**

- Ensure the `config` path is correct relative to the repository root
- Verify the file exists and has the correct name
- Check file permissions

#### No PDF files generated

```text
⚠️ No PDF files were generated
```

**Solution:**

- Verify your `docfx.json` includes a `pdf` section
- Ensure the content files specified in the PDF section exist
- Check that the table of contents (toc.yml) files are properly configured
- Review the log output for specific error messages

#### PDF generation fails with missing dependencies

```text
❌ Error: PDF generation failed
```

**Solution:**

- On Linux: Install required packages
  ```bash
  sudo apt-get update
  sudo apt-get install -y libgdiplus libc6-dev
  ```
- On macOS: Ensure system is up to date
- On Windows: Usually works out of the box

#### Memory issues with large documentation

**Solution:**

- Split large documentation into smaller sections
- Use `log-level: 'error'` to reduce memory usage
- Consider generating PDFs for specific sections only

### Debugging Tips

1. **Enable verbose logging:**

   ```yaml
   verbose: 'true'
   log-level: 'diagnostic'
   ```

2. **Save logs to file:**

   ```yaml
   log-file: 'docfx-pdf-debug.log'
   ```

3. **Check PDF configuration:**

   ```bash
   dotnet tool install -g docfx
   docfx pdf docfx.json --dry-run
   ```

4. **Validate content structure:**

   ```yaml
   show-summary: 'true'
   ```

5. **Test locally:**

   ```bash
   # Install DocFX globally
   dotnet tool install -g docfx

   # Generate metadata first
   docfx metadata docfx.json

   # Build the site
   docfx build docfx.json

   # Generate PDF
   docfx pdf docfx.json
   ```

### Platform-Specific Notes

#### Windows

- PDF generation typically works without additional setup
- Ensure .NET SDK is properly installed

#### Linux (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y libgdiplus libc6-dev
```

#### macOS

- May require additional system updates
- Consider using Docker for consistent results

## Output Structure

The action generates the following output structure:

```text
output-directory/
├── documentation.pdf      # Main documentation PDF
├── api-reference.pdf      # API reference PDF (if configured)
└── assets/               # Supporting assets
    └── images/           # Images used in PDF
```

## Related Actions

- **dotnet-docfx-metadata**: Generate API metadata from source code
- **dotnet-docfx-build**: Build HTML documentation sites
- **dotnet-tool-install**: Install .NET tools including DocFX
- **dotnet**: Execute .NET CLI commands

## Best Practices

1. **Generate metadata first**: Always run `dotnet-docfx-metadata` before PDF generation
2. **Build the site**: Consider running `dotnet-docfx-build` to validate content
3. **Use appropriate templates**: Choose templates that work well for PDF output
4. **Optimize images**: Ensure images are appropriately sized for PDF
5. **Test locally**: Validate PDF generation locally before CI/CD deployment
6. **Version your PDFs**: Include version information in PDF metadata

## License

This action is part of the GitHub Actions collection by Francois Raminosona.
