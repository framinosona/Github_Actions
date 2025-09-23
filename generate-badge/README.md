# 🏷️ Generate Badge Action

A comprehensive GitHub Action that generates customizable static badges using shields.io with support for various styling options, logos, and output formats.

## Features

- 📋 **Flexible Badge Creation** - Support for label-message or message-only badges
- 🎨 **Comprehensive Styling** - Multiple styles, colors, and logo support
- 🔗 **Multiple Output Formats** - URL, Markdown, and HTML formats
- 📁 **File Output** - Optional file saving with custom paths
- ⚡ **Fast & Reliable** - Direct shields.io integration with proper URL encoding
- 🛡️ **Input Validation** - Comprehensive parameter validation and error handling
- 📊 **Detailed Summaries** - Rich action summaries with badge previews

## Usage

### Basic Usage

```yaml
- name: Generate simple badge
  uses: framinosona/Github_Actions/generate-badge@main
  with:
    message: 'passing'
    color: 'green'
```

### Badge with Label

```yaml
- name: Generate build status badge
  uses: framinosona/Github_Actions/generate-badge@main
  with:
    label: 'build'
    message: 'passing'
    color: 'brightgreen'
```

### Advanced Styling

```yaml
- name: Generate styled badge with logo
  uses: framinosona/Github_Actions/generate-badge@main
  with:
    label: 'npm'
    message: 'v1.2.3'
    color: 'blue'
    style: 'for-the-badge'
    logo: 'npm'
    logo-color: 'white'
```

### Save to File

```yaml
- name: Generate and save badge
  uses: framinosona/Github_Actions/generate-badge@main
  with:
    label: 'coverage'
    message: '95%'
    color: 'brightgreen'
    output-file: './badges/coverage.md'
    output-format: 'markdown'
```

### Complete Example Workflow

```yaml
name: Generate Project Badges
on: [push]

jobs:
  badges:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Generate build badge
        id: build-badge
        uses: framinosona/Github_Actions/generate-badge@main
        with:
          label: 'build'
          message: 'passing'
          color: 'brightgreen'
          style: 'flat-square'
          logo: 'github-actions'

      - name: Generate coverage badge
        uses: framinosona/Github_Actions/generate-badge@main
        with:
          label: 'coverage'
          message: '95%'
          color: 'green'
          output-file: './docs/coverage-badge.md'
          output-format: 'markdown'

      - name: Use badge URL in next step
        run: echo "Badge URL: ${{ steps.build-badge.outputs.badge-url }}"
```

## Inputs

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `label` | Left-hand side text of the badge | `false` | `''` | `build`, `coverage`, `npm` |
| `message` | Right-hand side text/message of the badge | `true` | - | `passing`, `95%`, `v1.2.3` |
| `color` | Background color of the right part | `false` | `blue` | `green`, `red`, `#ff6b6b`, `rgb(255,107,107)` |
| `label-color` | Background color of the left part | `false` | `''` | `grey`, `#555`, `rgba(85,85,85,1)` |
| `style` | Badge style | `false` | `flat` | `flat`, `flat-square`, `plastic`, `for-the-badge`, `social` |
| `logo` | Icon slug from simple-icons | `false` | `''` | `github`, `docker`, `node-dot-js`, `python` |
| `logo-color` | Color of the logo | `false` | `''` | `white`, `black`, `#ffffff` |
| `logo-size` | Logo size (set to "auto" for adaptive) | `false` | `''` | `auto` |
| `output-file` | File path to save the badge | `false` | `''` | `./badges/build.md`, `./docs/status.html` |
| `output-format` | Output format for file | `false` | `url` | `url`, `markdown`, `html` |
| `cache-seconds` | HTTP cache lifetime in seconds | `false` | `''` | `3600`, `86400` |
| `show-summary` | Whether to show action summary | `false` | `true` | `true`, `false` |

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `badge-url` | The generated shields.io badge URL | `https://img.shields.io/badge/build-passing-brightgreen` |
| `badge-markdown` | Badge in Markdown format | `![build: passing](https://img.shields.io/badge/build-passing-brightgreen)` |
| `badge-html` | Badge in HTML format | `<img src="..." alt="build: passing" />` |
| `output-file-path` | Path to the output file if created | `/github/workspace/badges/build.md` |

## Color Options

The action supports various color formats:

### Named Colors
- `brightgreen`, `green`, `yellowgreen`, `yellow`, `orange`, `red`, `lightgrey`, `blue`

### Hex Colors
- `#ff6b6b`, `#4ecdc4`, `#45b7d1`

### RGB/RGBA Colors
- `rgb(255,107,107)`, `rgba(255,107,107,0.8)`

### HSL/HSLA Colors
- `hsl(0,100%,50%)`, `hsla(0,100%,50%,0.8)`

## Style Examples

| Style | Preview | Description |
|-------|---------|-------------|
| `flat` | ![flat](https://img.shields.io/badge/style-flat-blue?style=flat) | Default flat style |
| `flat-square` | ![flat-square](https://img.shields.io/badge/style-flat--square-blue?style=flat-square) | Flat with square corners |
| `plastic` | ![plastic](https://img.shields.io/badge/style-plastic-blue?style=plastic) | Plastic 3D effect |
| `for-the-badge` | ![for-the-badge](https://img.shields.io/badge/style-for--the--badge-blue?style=for-the-badge) | Large, bold style |
| `social` | ![social](https://img.shields.io/badge/style-social-blue?style=social) | Social media style |

## Logo Support

The action supports logos from [Simple Icons](https://simpleicons.org/). Popular examples:

| Service | Logo Slug | Example |
|---------|-----------|---------|
| GitHub | `github` | ![GitHub](https://img.shields.io/badge/GitHub-black?logo=github) |
| Docker | `docker` | ![Docker](https://img.shields.io/badge/Docker-blue?logo=docker&logoColor=white) |
| Node.js | `node-dot-js` | ![Node.js](https://img.shields.io/badge/Node.js-green?logo=node-dot-js) |
| Python | `python` | ![Python](https://img.shields.io/badge/Python-blue?logo=python&logoColor=white) |
| TypeScript | `typescript` | ![TypeScript](https://img.shields.io/badge/TypeScript-blue?logo=typescript&logoColor=white) |

## URL Encoding

The action automatically handles URL encoding for special characters:

| Character | Encoding |
|-----------|----------|
| Space ` ` | `%20` or `_` |
| Underscore `_` | `__` |
| Dash `-` | `--` |

## Examples

### Build Status Badges

```yaml
# Success badge
- uses: framinosona/Github_Actions/generate-badge@main
  with:
    label: 'build'
    message: 'passing'
    color: 'brightgreen'
    logo: 'github-actions'

# Failure badge
- uses: framinosona/Github_Actions/generate-badge@main
  with:
    label: 'build'
    message: 'failing'
    color: 'red'
    logo: 'github-actions'
```

### Version Badges

```yaml
# NPM version
- uses: framinosona/Github_Actions/generate-badge@main
  with:
    label: 'npm'
    message: 'v1.2.3'
    color: 'blue'
    logo: 'npm'
    style: 'flat-square'

# Docker version
- uses: framinosona/Github_Actions/generate-badge@main
  with:
    label: 'docker'
    message: 'latest'
    color: 'blue'
    logo: 'docker'
    logo-color: 'white'
```

### Coverage Badges

```yaml
# High coverage
- uses: framinosona/Github_Actions/generate-badge@main
  with:
    label: 'coverage'
    message: '95%'
    color: 'brightgreen'

# Medium coverage
- uses: framinosona/Github_Actions/generate-badge@main
  with:
    label: 'coverage'
    message: '75%'
    color: 'yellow'

# Low coverage
- uses: framinosona/Github_Actions/generate-badge@main
  with:
    label: 'coverage'
    message: '45%'
    color: 'red'
```

### License Badges

```yaml
- uses: framinosona/Github_Actions/generate-badge@main
  with:
    label: 'license'
    message: 'MIT'
    color: 'blue'
    style: 'for-the-badge'
```

### Custom Styled Badges

```yaml
# Social media style
- uses: framinosona/Github_Actions/generate-badge@main
  with:
    label: 'follow'
    message: '@username'
    color: '1da1f2'
    style: 'social'
    logo: 'twitter'
    logo-color: 'white'

# For-the-badge style
- uses: framinosona/Github_Actions/generate-badge@main
  with:
    message: 'AWESOME'
    color: 'ff6b6b'
    style: 'for-the-badge'
```

## Requirements

- GitHub Actions runner (any OS: Windows, Linux, macOS)
- Internet access to reach shields.io
- Bash shell (available on all GitHub runners)

## Troubleshooting

### Common Issues

#### Badge not displaying correctly
- **Problem**: Badge shows broken image or incorrect text
- **Solution**: Check URL encoding of special characters. Spaces should be `%20` or `_`, underscores should be `__`

#### Invalid color error
- **Problem**: Action fails with color validation error
- **Solution**: Use valid color formats: named colors, hex (#ffffff), rgb(), rgba(), hsl(), or hsla()

#### File not saved
- **Problem**: Output file not created despite setting `output-file`
- **Solution**: Ensure the directory exists or the action will create it. Check file permissions.

#### Logo not showing
- **Problem**: Logo parameter ignored or not displaying
- **Solution**: Verify the logo slug exists at [Simple Icons](https://simpleicons.org/). Use exact slug names (e.g., `node-dot-js` not `nodejs`)

### Debug Tips

1. **Enable summary**: Set `show-summary: true` to see detailed parameter and result information
2. **Check outputs**: Use the action outputs in subsequent steps to verify generated URLs
3. **Test URLs**: Copy the generated badge URL and test it directly in a browser
4. **Validate inputs**: The action provides comprehensive input validation with clear error messages

### Example Debug Workflow

```yaml
- name: Debug badge generation
  id: debug-badge
  uses: framinosona/Github_Actions/generate-badge@main
  with:
    label: 'test'
    message: 'debug'
    color: 'blue'

- name: Show debug info
  run: |
    echo "Badge URL: ${{ steps.debug-badge.outputs.badge-url }}"
    echo "Markdown: ${{ steps.debug-badge.outputs.badge-markdown }}"
    echo "HTML: ${{ steps.debug-badge.outputs.badge-html }}"
```

## Contributing

When contributing to this action, please follow the established patterns:

1. **Input validation**: Always validate inputs in the first step
2. **Error handling**: Provide clear, actionable error messages
3. **Documentation**: Update examples and troubleshooting sections
4. **Testing**: Test with various input combinations
5. **Consistency**: Follow the emoji and naming conventions

## License

This action is available under the same license as the repository.
