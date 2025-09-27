# 📦 Generate SBOM with gh-sbom Action

Generate Software Bill of Materials (SBOM) for GitHub repositories using the advanced-security/gh-sbom CLI extension.

## Features

- 📋 Generate SBOMs in SPDX or CycloneDX format
- 🔍 Support for any GitHub repository (current or specified)
- 📄 Optional license information inclusion for CycloneDX format
- 💾 Output to file or stdout
- 🛡️ Secure token handling with automatic masking
- 📊 Detailed component counting and reporting
- 🚀 Cross-platform support (Linux, macOS, Windows)
- ✅ Comprehensive input validation

## Usage

### Basic Usage (SPDX format)

Generate an SPDX SBOM for the current repository:

```yaml
- name: Generate SBOM
  uses: ./gh-sbom
```

### Generate CycloneDX SBOM with License Information

```yaml
- name: Generate CycloneDX SBOM
  uses: ./gh-sbom
  with:
    format: 'cyclonedx'
    include-license: 'true'
    output-file: 'sbom.json'
```

### Generate SBOM for Different Repository

```yaml
- name: Generate SBOM for specific repository
  uses: ./gh-sbom
  with:
    repository: 'owner/repo-name'
    format: 'spdx'
    output-file: 'dependency-sbom.json'
    show-summary: 'true'
```

### Advanced Usage with Custom Token

```yaml
- name: Generate SBOM with custom token
  uses: ./gh-sbom
  with:
    repository: 'advanced-security/gh-sbom'
    format: 'cyclonedx'
    include-license: 'true'
    output-file: 'reports/sbom-cyclonedx.json'
    github-token: ${{ secrets.CUSTOM_GITHUB_TOKEN }}
    show-summary: 'true'
```

## Inputs

| Input | Description | Required | Default | Valid Values |
|-------|-------------|----------|---------|--------------|
| `repository` | Repository to generate SBOM for (format: owner/repo). Uses current repository if not specified | `false` | `''` | Any valid GitHub repository |
| `format` | SBOM format to generate | `false` | `'spdx'` | `'spdx'`, `'cyclonedx'` |
| `include-license` | Include license information from clearlydefined.io for CycloneDX format (SPDX always includes license information) | `false` | `'false'` | `'true'`, `'false'` |
| `output-file` | Path to save the generated SBOM file. Outputs to stdout if not specified | `false` | `''` | Any valid file path |
| `github-token` | GitHub token for authentication. Uses GITHUB_TOKEN by default | `false` | `${{ github.token }}` | Valid GitHub token |
| `show-summary` | Whether to show the action summary | `false` | `'false'` | `'true'`, `'false'` |

## Outputs

| Output | Description | Example Value |
|--------|-------------|---------------|
| `sbom-format` | The format of the generated SBOM (spdx or cyclonedx) | `'spdx'` |
| `output-file` | Path to the generated SBOM file (if saved to file) | `'sbom.json'` |
| `component-count` | Number of components found in the SBOM | `42` |
| `exit-code` | Exit code of the gh-sbom command | `0` |

## Examples

### Workflow for Security Scanning

```yaml
name: Security - Generate SBOM

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  generate-sbom:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Generate SPDX SBOM
      uses: ./gh-sbom
      with:
        format: 'spdx'
        output-file: 'sbom-spdx.json'
        show-summary: 'true'

    - name: Generate CycloneDX SBOM with Licenses
      uses: ./gh-sbom
      with:
        format: 'cyclonedx'
        include-license: 'true'
        output-file: 'sbom-cyclonedx.json'
        show-summary: 'true'

    - name: Upload SBOM artifacts
      uses: actions/upload-artifact@v4
      with:
        name: sbom-reports
        path: |
          sbom-spdx.json
          sbom-cyclonedx.json
```

### Matrix Strategy for Multiple Formats

```yaml
name: Generate SBOMs

on:
  workflow_dispatch:
    inputs:
      repository:
        description: 'Repository to scan'
        required: true
        default: 'advanced-security/gh-sbom'

jobs:
  generate-sbom:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        format: ['spdx', 'cyclonedx']

    steps:
    - name: Generate SBOM - ${{ matrix.format }}
      uses: ./gh-sbom
      with:
        repository: ${{ github.event.inputs.repository }}
        format: ${{ matrix.format }}
        include-license: ${{ matrix.format == 'cyclonedx' && 'true' || 'false' }}
        output-file: 'sbom-${{ matrix.format }}.json'
        show-summary: 'true'
```

## Requirements

- **GitHub CLI (gh)**: Pre-installed on all GitHub-hosted runners
- **gh-sbom extension**: Automatically installed by the action
- **GitHub token**: Required for authentication (uses `GITHUB_TOKEN` by default)
- **Dependency Graph**: Must be enabled on the target repository
- **GitHub Enterprise Server**: Requires GHES 3.9 or higher (if using GHES)

### Repository Requirements

1. **Dependency Graph Enabled**: The target repository must have Dependency Graph enabled
   - Navigate to: `Settings → Security & analysis → Dependency graph`
   - Enable if not already active

2. **Supported Package Managers**: The repository should use supported package managers:
   - npm (JavaScript/Node.js)
   - pip (Python)
   - Maven (Java)
   - Go modules
   - RubyGems (Ruby)
   - GitHub Actions

## Format Specifications

### SPDX Format
- Uses the [Dependency Graph SBOM API](https://docs.github.com/en/rest/dependency-graph/sboms)
- Server-side generation (faster)
- Always includes license information
- Works with large repositories
- JSON format compliant with SPDX 2.3

### CycloneDX Format
- Assembled from Dependency Graph GraphQL API
- Client-side generation
- Optional license information from [ClearlyDefined](https://clearlydefined.io/)
- May not work with very large repositories
- JSON format compliant with CycloneDX 1.4

## Troubleshooting

### Common Issues

#### "No dependencies found" Error
```
If you own this repository, check if Dependency Graph is enabled:
https://github.com/owner/repo/settings/security_analysis
```

**Solution**: Enable Dependency Graph in repository settings.

#### Permission Errors
**Problem**: Action fails with authentication errors.

**Solutions**:
1. Ensure `GITHUB_TOKEN` has required permissions
2. For private repositories, use a token with `repo` scope
3. For organization repositories, ensure token has appropriate access

#### Large Repository Timeout
**Problem**: CycloneDX generation times out on large repositories.

**Solutions**:
1. Use SPDX format instead (server-side generation)
2. Consider running on a more powerful runner
3. Break down analysis by focusing on specific manifests

#### Installation Failures
**Problem**: GitHub CLI or extension installation fails.

**Solutions**:
1. Check runner OS compatibility
2. Verify network connectivity
3. Use a different runner image
4. Pre-install dependencies in your workflow

### Debug Information

Enable debug logging by setting:
```yaml
env:
  ACTIONS_STEP_DEBUG: true
```

This will provide detailed information about:
- Input validation steps
- Dependency installation progress
- Command construction and execution
- Component counting logic

### Error Codes

| Exit Code | Description |
|-----------|-------------|
| `0` | Success |
| `1` | General error (validation, authentication, etc.) |
| `2` | Network/API error |
| `3` | File system error |

## Comparison with Other SBOM Tools

| Feature | gh-sbom Action | Other Tools |
|---------|---------------|-------------|
| GitHub Integration | ✅ Native | ⚠️ Requires setup |
| Server-side Generation | ✅ SPDX format | ❌ Usually client-side |
| License Information | ✅ Built-in | ⚠️ Varies |
| Large Repositories | ✅ SPDX supports | ❌ Often limited |
| Multiple Formats | ✅ SPDX & CycloneDX | ⚠️ Usually single format |
| Zero Configuration | ✅ Works out-of-box | ❌ Requires configuration |

## Contributing

Issues and feature requests are welcome! Please check the [GitHub Issues](https://github.com/advanced-security/gh-sbom/issues) for the underlying tool.

## Related Actions

- [GitHub Security Actions](https://github.com/security)
- [Dependency Review Action](https://github.com/actions/dependency-review-action)
- [CodeQL Analysis](https://github.com/github/codeql-action)

## License

This action is provided under the same license terms as the repository.

## Support

- **Tool Issues**: [advanced-security/gh-sbom Issues](https://github.com/advanced-security/gh-sbom/issues)
- **Tool Discussions**: [advanced-security/gh-sbom Discussions](https://github.com/advanced-security/gh-sbom/discussions)
- **Action Issues**: Please file issues in this repository
