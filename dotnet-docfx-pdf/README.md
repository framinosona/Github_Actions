# 📄 DocFX PDF Generation Action

A comprehensive GitHub Action for generating high-quality PDF documentation from DocFX projects with support for custom templates, advanced configuration, and enterprise documentation workflows.

## ✨ Features

- 📋 **PDF Generation** - Convert DocFX documentation projects to professional PDF documents
- ⚙️ **Flexible Configuration** - Support for custom DocFX configurations and output directories
- 🔧 **Advanced Options** - Configurable logging, error handling, and validation settings
- 📊 **Rich Reporting** - Comprehensive output analysis with file statistics and generation metrics
- 🌐 **Cross-Platform** - Full compatibility across Windows, Linux, and macOS runners
- 📄 **Professional Output** - High-quality PDF suitable for offline distribution and archival
- 🚀 **Performance Optimization** - Efficient processing and resource management
- ✅ **Quality Assurance** - Built-in validation and error detection

## 🚀 Basic Usage

Generate PDF documentation:

```yaml
- name: "Generate PDF documentation"
  uses: laerdal/github_actions/dotnet-docfx-pdf@main
  with:
    config: "docfx.json"
    output: "_site"
```

```yaml
- name: "Generate with custom output"
  uses: laerdal/github_actions/dotnet-docfx-pdf@main
  with:
    config: "docs/docfx.json"
    output: "pdf-output"
    log-level: "info"
```

```yaml
- name: "Generate with specific DocFX version"
  uses: laerdal/github_actions/dotnet-docfx-pdf@main
  with:
    config: "docfx.json"
    docfx-version: "2.70.0"
    show-summary: "true"
```

## 🔧 Advanced Usage

Complete PDF generation with all configuration options:

```yaml
- name: "Advanced PDF generation"
  uses: laerdal/github_actions/dotnet-docfx-pdf@main
  with:
    config: "docs/docfx.json"
    output: "documentation/pdf"
    log-level: "verbose"
    log-file: "pdf-generation.log"
    verbose: "true"
    warnings-as-errors: "true"
    docfx-version: "2.70.0"
    show-summary: "true"
```

## 🔐 Permissions Required

This action requires standard repository permissions:

```yaml
permissions:
  contents: read  # Required to checkout repository code
```

For uploading artifacts or releases:

```yaml
permissions:
  contents: write  # Required to upload artifacts or create releases
```

## 🏗️ CI/CD Example

Complete documentation workflow with PDF generation:

```yaml
name: "Documentation Pipeline"

on:
  push:
    branches: ["main"]
    paths: ["docs/**", "src/**/*.cs"]
  release:
    types: [published]

permissions:
  contents: write

jobs:
  generate-documentation:
    runs-on: ubuntu-latest

    steps:
      - name: "📥 Checkout repository"
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: "🔧 Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: "🔧 Install DocFX"
        uses: laerdal/github_actions/dotnet-tool-install@main
        with:
          package-name: "docfx"
          version: "2.70.0"
          global: "true"

      - name: "📊 Generate API metadata"
        id: metadata
        uses: laerdal/github_actions/dotnet-docfx-metadata@main
        with:
          config: "docs/docfx.json"
          output: "docs/api"
          log-level: "info"
          show-summary: "true"

      - name: "🔨 Build documentation site"
        id: build
        uses: laerdal/github_actions/dotnet-docfx-build@main
        with:
          config: "docs/docfx.json"
          output: "docs/_site"
          log-level: "info"
          warnings-as-errors: "true"
          show-summary: "true"

      - name: "📄 Generate PDF documentation"
        id: pdf
        uses: laerdal/github_actions/dotnet-docfx-pdf@main
        with:
          config: "docs/docfx.json"
          output: "docs/pdf"
          log-level: "info"
          log-file: "pdf-generation.log"
          warnings-as-errors: "true"
          show-summary: "true"

      - name: "📊 Display generation results"
        run: |
          echo "📄 PDF Generation Results:"
          echo "Files generated: ${{ steps.pdf.outputs.files-count }}"
          echo "Output size: ${{ steps.pdf.outputs.output-size }} bytes"
          echo "PDF files: ${{ steps.pdf.outputs.pdf-files }}"
          echo "Output path: ${{ steps.pdf.outputs.output-path }}"

      - name: "📦 Upload PDF artifacts"
        uses: actions/upload-artifact@v4
        with:
          name: "documentation-pdf-${{ github.sha }}"
          path: ${{ steps.pdf.outputs.output-path }}
          retention-days: 90

      - name: "🚀 Attach PDF to release"
        if: github.event_name == 'release'
        uses: actions/upload-release-asset@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          upload_url: ${{ github.event.release.upload_url }}
          asset_path: "${{ steps.pdf.outputs.output-path }}/documentation.pdf"
          asset_name: "documentation-${{ github.event.release.tag_name }}.pdf"
          asset_content_type: "application/pdf"

      - name: "🏷️ Generate documentation badge"
        if: success()
        uses: laerdal/github_actions/generate-badge@main
        with:
          label: "docs"
          message: "PDF ready"
          color: "brightgreen"
          style: "flat-square"
          logo: "read-the-docs"

  multi-version-docs:
    strategy:
      matrix:
        version: ["v1.0", "v2.0", "latest"]
        include:
          - version: "v1.0"
            config: "docs/v1/docfx.json"
            output: "docs/pdf/v1"
          - version: "v2.0"
            config: "docs/v2/docfx.json"
            output: "docs/pdf/v2"
          - version: "latest"
            config: "docs/docfx.json"
            output: "docs/pdf/latest"

    runs-on: ubuntu-latest

    steps:
      - name: "📥 Checkout repository"
        uses: actions/checkout@v4

      - name: "🔧 Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: "📄 Generate PDF for ${{ matrix.version }}"
        id: generate
        uses: laerdal/github_actions/dotnet-docfx-pdf@main
        with:
          config: ${{ matrix.config }}
          output: ${{ matrix.output }}
          log-level: "info"
          log-file: "pdf-${{ matrix.version }}.log"
          show-summary: "true"

      - name: "📦 Archive versioned documentation"
        uses: actions/upload-artifact@v4
        with:
          name: "docs-${{ matrix.version }}"
          path: ${{ matrix.output }}/
          retention-days: 365
```

## 📋 Inputs

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `config` | Path to DocFX configuration file | ❌ No | `docfx.json` | `docs/docfx.json`, `./docfx.yaml` |
| `output` | Output base directory | ❌ No | `_site` | `pdf-docs`, `documentation/output` |
| `log-level` | Log level for DocFX | ❌ No | `info` | `error`, `warning`, `info`, `verbose`, `diagnostic` |
| `log-file` | Save log to structured JSON file | ❌ No | `''` | `generation.log`, `logs/docfx.json` |
| `verbose` | Enable verbose logging | ❌ No | `false` | `true`, `false` |
| `warnings-as-errors` | Treat warnings as errors | ❌ No | `false` | `true`, `false` |
| `docfx-version` | DocFX tool version to install | ❌ No | `''` | `2.70.0`, `2.59.4` |
| `show-summary` | Show detailed action summary | ❌ No | `false` | `true`, `false` |

## 📤 Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `output-path` | Full path to generated PDF output | `/github/workspace/docs/pdf` |
| `config-path` | Path to DocFX configuration used | `/github/workspace/docs/docfx.json` |
| `pdf-files` | Comma-separated list of PDF files | `documentation.pdf,api-reference.pdf` |
| `files-count` | Number of PDF files generated | `2`, `5` |
| `output-size` | Total output directory size in bytes | `2048576`, `10485760` |

## 🔗 Related Actions

| Action | Purpose | Repository |
|--------|---------|------------|
| 📊 **dotnet-docfx-metadata** | Generate API metadata | `laerdal/github_actions/dotnet-docfx-metadata` |
| 🔨 **dotnet-docfx-build** | Build HTML documentation | `laerdal/github_actions/dotnet-docfx-build` |
| 🔧 **dotnet-tool-install** | Install DocFX tool | `laerdal/github_actions/dotnet-tool-install` |
| 🚀 **dotnet** | Build .NET projects | `laerdal/github_actions/dotnet` |

## 💡 Examples

### Basic PDF Documentation Workflow

```yaml
name: "Generate Documentation PDF"

on:
  push:
    branches: ["main"]
    paths: ["docs/**"]

jobs:
  pdf-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: "Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: "Generate PDF"
        uses: laerdal/github_actions/dotnet-docfx-pdf@main
        with:
          config: "docfx.json"
          output: "pdf-output"
          show-summary: "true"

      - name: "Upload PDF"
        uses: actions/upload-artifact@v4
        with:
          name: "documentation-pdf"
          path: pdf-output/*.pdf
```

### Release Documentation Automation

```yaml
name: "Release Documentation"

on:
  release:
    types: [published]

jobs:
  release-docs:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4

      - name: "Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: "Generate metadata"
        uses: laerdal/github_actions/dotnet-docfx-metadata@main
        with:
          config: "docs/docfx.json"

      - name: "Build site"
        uses: laerdal/github_actions/dotnet-docfx-build@main
        with:
          config: "docs/docfx.json"

      - name: "Generate PDF"
        id: pdf
        uses: laerdal/github_actions/dotnet-docfx-pdf@main
        with:
          config: "docs/docfx.json"
          output: "docs/pdf"
          warnings-as-errors: "true"
          show-summary: "true"

      - name: "Attach to release"
        uses: actions/upload-release-asset@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          upload_url: ${{ github.event.release.upload_url }}
          asset_path: "${{ steps.pdf.outputs.pdf-files }}"
          asset_name: "docs-${{ github.event.release.tag_name }}.pdf"
          asset_content_type: "application/pdf"
```

### Multi-Language Documentation

```yaml
strategy:
  matrix:
    language: ["en", "es", "fr", "de"]
    include:
      - language: "en"
        config: "docs/en/docfx.json"
        output: "docs/pdf/en"
      - language: "es"
        config: "docs/es/docfx.json"
        output: "docs/pdf/es"
      - language: "fr"
        config: "docs/fr/docfx.json"
        output: "docs/pdf/fr"
      - language: "de"
        config: "docs/de/docfx.json"
        output: "docs/pdf/de"

steps:
  - name: "Generate ${{ matrix.language }} PDF"
    uses: laerdal/github_actions/dotnet-docfx-pdf@main
    with:
      config: ${{ matrix.config }}
      output: ${{ matrix.output }}
      log-level: "info"
      show-summary: "true"

  - name: "Upload ${{ matrix.language }} docs"
    uses: actions/upload-artifact@v4
    with:
      name: "docs-${{ matrix.language }}"
      path: ${{ matrix.output }}/
```

### Scheduled Documentation Generation

```yaml
name: "Weekly Documentation Update"

on:
  schedule:
    - cron: "0 2 * * 1"  # Every Monday at 2 AM
  workflow_dispatch:

jobs:
  weekly-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: "Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: "Generate weekly PDF"
        id: weekly
        uses: laerdal/github_actions/dotnet-docfx-pdf@main
        with:
          config: "docs/docfx.json"
          output: "weekly-docs"
          log-level: "verbose"
          log-file: "weekly-generation.log"
          show-summary: "true"

      - name: "Archive weekly docs"
        run: |
          date_suffix=$(date +%Y-%m-%d)
          mkdir -p "archive/weekly"
          cp -r weekly-docs/ "archive/weekly/docs-$date_suffix/"

      - name: "Commit archive"
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add archive/
          git commit -m "📄 Weekly documentation update $(date +%Y-%m-%d)" || exit 0
          git push
```

## 🔧 DocFX Configuration for PDF

Your `docfx.json` should include PDF-specific configuration:

### Basic PDF Configuration

```json
{
  "metadata": [
    {
      "src": [
        {
          "files": ["**.csproj"],
          "exclude": ["**/bin/**", "**/obj/**"]
        }
      ],
      "dest": "api"
    }
  ],
  "build": {
    "content": [
      {
        "files": ["api/**.yml", "api/index.md"]
      },
      {
        "files": ["articles/**.md", "articles/**/toc.yml", "toc.yml", "*.md"]
      }
    ],
    "resource": [
      {
        "files": ["images/**"]
      }
    ],
    "dest": "_site",
    "template": ["default", "modern"],
    "globalMetadata": {
      "_appTitle": "My Documentation",
      "_appFooter": "© 2024 My Company"
    }
  },
  "pdf": {
    "content": [
      {
        "files": ["articles/toc.yml"],
        "tocFilter": "excludeUnreferencedPages"
      },
      {
        "files": ["api/toc.yml"],
        "tocFilter": "excludeUnreferencedPages"
      }
    ],
    "dest": "_pdf",
    "wkhtmltopdf": {
      "additionalArguments": "--enable-local-file-access --print-media-type"
    }
  }
}
```

### Advanced PDF Configuration

```json
{
  "pdf": {
    "content": [
      {
        "files": ["manual/toc.yml"],
        "tocFilter": "excludeUnreferencedPages"
      }
    ],
    "dest": "_pdf",
    "wkhtmltopdf": {
      "additionalArguments": "--enable-local-file-access --print-media-type --page-size A4 --margin-top 0.75in --margin-right 0.75in --margin-bottom 0.75in --margin-left 0.75in"
    },
    "excludedToc": ["api/toc.yml"],
    "generatesAppendices": true,
    "generatesExternalLink": false,
    "keepRawFiles": false,
    "rawOutputFolder": "raw"
  }
}
```

## 🖥️ Requirements

- .NET SDK 6.0 or later installed on the runner
- Valid DocFX configuration file with PDF section
- DocFX tool (automatically installed if version specified)
- System dependencies for PDF generation:
  - **Linux**: `libgdiplus`, `libc6-dev`
  - **Windows**: Built-in support
  - **macOS**: System updates may be required

### Platform-Specific Setup

#### Ubuntu/Debian Linux

```yaml
- name: "Install PDF dependencies"
  run: |
    sudo apt-get update
    sudo apt-get install -y libgdiplus libc6-dev wkhtmltopdf
```

#### CentOS/RHEL

```yaml
- name: "Install PDF dependencies"
  run: |
    sudo yum install -y libgdiplus-devel glibc-devel wkhtmltopdf
```

#### Docker Setup

```yaml
- name: "Setup Docker for PDF"
  run: |
    docker run --rm -v $(pwd):/workspace \
      mcr.microsoft.com/dotnet/sdk:8.0 \
      /bin/bash -c "cd /workspace && dotnet tool install -g docfx && docfx pdf docfx.json"
```

## 🐛 Troubleshooting

### Common Issues

#### Configuration File Not Found

**Problem**: "DocFX configuration file not found: docfx.json"

**Solution**: Verify file path and existence:

```yaml
- name: "Verify configuration"
  run: |
    echo "Checking DocFX configuration..."
    if [ -f "docfx.json" ]; then
      echo "✅ Configuration file found"
      cat docfx.json | jq '.pdf' || echo "No PDF section found"
    else
      echo "❌ Configuration file missing"
      find . -name "*.json" -type f | grep -i docfx || echo "No DocFX config found"
    fi

- name: "Generate PDF with verification"
  uses: laerdal/github_actions/dotnet-docfx-pdf@main
  with:
    config: "docfx.json"
    show-summary: "true"
```

#### No PDF Files Generated

**Problem**: "⚠️ No PDF files were generated"

**Solution**: Check PDF configuration and content:

```yaml
- name: "Debug PDF generation"
  run: |
    echo "Checking PDF configuration..."
    if [ -f "docfx.json" ]; then
      # Check if PDF section exists
      if jq -e '.pdf' docfx.json > /dev/null; then
        echo "✅ PDF section found in configuration"
        jq '.pdf' docfx.json
      else
        echo "❌ No PDF section in configuration"
        exit 1
      fi

      # Check for table of contents files
      if [ -f "toc.yml" ] || [ -f "articles/toc.yml" ]; then
        echo "✅ TOC files found"
      else
        echo "❌ No TOC files found"
      fi
    fi

- name: "Generate with debug"
  uses: laerdal/github_actions/dotnet-docfx-pdf@main
  with:
    config: "docfx.json"
    log-level: "diagnostic"
    verbose: "true"
    show-summary: "true"
```

#### PDF Generation Dependencies Missing

**Problem**: PDF generation fails with system dependency errors

**Solution**: Install required system packages:

```yaml
- name: "Install PDF dependencies (Linux)"
  if: runner.os == 'Linux'
  run: |
    sudo apt-get update
    sudo apt-get install -y libgdiplus libc6-dev wkhtmltopdf xvfb

- name: "Test PDF generation with dependencies"
  run: |
    # Test wkhtmltopdf installation
    wkhtmltopdf --version || echo "wkhtmltopdf not available"

    # Test with virtual display (Linux)
    if [ "$RUNNER_OS" = "Linux" ]; then
      xvfb-run -a wkhtmltopdf --version || echo "xvfb test failed"
    fi

- name: "Generate PDF with dependencies"
  uses: laerdal/github_actions/dotnet-docfx-pdf@main
  with:
    config: "docfx.json"
    log-level: "verbose"
    show-summary: "true"
```

#### Memory Issues with Large Documentation

**Problem**: Out of memory errors during PDF generation

**Solution**: Optimize configuration and split large docs:

```yaml
- name: "Optimize for large docs"
  run: |
    # Check documentation size
    echo "Documentation size analysis:"
    find . -name "*.md" -type f | wc -l
    find . -name "*.yml" -type f | wc -l
    du -sh docs/ 2>/dev/null || echo "docs/ not found"

- name: "Generate PDF with optimization"
  uses: laerdal/github_actions/dotnet-docfx-pdf@main
  with:
    config: "docfx.json"
    log-level: "error"  # Reduce memory usage
    show-summary: "true"
  env:
    DOTNET_CLI_TELEMETRY_OPTOUT: true  # Reduce memory overhead
```

### Debug Mode

Enable comprehensive debugging:

```yaml
- name: "Debug PDF generation"
  uses: laerdal/github_actions/dotnet-docfx-pdf@main
  with:
    config: "docfx.json"
    log-level: "diagnostic"
    verbose: "true"
    log-file: "debug-pdf.log"
    show-summary: "true"
  env:
    ACTIONS_STEP_DEBUG: true
    DOTNET_CLI_TELEMETRY_OPTOUT: true
```

### Local Testing

Test PDF generation locally:

```bash
# Install DocFX globally
dotnet tool install -g docfx

# Generate metadata first
docfx metadata docfx.json

# Build the site
docfx build docfx.json

# Generate PDF
docfx pdf docfx.json --log-level verbose

# Check output
ls -la _pdf/
```

## 🔧 Advanced Features

### Custom PDF Styling

```yaml
- name: "Generate with custom styling"
  run: |
    # Create custom CSS for PDF
    cat > pdf-styles.css << EOF
    @page {
      size: A4;
      margin: 1in;
    }
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      font-size: 12pt;
      line-height: 1.4;
    }
    h1, h2, h3 {
      color: #2e75b6;
      page-break-after: avoid;
    }
    EOF

- name: "Generate PDF with styling"
  uses: laerdal/github_actions/dotnet-docfx-pdf@main
  with:
    config: "docfx.json"
    output: "styled-pdf"
    show-summary: "true"
```

### Batch PDF Generation

```yaml
- name: "Generate multiple PDFs"
  run: |
    configs=("user-guide/docfx.json" "api-docs/docfx.json" "tutorials/docfx.json")

    for config in "${configs[@]}"; do
      echo "Processing $config..."
      if [ -f "$config" ]; then
        base_dir=$(dirname "$config")
        echo "Config found in $base_dir"
      fi
    done

- name: "User guide PDF"
  uses: laerdal/github_actions/dotnet-docfx-pdf@main
  with:
    config: "user-guide/docfx.json"
    output: "pdfs/user-guide"

- name: "API documentation PDF"
  uses: laerdal/github_actions/dotnet-docfx-pdf@main
  with:
    config: "api-docs/docfx.json"
    output: "pdfs/api-docs"
```

### Conditional PDF Generation

```yaml
- name: "Check if PDF generation needed"
  id: check-changes
  run: |
    if git diff --name-only HEAD~1 | grep -E '\.(md|yml|json)$' > /dev/null; then
      echo "needs-pdf=true" >> $GITHUB_OUTPUT
    else
      echo "needs-pdf=false" >> $GITHUB_OUTPUT
    fi

- name: "Generate PDF if needed"
  if: steps.check-changes.outputs.needs-pdf == 'true'
  uses: laerdal/github_actions/dotnet-docfx-pdf@main
  with:
    config: "docfx.json"
    show-summary: "true"
```

## 📄 License

This action is part of the GitHub Actions collection by Francois Raminosona.

---

> 💡 **Tip**: Always generate metadata and build the site before PDF generation for best results, and test PDF output locally during development.
