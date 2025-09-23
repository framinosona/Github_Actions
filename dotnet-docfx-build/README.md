# 🏗️ DocFX Build Action

Build static site contents from DocFX projects using the DocFX .NET Global Tool.

## Features

- 🏗️ **Static Site Generation** - Build complete documentation websites
- 🎨 **Theme & Template Support** - Use built-in or custom themes and templates
- 🔧 **Debug Support** - Export raw and view models for troubleshooting
- 📊 **Comprehensive Logging** - Multiple log levels with optional structured JSON output
- ⚡ **Performance Options** - Configurable parallelism and Git feature control
- 📈 **Detailed Analytics** - File counts, sizes, and execution metrics

## Usage

### Basic Usage

Build documentation using default `docfx.json` configuration:

```yaml
- name: Build Documentation
  uses: ./dotnet-docfx-build
  with:
    config: 'docfx.json'
```

### Advanced Usage

```yaml
- name: Build Documentation with Custom Settings
  uses: ./dotnet-docfx-build
  with:
    config: 'docs/docfx.json'
    output: 'documentation'
    theme: 'modern'
    template: 'custom-template'
    log-level: 'verbose'
    warnings-as-errors: 'true'
    metadata: '{"_appTitle":"My Project","_appFooter":"© 2024 My Company"}'
    xref: 'https://docs.microsoft.com/dotnet/xref/'
```

## Inputs

| Input | Description | Default | Example |
|-------|-------------|---------|---------|
| `config` | Path to the docfx configuration file | `docfx.json` | `docs/docfx.json` |
| `output` | Output base directory | `_site` | `documentation` |
| `log-level` | Log level (error, warning, info, verbose, diagnostic) | `info` | `verbose` |
| `log-file` | Save structured JSON log to specified file | `''` | `docfx.log.json` |
| `verbose` | Enable verbose logging | `false` | `true` |
| `warnings-as-errors` | Treat warnings as errors | `false` | `true` |
| `metadata` | Global metadata in JSON format | `''` | `{"_appTitle":"My App"}` |
| `xref` | Comma-separated xrefmap URLs | `''` | `https://docs.microsoft.com/dotnet/xref/` |
| `template` | Template name to apply | `''` | `modern` |
| `theme` | Theme to use | `default` | `modern` |
| `debug` | Run in debug mode | `false` | `true` |
| `debug-output` | Debug output folder | `''` | `debug-output` |
| `export-raw-model` | Export raw model files | `false` | `true` |
| `raw-model-output-folder` | Raw model output folder | `''` | `raw-models` |
| `export-view-model` | Export view model files | `false` | `true` |
| `view-model-output-folder` | View model output folder | `''` | `view-models` |
| `max-parallelism` | Maximum parallel processes (0 = auto) | `0` | `4` |
| `markdown-engine-properties` | Markdown engine parameters (JSON) | `''` | `{"markdigExtensions":["pipes"]}` |
| `post-processors` | Comma-separated post processor order | `''` | `ExtractSearchIndex,SitemapGenerator` |
| `disable-git-features` | Disable Git information fetching | `false` | `true` |
| `docfx-version` | Specific DocFX version to install | `''` | `2.70.0` |
| `show-summary` | Show action summary | `true` | `false` |

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `output-path` | Full path to generated documentation | `/path/to/_site` |
| `config-path` | Path to DocFX configuration file used | `/path/to/docfx.json` |
| `files-count` | Number of files generated | `145` |
| `output-size` | Total output directory size in bytes | `2048576` |
| `execution-time` | Build time in seconds | `45` |

## Examples

### Complete Documentation Build

```yaml
name: Build Documentation

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '8.0.x'

    - name: Build Documentation
      uses: ./dotnet-docfx-build
      with:
        config: 'docfx.json'
        output: 'docs-site'
        theme: 'modern'
        metadata: '{"_appTitle":"My API Documentation"}'
        warnings-as-errors: 'true'

    - name: Upload Documentation
      uses: actions/upload-artifact@v4
      with:
        name: documentation-site
        path: docs-site/
```

### Debug Build with Model Export

```yaml
- name: Debug Build with Model Export
  uses: ./dotnet-docfx-build
  with:
    config: 'docfx.json'
    debug: 'true'
    export-raw-model: 'true'
    export-view-model: 'true'
    debug-output: 'debug-files'
    log-level: 'diagnostic'
```

### Production Build with Performance Optimization

```yaml
- name: Production Documentation Build
  uses: ./dotnet-docfx-build
  with:
    config: 'docfx.json'
    output: 'production-docs'
    max-parallelism: '4'
    disable-git-features: 'true'
    warnings-as-errors: 'true'
    log-level: 'warning'
    metadata: |
      {
        "_appTitle": "Production Documentation",
        "_appFooter": "© 2024 My Company. All rights reserved.",
        "_enableSearch": true
      }
```

## Requirements

### Prerequisites

- .NET SDK (any supported version)
- DocFX-compatible project structure
- Valid `docfx.json` configuration file

### Dependencies

- **DocFX Global Tool** - Automatically installed by the action

### Supported Platforms

- ✅ Linux (ubuntu-latest)
- ✅ macOS (macos-latest)
- ✅ Windows (windows-latest)

## Configuration

### DocFX Configuration File

Create a `docfx.json` file for build configuration:

```json
{
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
    "output": "_site",
    "template": ["default", "modern"],
    "globalMetadata": {
      "_appTitle": "My Project Documentation"
    }
  }
}
```

## Troubleshooting

### Common Issues

#### ❌ Build Failures

```
Error: Documentation build failed
```

**Solutions:**
1. Enable verbose logging:
   ```yaml
   log-level: 'verbose'
   verbose: 'true'
   ```

2. Use debug mode:
   ```yaml
   debug: 'true'
   export-raw-model: 'true'
   ```

3. Check your content file references in `docfx.json`

#### ❌ Template/Theme Issues

```
Error: Template 'xyz' not found
```

**Solutions:**
1. Use built-in themes:
   ```yaml
   theme: 'default'  # or 'modern'
   ```

2. Ensure custom templates are in the correct path

#### ❌ Memory Issues

```
OutOfMemoryException during build
```

**Solutions:**
1. Reduce parallelism:
   ```yaml
   max-parallelism: '1'
   ```

2. Disable Git features for large repos:
   ```yaml
   disable-git-features: 'true'
   ```

### Performance Optimization

For large documentation sets:

```yaml
- name: Optimized Documentation Build
  uses: ./dotnet-docfx-build
  with:
    config: 'docfx.json'
    max-parallelism: '4'
    disable-git-features: 'true'
    log-level: 'warning'
```

### Validation

Validate your configuration before building:

```yaml
- name: Validate Build Configuration
  uses: ./dotnet-docfx-build
  with:
    config: 'docfx.json'
    log-level: 'verbose'
```

## Contributing

When contributing to this action:

1. Follow the [Actions Guidelines](../.github/copilot-instructions.md)
2. Test with various DocFX configurations
3. Ensure cross-platform compatibility
4. Update documentation for new features

## License

This action is distributed under the same license as the repository.

## Support

For issues related to:
- **DocFX build functionality:** Check [DocFX Build Documentation](https://dotnet.github.io/docfx/reference/docfx-cli-reference/docfx-build.html)
- **Action bugs:** Create an issue in this repository
- **GitHub Actions:** Check [GitHub Actions Documentation](https://docs.github.com/en/actions)
