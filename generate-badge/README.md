# 🏷️ Generate Badge Action

A comprehensive GitHub Action for creating customizable static badges using shields.io with support for various styling options, logos, multiple output formats, and advanced badge management.

## ✨ Features

- 📋 **Flexible Badge Creation** - Support for label-message or message-only badges
- 🎨 **Comprehensive Styling** - Multiple styles, colors, logos, and visual customization
- 🔗 **Multiple Output Formats** - URL, Markdown, HTML, and SVG formats with automatic encoding
- 📁 **File Output Options** - Optional file saving with custom paths and format selection
- ⚡ **Fast & Reliable** - Direct shields.io integration with proper URL encoding
- 🛡️ **Input Validation** - Comprehensive parameter validation and error handling
- 📊 **Rich Action Summaries** - Detailed summaries with badge previews and statistics
- 🔍 **SVG Content Access** - Direct SVG content output for offline and custom usage

## 🚀 Basic Usage

Generate a simple status badge:

```yaml
- name: "Generate simple badge"
  uses: laerdal/github_actions/generate-badge@main
  with:
    message: "passing"
    color: "green"
```

```yaml
- name: "Generate build status badge"
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "build"
    message: "passing"
    color: "brightgreen"
```

```yaml
- name: "Generate version badge with logo"
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "npm"
    message: "v1.2.3"
    color: "blue"
    logo: "npm"
    style: "flat-square"
```

## 🔧 Advanced Usage

Full configuration with all available options:

```yaml
- name: "Advanced styled badge with logo"
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "coverage"
    message: "95%"
    color: "brightgreen"
    label-color: "grey"
    style: "for-the-badge"
    logo: "codecov"
    logo-color: "white"
    logo-size: "auto"
    output-file: "./badges/coverage.md"
    output-format: "markdown"
    cache-seconds: "3600"
    show-summary: "true"
```

## 🔐 Permissions Required

This action requires standard repository permissions:

```yaml
permissions:
  contents: read  # Required to checkout repository code
```

If saving badges to repository:

```yaml
permissions:
  contents: write  # Required to commit badge files
```

## 🏗️ CI/CD Example

Complete workflow for generating project badges:

```yaml
name: "Generate Project Badges"

on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["main"]
  workflow_run:
    workflows: ["Tests", "Build"]
    types: [completed]

permissions:
  contents: write

jobs:
  generate-badges:
    runs-on: ubuntu-latest

    steps:
      - name: "📥 Checkout repository"
        uses: actions/checkout@v4

      - name: "🔧 Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: "🧪 Run tests with coverage"
        id: test-results
        uses: laerdal/github_actions/dotnet-test@main
        with:
          projects: "./tests/**/*.csproj"
          collect: "XPlat Code Coverage"
          results-directory: "./test-results"

      - name: "📊 Calculate coverage percentage"
        id: coverage
        run: |
          # Extract coverage percentage from results
          coverage=$(grep -oP 'Line coverage: \K[0-9.]+' ./test-results/coverage.xml || echo "0")
          echo "percentage=$coverage" >> $GITHUB_OUTPUT

      - name: "🏷️ Generate build status badge"
        id: build-badge
        uses: laerdal/github_actions/generate-badge@main
        with:
          label: "build"
          message: ${{ job.status == 'success' && 'passing' || 'failing' }}
          color: ${{ job.status == 'success' && 'brightgreen' || 'red' }}
          style: "flat-square"
          logo: "github-actions"
          output-file: "./docs/badges/build.md"
          output-format: "markdown"
          show-summary: "true"

      - name: "📈 Generate coverage badge"
        uses: laerdal/github_actions/generate-badge@main
        with:
          label: "coverage"
          message: "${{ steps.coverage.outputs.percentage }}%"
          color: ${{ steps.coverage.outputs.percentage >= 90 && 'brightgreen' || (steps.coverage.outputs.percentage >= 70 && 'yellow' || 'red') }}
          style: "flat-square"
          logo: "codecov"
          output-file: "./docs/badges/coverage.md"
          output-format: "markdown"

      - name: "🔢 Generate version badge"
        uses: laerdal/github_actions/generate-badge@main
        with:
          label: "version"
          message: "v${{ env.VERSION || '1.0.0' }}"
          color: "blue"
          style: "flat-square"
          logo: "semver"
          output-file: "./docs/badges/version.md"
          output-format: "markdown"

      - name: "📄 Generate license badge"
        uses: laerdal/github_actions/generate-badge@main
        with:
          label: "license"
          message: "MIT"
          color: "blue"
          style: "flat-square"
          output-file: "./docs/badges/license.svg"
          output-format: "svg"

      - name: "💾 Commit badge updates"
        if: github.ref == 'refs/heads/main'
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add docs/badges/
          git diff --staged --quiet || git commit -m "🏷️ Update project badges"
          git push

      - name: "📊 Display badge URLs"
        run: |
          echo "Build badge: ${{ steps.build-badge.outputs.badge-url }}"
          echo "Badge files created in: ./docs/badges/"
```

## 📋 Inputs

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `label` | Left-hand side text of the badge | ❌ No | `''` | `build`, `coverage`, `npm` |
| `message` | Right-hand side text/message of the badge | ✅ Yes | - | `passing`, `95%`, `v1.2.3` |
| `color` | Background color of the right part | ❌ No | `blue` | `green`, `red`, `#ff6b6b`, `rgb(255,107,107)` |
| `label-color` | Background color of the left part | ❌ No | `''` | `grey`, `#555`, `rgba(85,85,85,1)` |
| `style` | Badge style | ❌ No | `flat` | `flat`, `flat-square`, `plastic`, `for-the-badge`, `social` |
| `logo` | Icon slug from simple-icons | ❌ No | `''` | `github`, `docker`, `node-dot-js`, `python` |
| `logo-color` | Color of the logo | ❌ No | `''` | `white`, `black`, `#ffffff` |
| `logo-size` | Logo size (set to "auto" for adaptive) | ❌ No | `''` | `auto` |
| `output-file` | File path to save the badge | ❌ No | `''` | `./badges/build.md`, `./docs/status.html` |
| `output-format` | Output format for file | ❌ No | `svg` | `url`, `markdown`, `html`, `svg` |
| `cache-seconds` | HTTP cache lifetime in seconds | ❌ No | `''` | `3600`, `86400` |
| `show-summary` | Whether to show action summary | ❌ No | `false` | `true`, `false` |

## 📤 Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `badge-url` | The generated shields.io badge URL | `https://img.shields.io/badge/build-passing-brightgreen` |
| `badge-markdown` | Badge in Markdown format | `![build: passing](https://img.shields.io/badge/build-passing-brightgreen)` |
| `badge-html` | Badge in HTML format | `<img src="..." alt="build: passing" />` |
| `svg-content` | SVG content of the badge | `<svg xmlns="http://www.w3.org/2000/svg"...` |
| `output-file-path` | Path to the output file if created | `/github/workspace/badges/build.md` |

## 🔗 Related Actions

| Action | Purpose | Repository |
|--------|---------|------------|
| 🧪 **dotnet-test** | Generate test result badges | `laerdal/github_actions/dotnet-test` |
| 🔢 **generate-version** | Create version badges | `laerdal/github_actions/generate-version` |
| 🚀 **dotnet** | Build status badges | `laerdal/github_actions/dotnet` |
| 🏷️ **git-tag** | Tag-based badges | `laerdal/github_actions/git-tag` |

## 💡 Examples

### Build Status Badges

```yaml
# Success badge
- name: "Generate success badge"
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "build"
    message: "passing"
    color: "brightgreen"
    logo: "github-actions"

# Failure badge
- name: "Generate failure badge"
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "build"
    message: "failing"
    color: "red"
    logo: "github-actions"
```

### Version Badges

```yaml
# NPM version
- name: "Generate NPM version badge"
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "npm"
    message: "v1.2.3"
    color: "blue"
    logo: "npm"
    style: "flat-square"

# Docker version
- name: "Generate Docker badge"
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "docker"
    message: "latest"
    color: "blue"
    logo: "docker"
    logo-color: "white"
```

### Coverage Badges

```yaml
# Dynamic coverage badge
- name: "Generate coverage badge"
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "coverage"
    message: "${{ env.COVERAGE_PERCENT }}%"
    color: ${{ env.COVERAGE_PERCENT >= 90 && 'brightgreen' || (env.COVERAGE_PERCENT >= 70 && 'yellow' || 'red') }}
    style: "flat-square"
    logo: "codecov"
```

### License and Social Badges

```yaml
# License badge
- name: "Generate license badge"
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "license"
    message: "MIT"
    color: "blue"
    style: "for-the-badge"

# Social follow badge
- name: "Generate social badge"
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "follow"
    message: "@username"
    color: "1da1f2"
    style: "social"
    logo: "twitter"
    logo-color: "white"
```

### Multi-Format Output

```yaml
# Save as different formats
- name: "Generate badge in multiple formats"
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "status"
    message: "active"
    color: "green"
    output-file: "./badges/status.md"
    output-format: "markdown"

- name: "Generate SVG badge"
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "status"
    message: "active"
    color: "green"
    output-file: "./badges/status.svg"
    output-format: "svg"
```

### Matrix Badge Generation

```yaml
strategy:
  matrix:
    badge:
      - { label: "build", message: "passing", color: "brightgreen", logo: "github-actions" }
      - { label: "tests", message: "100%", color: "brightgreen", logo: "pytest" }
      - { label: "coverage", message: "95%", color: "brightgreen", logo: "codecov" }
      - { label: "license", message: "MIT", color: "blue", logo: "" }

steps:
  - name: "Generate ${{ matrix.badge.label }} badge"
    uses: laerdal/github_actions/generate-badge@main
    with:
      label: ${{ matrix.badge.label }}
      message: ${{ matrix.badge.message }}
      color: ${{ matrix.badge.color }}
      logo: ${{ matrix.badge.logo }}
      style: "flat-square"
      output-file: "./docs/badges/${{ matrix.badge.label }}.md"
      output-format: "markdown"
```

## 🎨 Styling Options

### Available Styles

| Style | Description | Preview |
|-------|-------------|---------|
| `flat` | Default flat style | ![flat](https://img.shields.io/badge/style-flat-blue?style=flat) |
| `flat-square` | Flat with square corners | ![flat-square](https://img.shields.io/badge/style-flat--square-blue?style=flat-square) |
| `plastic` | Plastic 3D effect | ![plastic](https://img.shields.io/badge/style-plastic-blue?style=plastic) |
| `for-the-badge` | Large, bold style | ![for-the-badge](https://img.shields.io/badge/style-for--the--badge-blue?style=for-the-badge) |
| `social` | Social media style | ![social](https://img.shields.io/badge/style-social-blue?style=social) |

### Color Options

#### Named Colors

- `brightgreen`, `green`, `yellowgreen`, `yellow`, `orange`, `red`, `lightgrey`, `blue`

#### Hex Colors

- `#ff6b6b`, `#4ecdc4`, `#45b7d1`

#### RGB/RGBA Colors

- `rgb(255,107,107)`, `rgba(255,107,107,0.8)`

#### HSL/HSLA Colors

- `hsl(0,100%,50%)`, `hsla(0,100%,50%,0.8)`

### Logo Support

The action supports logos from [Simple Icons](https://simpleicons.org/). Popular examples:

| Service | Logo Slug | Example |
|---------|-----------|---------|
| GitHub | `github` | ![GitHub](https://img.shields.io/badge/GitHub-black?logo=github) |
| Docker | `docker` | ![Docker](https://img.shields.io/badge/Docker-blue?logo=docker&logoColor=white) |
| Node.js | `node-dot-js` | ![Node.js](https://img.shields.io/badge/Node.js-green?logo=node-dot-js) |
| Python | `python` | ![Python](https://img.shields.io/badge/Python-blue?logo=python&logoColor=white) |
| TypeScript | `typescript` | ![TypeScript](https://img.shields.io/badge/TypeScript-blue?logo=typescript&logoColor=white) |

## 📁 Output Formats

### URL Format

```text
https://img.shields.io/badge/build-passing-brightgreen
```

### Markdown Format

```markdown
![build: passing](https://img.shields.io/badge/build-passing-brightgreen)
```

### HTML Format

```html
<img src="https://img.shields.io/badge/build-passing-brightgreen" alt="build: passing" />
```

### SVG Format

```xml
<svg xmlns="http://www.w3.org/2000/svg" width="104" height="20">
  <!-- SVG content -->
</svg>
```

## 🔧 Character Encoding

The action automatically handles URL encoding for special characters:

| Character | Encoding |
|-----------|----------|
| Space ` ` | `%20` |
| Underscore `_` | `__` |
| Dash `-` | `--` |
| Percent `%` | `%25` |

## 🖥️ Requirements

- GitHub Actions runner (Windows, Linux, or macOS)
- Internet access to reach shields.io
- Bash shell (available on all GitHub runners)
- curl or wget (pre-installed on runners)

## 🐛 Troubleshooting

### Common Issues

#### Badge Not Displaying Correctly

**Problem**: Badge shows broken image or incorrect text

**Solution**: Check URL encoding of special characters:

```yaml
- name: "Debug badge URL"
  id: badge
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "test with spaces"
    message: "100%"
    color: "green"
    show-summary: "true"

- name: "Check generated URL"
  run: echo "Badge URL: ${{ steps.badge.outputs.badge-url }}"
```

#### Invalid Color Error

**Problem**: Action fails with color validation error

**Solution**: Use valid color formats:

```yaml
# ✅ Valid colors
color: "brightgreen"        # Named color
color: "#00ff00"           # Hex color
color: "rgb(0,255,0)"      # RGB color
color: "hsl(120,100%,50%)" # HSL color

# ❌ Invalid colors
color: "bright-green"      # Invalid name
color: "00ff00"           # Missing #
color: "green!"           # Invalid character
```

#### File Not Saved

**Problem**: Output file not created despite setting `output-file`

**Solution**: Verify directory structure and permissions:

```yaml
- name: "Create badge directory"
  run: mkdir -p ./badges

- name: "Generate badge with file output"
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "status"
    message: "active"
    color: "green"
    output-file: "./badges/status.md"
    output-format: "markdown"

- name: "Verify file creation"
  run: ls -la ./badges/
```

#### Logo Not Showing

**Problem**: Logo parameter ignored or not displaying

**Solution**: Verify logo slug from Simple Icons:

```yaml
- name: "Test logo badge"
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "test"
    message: "logo"
    color: "blue"
    logo: "github"  # Exact slug from simpleicons.org
    logo-color: "white"
    show-summary: "true"
```

### Debug Mode

Enable comprehensive debugging:

```yaml
- name: "Debug badge generation"
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "debug"
    message: "test"
    color: "blue"
    show-summary: "true"
  env:
    ACTIONS_STEP_DEBUG: true
```

## 🔧 Advanced Features

### Conditional Badge Colors

```yaml
- name: "Generate status badge with conditional color"
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "tests"
    message: ${{ env.TEST_STATUS }}
    color: ${{ env.TEST_STATUS == 'passing' && 'brightgreen' || 'red' }}
    logo: "github-actions"
```

### Badge Caching

```yaml
- name: "Generate cached badge"
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "build"
    message: "stable"
    color: "blue"
    cache-seconds: "86400"  # Cache for 24 hours
```

### SVG Content Manipulation

```yaml
- name: "Generate and modify SVG badge"
  id: svg-badge
  uses: laerdal/github_actions/generate-badge@main
  with:
    label: "custom"
    message: "badge"
    color: "blue"
    output-format: "svg"

- name: "Customize SVG content"
  run: |
    # Modify SVG content for custom styling
    echo '${{ steps.svg-badge.outputs.svg-content }}' | \
      sed 's/fill="#4c1"/fill="#ff0000"/g' > custom-badge.svg
```

## 📄 License

This action is part of the GitHub Actions collection by Francois Raminosona.

---

> 💡 **Tip**: Use this action to create comprehensive badge sets that automatically update based on your CI/CD pipeline results.
