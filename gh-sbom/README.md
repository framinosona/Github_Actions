# 📦 GitHub SBOM Generation Action

A comprehensive GitHub Action for generating Software Bill of Materials (SBOM) using the advanced-security/gh-sbom CLI extension with support for multiple formats, licensing information, and enterprise integration.

## ✨ Features

- 📋 **Multiple SBOM Formats** - Generate SPDX or CycloneDX format SBOMs
- 🔍 **Repository Flexibility** - Support for any GitHub repository (current or specified)
- 📄 **License Information** - Optional license details from ClearlyDefined.io for CycloneDX
- 💾 **Flexible Output** - Output to file or stdout with multiple format options
- 🛡️ **Secure Token Handling** - Automatic token masking and secure authentication
- 📊 **Detailed Component Analysis** - Component counting and comprehensive reporting
- 🚀 **Cross-Platform Support** - Works on Linux, macOS, and Windows runners
- ✅ **Enterprise Ready** - Support for GitHub Enterprise Server and private repositories

## 🚀 Basic Usage

Generate an SPDX SBOM for the current repository:

```yaml
- name: "Generate SBOM"
  uses: laerdal/github_actions/gh-sbom@main
```

```yaml
- name: "Generate CycloneDX SBOM with licenses"
  uses: laerdal/github_actions/gh-sbom@main
  with:
    format: "cyclonedx"
    include-license: "true"
    output-file: "sbom.json"
```

```yaml
- name: "Generate SBOM for specific repository"
  uses: laerdal/github_actions/gh-sbom@main
  with:
    repository: "owner/repo-name"
    format: "spdx"
    output-file: "dependency-sbom.json"
    show-summary: "true"
```

## 🔧 Advanced Usage

Full configuration with all available options:

```yaml
- name: "Advanced SBOM generation"
  uses: laerdal/github_actions/gh-sbom@main
  with:
    repository: "advanced-security/gh-sbom"
    format: "cyclonedx"
    include-license: "true"
    output-file: "reports/sbom-cyclonedx.json"
    github-token: ${{ secrets.CUSTOM_GITHUB_TOKEN }}
    show-summary: "true"
```

## 🔐 Permissions Required

This action requires standard repository permissions:

```yaml
permissions:
  contents: read    # Required to access repository and dependency graph
  security-events: read  # Required for dependency graph access
```

For private repositories or cross-repo access:

```yaml
permissions:
  contents: read
  security-events: read
  metadata: read
```

## 🏗️ CI/CD Example

Complete workflow for SBOM generation and security scanning:

```yaml
name: "Security - SBOM Generation"

on:
  push:
    branches: ["main"]
  pull_request:
    branches: ["main"]
  schedule:
    - cron: "0 6 * * 1"  # Weekly on Mondays

permissions:
  contents: read
  security-events: read

jobs:
  generate-sbom:
    runs-on: ubuntu-latest

    steps:
      - name: "📥 Checkout repository"
        uses: actions/checkout@v4

      - name: "📋 Generate SPDX SBOM"
        id: spdx-sbom
        uses: laerdal/github_actions/gh-sbom@main
        with:
          format: "spdx"
          output-file: "sbom-spdx.json"
          show-summary: "true"

      - name: "📋 Generate CycloneDX SBOM with licenses"
        id: cyclonedx-sbom
        uses: laerdal/github_actions/gh-sbom@main
        with:
          format: "cyclonedx"
          include-license: "true"
          output-file: "sbom-cyclonedx.json"
          show-summary: "true"

      - name: "📊 Report SBOM statistics"
        run: |
          echo "SPDX SBOM components: ${{ steps.spdx-sbom.outputs.component-count }}"
          echo "CycloneDX SBOM components: ${{ steps.cyclonedx-sbom.outputs.component-count }}"

      - name: "📁 Upload SBOM artifacts"
        uses: actions/upload-artifact@v4
        with:
          name: "sbom-reports-${{ github.sha }}"
          path: |
            sbom-spdx.json
            sbom-cyclonedx.json
            signed-sbom-spdx.json
          retention-days: 90
```

## 📋 Inputs

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `repository` | Repository to generate SBOM for (format: owner/repo) | ❌ No | `''` | `owner/repo-name`, `microsoft/vscode` |
| `format` | SBOM format to generate | ❌ No | `'spdx'` | `spdx`, `cyclonedx` |
| `include-license` | Include license information for CycloneDX format | ❌ No | `'false'` | `true`, `false` |
| `output-file` | Path to save the generated SBOM file | ❌ No | `''` | `sbom.json`, `./reports/sbom.spdx` |
| `github-token` | GitHub token for authentication | ❌ No | `${{ github.token }}` | `${{ secrets.GITHUB_TOKEN }}` |
| `show-summary` | Whether to show the action summary | ❌ No | `'false'` | `true`, `false` |

## 📤 Outputs

| Output | Description | Type | Example |
|--------|-------------|------|---------|
| `sbom-format` | Format of the generated SBOM | `string` | `spdx`, `cyclonedx` |
| `output-file` | Path to the generated SBOM file | `string` | `sbom.json` |
| `component-count` | Number of components found in the SBOM | `string` | `42` |
| `exit-code` | Exit code of the gh-sbom command | `string` | `0` |
| `file-size` | Size of generated SBOM file in bytes | `string` | `15728` |

## 🔗 Related Actions

| Action | Purpose | Repository |
|--------|---------|------------|
| 📋 **dotnet-cyclonedx** | Generate .NET SBOMs | `laerdal/github_actions/dotnet-cyclonedx` |
| 🛡️ **Security Actions** | GitHub security tooling | Various security actions |

## 💡 Examples

### Basic SBOM Generation

```yaml
- name: "Generate SPDX SBOM for current repo"
  uses: laerdal/github_actions/gh-sbom@main
  with:
    format: "spdx"
    output-file: "sbom.spdx.json"
```

### Multi-Format Generation

```yaml
- name: "Generate both SBOM formats"
  strategy:
    matrix:
      format: ['spdx', 'cyclonedx']

  steps:
    - name: "Generate ${{ matrix.format }} SBOM"
      uses: laerdal/github_actions/gh-sbom@main
      with:
        format: ${{ matrix.format }}
        include-license: ${{ matrix.format == 'cyclonedx' && 'true' || 'false' }}
        output-file: "sbom-${{ matrix.format }}.json"
        show-summary: "true"
```

### Cross-Repository Analysis

```yaml
- name: "Analyze multiple repositories"
  strategy:
    matrix:
      repo:
        - "owner/repo1"
        - "owner/repo2"
        - "owner/repo3"

  steps:
    - name: "Generate SBOM for ${{ matrix.repo }}"
      uses: laerdal/github_actions/gh-sbom@main
      with:
        repository: ${{ matrix.repo }}
        format: "spdx"
        output-file: "sbom-${{ matrix.repo | replace('/', '-') }}.json"
        github-token: ${{ secrets.CROSS_REPO_TOKEN }}
```

### Enterprise Workflow

```yaml
- name: "Enterprise SBOM workflow"
  uses: laerdal/github_actions/gh-sbom@main
  with:
    repository: ${{ github.repository }}
    format: "cyclonedx"
    include-license: "true"
    output-file: "./compliance/sbom-cyclonedx.json"
    github-token: ${{ secrets.ENTERPRISE_GITHUB_TOKEN }}
    show-summary: "true"

- name: "Validate SBOM compliance"
  run: |
    # Custom validation logic for enterprise compliance
    jq '.components | length' ./compliance/sbom-cyclonedx.json

- name: "Archive for compliance"
  uses: actions/upload-artifact@v4
  with:
    name: "compliance-sbom-${{ github.run_id }}"
    path: ./compliance/sbom-cyclonedx.json
    retention-days: 2555  # 7 years for compliance
```

### Conditional SBOM Generation

```yaml
- name: "Check if SBOM generation needed"
  id: check-changes
  run: |
    if git diff --name-only HEAD~1 | grep -E '\.(csproj|sln|packages\.config|package\.json|requirements\.txt|go\.mod|Cargo\.toml)$'; then
      echo "needs-sbom=true" >> $GITHUB_OUTPUT
    else
      echo "needs-sbom=false" >> $GITHUB_OUTPUT
    fi

- name: "Generate SBOM on dependency changes"
  if: steps.check-changes.outputs.needs-sbom == 'true'
  uses: laerdal/github_actions/gh-sbom@main
  with:
    format: "spdx"
    output-file: "updated-sbom.json"
    show-summary: "true"
```

## 📊 Format Specifications

### SPDX Format

- **API Source**: [Dependency Graph SBOM API](https://docs.github.com/en/rest/dependency-graph/sboms)
- **Generation**: Server-side (faster performance)
- **License Information**: Always included
- **Repository Size**: Works with large repositories
- **Format Version**: SPDX 2.3 compliant JSON
- **Best For**: Production workflows, large repositories, enterprise use

### CycloneDX Format

- **API Source**: Dependency Graph GraphQL API
- **Generation**: Client-side assembly
- **License Information**: Optional from [ClearlyDefined](https://clearlydefined.io/)
- **Repository Size**: May have limitations with very large repositories
- **Format Version**: CycloneDX 1.4 compliant JSON
- **Best For**: Detailed license analysis, smaller repositories, development workflows

## 📋 Requirements

### GitHub CLI and Extension

- **GitHub CLI (gh)**: Pre-installed on all GitHub-hosted runners
- **gh-sbom extension**: Automatically installed by the action
- **Version Compatibility**: Latest stable versions

### Repository Requirements

1. **Dependency Graph Enabled**: Target repository must have Dependency Graph enabled
   - Navigate to: `Settings → Security & analysis → Dependency graph`
   - Enable if not already active

2. **Supported Package Managers**:
   - npm (JavaScript/Node.js)
   - pip (Python)
   - Maven (Java)
   - Go modules
   - RubyGems (Ruby)
   - GitHub Actions
   - .NET NuGet packages

### Authentication Requirements

- **GitHub Token**: Required for authentication (uses `GITHUB_TOKEN` by default)
- **Private Repositories**: Token needs `repo` scope
- **Cross-Repository**: Token needs access to target repositories
- **Enterprise**: Compatible with GitHub Enterprise Server 3.9+

## 🐛 Troubleshooting

### Common Issues

#### Dependency Graph Not Enabled

**Problem**: No dependencies found error

```text
If you own this repository, check if Dependency Graph is enabled:
https://github.com/owner/repo/settings/security_analysis
```

**Solution**: Enable Dependency Graph in repository settings:

```yaml
- name: "Check dependency graph status"
  run: |
    echo "Verify Dependency Graph is enabled at:"
    echo "https://github.com/${{ github.repository }}/settings/security_analysis"
```

#### Permission Errors

**Problem**: Action fails with authentication errors

**Solutions**:

1. Ensure `GITHUB_TOKEN` has required permissions:

```yaml
permissions:
  contents: read
  security-events: read
  metadata: read
```

1. For private repositories, use a token with `repo` scope:

```yaml
- name: "Generate SBOM for private repo"
  uses: laerdal/github_actions/gh-sbom@main
  with:
    repository: "private-org/private-repo"
    github-token: ${{ secrets.PRIVATE_REPO_TOKEN }}
```

#### Large Repository Timeouts

**Problem**: CycloneDX generation times out on large repositories

**Solutions**:

1. Use SPDX format instead:

```yaml
- name: "Generate SBOM for large repo"
  uses: laerdal/github_actions/gh-sbom@main
  with:
    format: "spdx"  # Server-side generation
    output-file: "large-repo-sbom.json"
```

1. Consider running on more powerful runners:

```yaml
runs-on: ubuntu-latest-8-cores  # Use larger runner
```

#### Extension Installation Failures

**Problem**: GitHub CLI or extension installation fails

**Solutions**:

1. Check runner OS compatibility and network connectivity

2. Pre-install dependencies:

```yaml
- name: "Pre-install gh-sbom extension"
  run: |
    gh extension install advanced-security/gh-sbom
    gh sbom --version
```

#### No Components Found

**Problem**: SBOM generated but shows zero components

**Solutions**:

1. Verify supported package managers are in use
2. Check repository has manifest files (package.json, requirements.txt, etc.)
3. Ensure dependencies are committed to repository

```yaml
- name: "List package manifests"
  run: |
    find . -name "package.json" -o -name "requirements.txt" -o -name "*.csproj" -o -name "go.mod" | head -10
```

### Debug Mode

Enable comprehensive debugging:

```yaml
- name: "Debug SBOM generation"
  uses: laerdal/github_actions/gh-sbom@main
  with:
    format: "spdx"
    output-file: "debug-sbom.json"
    show-summary: "true"
  env:
    ACTIONS_STEP_DEBUG: true
    GH_DEBUG: true
```

### Error Codes

| Exit Code | Description | Action |
|-----------|-------------|--------|
| `0` | Success | Continue workflow |
| `1` | General error | Check inputs and permissions |
| `2` | Network/API error | Retry or check connectivity |
| `3` | File system error | Check file paths and permissions |

## 🔧 Advanced Configuration

### Enterprise GitHub Setup

```yaml
- name: "Generate SBOM on GitHub Enterprise"
  uses: laerdal/github_actions/gh-sbom@main
  with:
    repository: "enterprise-org/enterprise-repo"
    format: "spdx"
    output-file: "enterprise-sbom.json"
    github-token: ${{ secrets.GHES_TOKEN }}
  env:
    GH_HOST: "github.enterprise.com"
```

### Batch SBOM Generation

```yaml
- name: "Generate SBOMs for organization"
  run: |
    for repo in $(gh repo list myorg --json name --jq '.[].name'); do
      echo "Generating SBOM for myorg/$repo"

      gh sbom repo "myorg/$repo" --format spdx > "sbom-$repo.json" || echo "Failed for $repo"
    done
  env:
    GH_TOKEN: ${{ secrets.ORG_ACCESS_TOKEN }}
```

### Comparison Workflow

```yaml
- name: "Compare SBOM formats"
  run: |
    # Generate both formats
    gh sbom repo ${{ github.repository }} --format spdx > sbom-spdx.json
    gh sbom repo ${{ github.repository }} --format cyclonedx --include-license > sbom-cyclonedx.json

    # Compare component counts
    spdx_count=$(jq '.packages | length' sbom-spdx.json)
    cyclonedx_count=$(jq '.components | length' sbom-cyclonedx.json)

    echo "SPDX components: $spdx_count"
    echo "CycloneDX components: $cyclonedx_count"
```

## 📊 Comparison with Other SBOM Tools

| Feature | gh-sbom Action | Other Tools |
|---------|----------------|-------------|
| **GitHub Integration** | ✅ Native integration | ⚠️ Requires complex setup |
| **Server-side Generation** | ✅ SPDX format | ❌ Usually client-side only |
| **License Information** | ✅ Built-in support | ⚠️ Varies by tool |
| **Large Repositories** | ✅ SPDX supports any size | ❌ Often limited |
| **Multiple Formats** | ✅ SPDX & CycloneDX | ⚠️ Usually single format |
| **Zero Configuration** | ✅ Works out-of-box | ❌ Requires extensive setup |
| **Enterprise Support** | ✅ GitHub Enterprise ready | ⚠️ Limited enterprise features |

## 📄 License

This action is part of the GitHub Actions collection by Francois Raminosona.

---

> 💡 **Tip**: Combine this action with our SBOM signing and publishing actions for complete supply chain security workflows.
