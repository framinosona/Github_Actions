# 📚 DocFX Documentation Build Action

A comprehensive GitHub Action for building complete documentation sites using DocFX .NET Global Tool with support for multiple output formats, themes, and advanced configuration options.

## ✨ Features

- 📚 **Complete Documentation Building** - Build full documentation sites from DocFX projects
- 🎨 **Theme & Template Support** - Built-in and custom theme integration
- 🔧 **Automatic Tool Management** - Installs and manages DocFX global tool
- 📊 **Multi-Format Output** - HTML, PDF-ready, and custom format support
- ⚡ **Performance Optimized** - Configurable parallelism and caching
- 🛡️ **Cross-Platform** - Works on Windows, Linux, and macOS runners
- 📋 **Comprehensive Validation** - Input validation with helpful error messages
- 🔍 **Debug Support** - Export models and detailed logging for troubleshooting

## 🚀 Basic Usage

Build documentation with default settings:

```yaml
- name: "Build documentation"
  uses: laerdal/github_actions/dotnet-docfx-build@main
  with:
    config: "docfx.json"
```

```yaml
- name: "Build with custom output"
  uses: laerdal/github_actions/dotnet-docfx-build@main
  with:
    config: "docs/docfx.json"
    output: "./dist/documentation"
```

```yaml
- name: "Build with specific theme"
  uses: laerdal/github_actions/dotnet-docfx-build@main
  with:
    config: "docfx.json"
    template: "modern"
    serve: "false"
```

## 🔧 Advanced Usage

Full configuration with all available options:

```yaml
- name: "Advanced documentation build"
  uses: laerdal/github_actions/dotnet-docfx-build@main
  with:
    config: "docs/docfx.json"
    output: "./dist/docs"
    template: "modern,pdf"
    theme: "darkfx"
    log-level: "info"
    log-file: "./logs/build.json"
    working-directory: "./documentation"
    global: "true"
    serve: "false"
    port: "8080"
    hostname: "localhost"
    force: "true"
    debug: "false"
    debugOutput: "./debug"
    export-raw-model: "false"
    export-view-model: "false"
    raw-model-output: "./models/raw"
    view-model-output: "./models/view"
    dry-run: "false"
    disable-git-features: "false"
    max-parallelism: "4"
    markup-engine: "markdig"
    no-check-external-link: "false"
    disable-contribution: "false"
    disable-edit-page: "false"
    disable-navbar: "false"
    disable-breadcrumb: "false"
    clean-cache: "false"
    show-summary: "true"
```

## 🔐 Permissions Required

This action requires standard repository permissions:

```yaml
permissions:
  contents: read  # Required to checkout repository code
```

## 🏗️ CI/CD Example

Complete workflow for documentation site generation and deployment:

```yaml
name: "Documentation Build & Deploy"

on:
  push:
    branches: ["main"]
    paths: ["docs/**", "src/**/*.cs"]
  pull_request:
    branches: ["main"]

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build-docs:
    runs-on: ubuntu-latest

    steps:
      - name: "📥 Checkout repository"
        uses: actions/checkout@v4

      - name: "🔧 Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: "📖 Generate API metadata"
        uses: laerdal/github_actions/dotnet-docfx-metadata@main
        with:
          config: "docs/docfx.json"
          projects: "./src/**/*.csproj"
          output: "./docs/api"

      - name: "📚 Build documentation site"
        id: build-docs
        uses: laerdal/github_actions/dotnet-docfx-build@main
        with:
          config: "docs/docfx.json"
          output: "./dist/docs"
          template: "modern"
          log-level: "info"
          force: "true"
          max-parallelism: "2"
          show-summary: "true"

      - name: "📤 Upload documentation artifact"
        uses: actions/upload-artifact@v4
        with:
          name: "documentation-site"
          path: ./dist/docs

      - name: "🚀 Deploy to GitHub Pages"
        if: github.ref == 'refs/heads/main'
        uses: actions/deploy-pages@v4
        with:
          artifact_name: "documentation-site"
```

## 📋 Inputs

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `config` | Path to DocFX configuration file | ❌ No | `"docfx.json"` | `docs/docfx.json`, `./config/docs.json` |
| `output` | Output directory for built site | ❌ No | `"_site"` | `./dist/docs`, `./public` |
| `template` | DocFX template(s) to use | ❌ No | `"default"` | `modern`, `statictoc,pdf` |
| `theme` | Custom theme for documentation | ❌ No | `""` | `darkfx`, `custom-theme` |
| `log-level` | Logging verbosity level | ❌ No | `"info"` | `quiet`, `minimal`, `info`, `verbose`, `diagnostic` |
| `log-file` | Path to save structured JSON logs | ❌ No | `""` | `./logs/build.json` |
| `working-directory` | Working directory for command execution | ❌ No | `"."` | `./docs`, `./documentation` |
| `global` | Install DocFX as global tool if needed | ❌ No | `"true"` | `true`, `false` |
| `serve` | Start local web server after build | ❌ No | `"false"` | `true`, `false` |
| `port` | Port for local web server | ❌ No | `"8080"` | `3000`, `8080`, `9000` |
| `hostname` | Hostname for local web server | ❌ No | `"localhost"` | `localhost`, `0.0.0.0` |
| `force` | Force rebuild of all content | ❌ No | `"false"` | `true`, `false` |
| `debug` | Enable debug mode | ❌ No | `"false"` | `true`, `false` |
| `debugOutput` | Output directory for debug files | ❌ No | `""` | `./debug`, `./troubleshoot` |
| `export-raw-model` | Export raw model data | ❌ No | `"false"` | `true`, `false` |
| `export-view-model` | Export view model data | ❌ No | `"false"` | `true`, `false` |
| `raw-model-output` | Output directory for raw models | ❌ No | `""` | `./models/raw` |
| `view-model-output` | Output directory for view models | ❌ No | `""` | `./models/view` |
| `dry-run` | Perform dry run without generating output | ❌ No | `"false"` | `true`, `false` |
| `disable-git-features` | Disable Git-based features | ❌ No | `"false"` | `true`, `false` |
| `max-parallelism` | Maximum parallel processing threads | ❌ No | `"0"` | `1`, `2`, `4`, `8` |
| `markup-engine` | Markup processing engine | ❌ No | `"markdig"` | `markdig`, `dfm` |
| `no-check-external-link` | Skip external link validation | ❌ No | `"false"` | `true`, `false` |
| `disable-contribution` | Disable contribution links | ❌ No | `"false"` | `true`, `false` |
| `disable-edit-page` | Disable edit page links | ❌ No | `"false"` | `true`, `false` |
| `disable-navbar` | Disable navigation bar | ❌ No | `"false"` | `true`, `false` |
| `disable-breadcrumb` | Disable breadcrumb navigation | ❌ No | `"false"` | `true`, `false` |
| `clean-cache` | Clean DocFX cache before build | ❌ No | `"false"` | `true`, `false` |
| `show-summary` | Display action summary | ❌ No | `"false"` | `true`, `false` |

## 📤 Outputs

| Output | Description | Type | Example |
|--------|-------------|------|---------|
| `exit-code` | Exit code of the DocFX command | `string` | `0`, `1` |
| `executed-command` | Full command that was executed | `string` | `dotnet tool run DocFX build docfx.json` |
| `output-path` | Path to the generated documentation | `string` | `./dist/docs` |
| `site-size` | Total size of generated site in bytes | `string` | `15728640` |
| `files-generated` | Number of files generated | `string` | `156` |
| `build-time` | Build duration in seconds | `string` | `45.2` |
| `server-url` | URL if serve mode is enabled | `string` | `http://localhost:8080` |

## 🔗 Related Actions

| Action | Purpose | Repository |
|--------|---------|------------|
| 📖 **dotnet-docfx-metadata** | Generate API metadata | `laerdal/github_actions/dotnet-docfx-metadata` |
| 📄 **dotnet-docfx-pdf** | Generate PDF documentation | `laerdal/github_actions/dotnet-docfx-pdf` |
| 🔧 **dotnet-tool-install** | Install .NET tools | `laerdal/github_actions/dotnet-tool-install` |
| 🚀 **dotnet** | Execute .NET CLI commands | `laerdal/github_actions/dotnet` |

## 💡 Examples

### Basic Documentation Site

```yaml
- name: "Build documentation site"
  uses: laerdal/github_actions/dotnet-docfx-build@main
  with:
    config: "docfx.json"
    output: "./site"
    template: "modern"
```

### Multi-Template Build

```yaml
- name: "Build with multiple templates"
  uses: laerdal/github_actions/dotnet-docfx-build@main
  with:
    config: "docfx.json"
    template: "modern,statictoc,pdf"
    output: "./dist"
    force: "true"
```

### Debug and Development Mode

```yaml
- name: "Build with debugging"
  uses: laerdal/github_actions/dotnet-docfx-build@main
  with:
    config: "docfx.json"
    debug: "true"
    debugOutput: "./debug"
    export-raw-model: "true"
    export-view-model: "true"
    log-level: "diagnostic"
```

### Local Development Server

```yaml
- name: "Build and serve locally"
  uses: laerdal/github_actions/dotnet-docfx-build@main
  with:
    config: "docfx.json"
    serve: "true"
    port: "3000"
    hostname: "0.0.0.0"
    force: "true"
```

### Performance Optimized Build

```yaml
- name: "Fast parallel build"
  uses: laerdal/github_actions/dotnet-docfx-build@main
  with:
    config: "docfx.json"
    max-parallelism: "4"
    no-check-external-link: "true"
    clean-cache: "true"
    disable-git-features: "false"
```

### GitHub Pages Deployment

```yaml
- name: "Build for GitHub Pages"
  uses: laerdal/github_actions/dotnet-docfx-build@main
  with:
    config: "docs/docfx.json"
    output: "./pages"
    template: "modern"
    disable-contribution: "true"
    disable-edit-page: "true"
    force: "true"
```

## 🎨 Available Templates

| Template | Description | Use Case |
|----------|-------------|----------|
| `default` | Standard DocFX template | Basic documentation |
| `modern` | Modern responsive design | Professional sites |
| `statictoc` | Static table of contents | Large documentation sets |
| `material` | Material design theme | Modern UI/UX |
| `pdf` | PDF-optimized layout | Print-ready documentation |

## 🔧 Markup Engines

| Engine | Description | Features |
|--------|-------------|----------|
| `markdig` | Advanced Markdown processor | Extensions, tables, math |
| `dfm` | DocFX Flavored Markdown | DocFX-specific features |

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

#### Build Failures

**Problem**: Documentation build fails with errors

**Solution**: Enable diagnostic logging and check dependencies:

```yaml
- name: "Debug build issues"
  uses: laerdal/github_actions/dotnet-docfx-build@main
  with:
    config: "docfx.json"
    log-level: "diagnostic"
    log-file: "./logs/build-debug.json"
    debug: "true"
    debugOutput: "./debug"
```

#### Missing Content

**Problem**: Some content is not included in the build

**Solution**: Check configuration and force rebuild:

```yaml
- name: "Force complete rebuild"
  uses: laerdal/github_actions/dotnet-docfx-build@main
  with:
    config: "docfx.json"
    force: "true"
    clean-cache: "true"
    export-raw-model: "true"
```

#### Template Issues

**Problem**: Custom template not working correctly

**Solution**: Use built-in templates and verify template path:

```yaml
- name: "Use built-in template"
  uses: laerdal/github_actions/dotnet-docfx-build@main
  with:
    config: "docfx.json"
    template: "modern"
    theme: ""
```

#### Performance Issues

**Problem**: Build is slow or times out

**Solution**: Optimize build settings:

```yaml
- name: "Optimized build"
  uses: laerdal/github_actions/dotnet-docfx-build@main
  with:
    config: "docfx.json"
    max-parallelism: "2"
    no-check-external-link: "true"
    disable-git-features: "true"
```

### Debug Tips

1. **Enable Debug Mode**: Set `debug: "true"` and `debugOutput`
2. **Export Models**: Use `export-raw-model` and `export-view-model`
3. **Detailed Logging**: Set `log-level: "diagnostic"`
4. **Dry Run**: Use `dry-run: "true"` to test configuration

## 📊 Debug Output

When debug mode is enabled, the following files are generated:

- Raw model files (`.raw.model.json`)
- View model files (`.view.model.json`)
- Debug logs with detailed processing information
- Configuration validation results

## 📝 Requirements

- GitHub Actions runner (Windows, Linux, or macOS)
- .NET SDK installed (use `actions/setup-dotnet`)
- Valid DocFX configuration file (docfx.json)
- Source content (Markdown files, API metadata)

## 🔧 Advanced Features

### Custom Theme Integration

```yaml
- name: "Build with custom theme"
  uses: laerdal/github_actions/dotnet-docfx-build@main
  with:
    config: "docfx.json"
    template: "custom"
    theme: "./themes/company-theme"
```

### Multi-Stage Builds

```yaml
- name: "Build development version"
  uses: laerdal/github_actions/dotnet-docfx-build@main
  with:
    config: "docfx-dev.json"
    output: "./dev-docs"

- name: "Build production version"
  uses: laerdal/github_actions/dotnet-docfx-build@main
  with:
    config: "docfx-prod.json"
    output: "./prod-docs"
    force: "true"
```

## 📄 License

This action is part of the GitHub Actions collection by Francois Raminosona.

---

> 💡 **Tip**: For complete documentation workflows, combine this action with our metadata generation and PDF creation actions in the [Related Actions](#-related-actions) section.
