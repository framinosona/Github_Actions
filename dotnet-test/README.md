# 🧪 .NET Test Action

A comprehensive GitHub Action for running .NET tests with advanced configuration support, including test filtering, code coverage, blame analysis, and multiple output formats.

## ✨ Features

- 🧪 **Comprehensive Test Execution** - Full support for all .NET test frameworks
- 🔍 **Advanced Test Filtering** - Filter tests by name, category, traits, and expressions
- 📊 **Multiple Output Formats** - TRX, JUnit, Console, and custom logger support
- 📈 **Code Coverage Integration** - Built-in support for coverage data collection
- 🐛 **Blame Analysis** - Isolate problematic tests with crash and hang detection
- ⚙️ **Environment Control** - Custom environment variables and runtime configuration
- 🎯 **Framework Targeting** - Test against specific .NET frameworks and runtimes
- 📁 **Artifact Management** - Flexible output and test result organization
- 🔧 **Build Control** - Independent build and restore configuration
- 📋 **Detailed Reporting** - Comprehensive summaries and execution metrics

## 🚀 Basic Usage

Run tests with default settings:

```yaml
- name: "Run tests"
  uses: laerdal/github_actions/dotnet-test@main
  with:
    projects: "./tests/**/*.csproj"
```

```yaml
- name: "Run tests with coverage"
  uses: laerdal/github_actions/dotnet-test@main
  with:
    projects: "./tests/**/*.csproj"
    collect: "XPlat Code Coverage"
    results-directory: "./test-results"
```

```yaml
- name: "Run filtered tests"
  uses: laerdal/github_actions/dotnet-test@main
  with:
    projects: "./tests/**/*.csproj"
    filter: "Category=Unit&Priority=High"
    logger: "trx;LogFileName=unit-tests.trx"
```

## 🔧 Advanced Usage

Full configuration with all available options:

```yaml
- name: "Advanced test execution"
  uses: laerdal/github_actions/dotnet-test@main
  with:
    projects: "./tests/**/*.csproj"
    configuration: "Release"
    framework: "net8.0"
    runtime: "linux-x64"
    no-build: "false"
    no-restore: "false"
    filter: "Category=Integration|Category=Unit"
    test-adapter-path: "./tools/adapters"
    logger: "trx;LogFileName=test-results.trx;html;LogFileName=test-report.html"
    output: "./bin/tests"
    diag: "./logs/test-diagnostics.log"
    results-directory: "./test-results"
    collect: "XPlat Code Coverage;Format=opencover"
    settings: "./tests/test.runsettings"
    list-tests: "false"
    blame: "true"
    blame-crash: "true"
    blame-crash-dump-type: "full"
    blame-crash-collect-always: "true"
    blame-hang: "true"
    blame-hang-dump-type: "mini"
    blame-hang-timeout: "30m"
    environment: "TestEnvironment=CI;DATABASE_URL=test://localhost"
    interactive: "false"
    verbosity: "normal"
    working-directory: "./src"
    arch: "x64"
    os: "linux"
    tl: "true"
    show-summary: "true"
```

## 🔐 Permissions Required

This action requires standard repository permissions:

```yaml
permissions:
  contents: read  # Required to checkout repository code
```

## 🏗️ CI/CD Example

Complete workflow for comprehensive testing:

```yaml
name: "Test Suite"

on:
  push:
    branches: ["main", "develop"]
  pull_request:
    branches: ["main"]

permissions:
  contents: read
  checks: write  # For test result publishing

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        framework: ["net6.0", "net8.0"]
        configuration: ["Debug", "Release"]

    steps:
      - name: "📥 Checkout repository"
        uses: actions/checkout@v4

      - name: "🔧 Setup .NET"
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: |
            6.0.x
            8.0.x

      - name: "📦 Restore dependencies"
        uses: laerdal/github_actions/dotnet@main
        with:
          command: "restore"

      - name: "🔨 Build projects"
        uses: laerdal/github_actions/dotnet@main
        with:
          command: "build"
          configuration: ${{ matrix.configuration }}
          framework: ${{ matrix.framework }}
          no-restore: "true"

      - name: "🧪 Run unit tests"
        id: unit-tests
        uses: laerdal/github_actions/dotnet-test@main
        with:
          projects: "./tests/unit/**/*.csproj"
          configuration: ${{ matrix.configuration }}
          framework: ${{ matrix.framework }}
          no-build: "true"
          filter: "Category=Unit"
          logger: "trx;LogFileName=unit-tests-${{ matrix.framework }}.trx"
          collect: "XPlat Code Coverage"
          results-directory: "./test-results/unit"
          blame: "true"
          blame-hang: "true"
          blame-hang-timeout: "10m"

      - name: "🔗 Run integration tests"
        id: integration-tests
        uses: laerdal/github_actions/dotnet-test@main
        with:
          projects: "./tests/integration/**/*.csproj"
          configuration: ${{ matrix.configuration }}
          framework: ${{ matrix.framework }}
          no-build: "true"
          filter: "Category=Integration"
          logger: "trx;LogFileName=integration-tests-${{ matrix.framework }}.trx"
          results-directory: "./test-results/integration"
          environment: "DATABASE_CONNECTION=test://localhost;API_BASE_URL=http://localhost:8080"
          blame: "true"
          blame-hang: "true"
          blame-hang-timeout: "30m"

      - name: "📊 Publish test results"
        if: always()
        uses: dorny/test-reporter@v1
        with:
          name: "Test Results (${{ matrix.framework }}, ${{ matrix.configuration }})"
          path: "./test-results/**/*.trx"
          reporter: "dotnet-trx"

      - name: "📈 Upload coverage reports"
        uses: codecov/codecov-action@v4
        with:
          directory: "./test-results"
          flags: unittests
          name: "${{ matrix.framework }}-${{ matrix.configuration }}"
```

## 📋 Inputs

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `projects` | Path to test projects or solution | ❌ No | `""` | `./tests/**/*.csproj`, `TestSolution.sln` |
| `configuration` | Build configuration | ❌ No | `"Debug"` | `Debug`, `Release`, `Custom` |
| `framework` | Target framework | ❌ No | `""` | `net8.0`, `net6.0`, `netcoreapp3.1` |
| `runtime` | Target runtime identifier | ❌ No | `""` | `linux-x64`, `win-x64`, `osx-x64` |
| `no-build` | Skip building before testing | ❌ No | `"false"` | `true`, `false` |
| `no-restore` | Skip restoring before testing | ❌ No | `"false"` | `true`, `false` |
| `filter` | Test filter expression | ❌ No | `""` | `Category=Unit`, `Name~Integration` |
| `test-adapter-path` | Path to test adapters | ❌ No | `""` | `./tools/adapters` |
| `logger` | Test logger configuration | ❌ No | `""` | `trx;LogFileName=results.trx`, `console;verbosity=detailed` |
| `output` | Output directory | ❌ No | `""` | `./bin/tests`, `./output` |
| `diag` | Diagnostic log file path | ❌ No | `""` | `./logs/test-diag.log` |
| `results-directory` | Test results directory | ❌ No | `""` | `./test-results`, `./reports` |
| `collect` | Data collection settings | ❌ No | `""` | `XPlat Code Coverage`, `Code Coverage` |
| `settings` | Run settings file path | ❌ No | `""` | `./test.runsettings`, `./config/tests.runsettings` |
| `list-tests` | List available tests without running | ❌ No | `"false"` | `true`, `false` |
| `blame` | Enable blame mode | ❌ No | `"false"` | `true`, `false` |
| `blame-crash` | Enable crash dump collection | ❌ No | `"false"` | `true`, `false` |
| `blame-crash-dump-type` | Crash dump type | ❌ No | `"mini"` | `mini`, `full` |
| `blame-crash-collect-always` | Always collect crash dumps | ❌ No | `"false"` | `true`, `false` |
| `blame-hang` | Enable hang detection | ❌ No | `"false"` | `true`, `false` |
| `blame-hang-dump-type` | Hang dump type | ❌ No | `"mini"` | `mini`, `full` |
| `blame-hang-timeout` | Hang detection timeout | ❌ No | `"1h"` | `30m`, `1h`, `2h` |
| `environment` | Environment variables | ❌ No | `""` | `VAR1=value1;VAR2=value2` |
| `interactive` | Enable interactive mode | ❌ No | `"false"` | `true`, `false` |
| `verbosity` | Logging verbosity | ❌ No | `"normal"` | `quiet`, `minimal`, `normal`, `detailed`, `diagnostic` |
| `working-directory` | Working directory | ❌ No | `"."` | `./src`, `./tests` |
| `arch` | Target architecture | ❌ No | `""` | `x64`, `x86`, `arm64` |
| `os` | Target operating system | ❌ No | `""` | `linux`, `windows`, `osx` |
| `tl` | Enable test logger | ❌ No | `"false"` | `true`, `false` |
| `show-summary` | Display action summary | ❌ No | `"false"` | `true`, `false` |

## 📤 Outputs

| Output | Description | Type | Example |
|--------|-------------|------|---------|
| `exit-code` | Exit code of the test command | `string` | `0`, `1` |
| `executed-command` | Full command that was executed | `string` | `dotnet test ./tests --configuration Release` |
| `tests-total` | Total number of tests discovered | `string` | `156` |
| `tests-passed` | Number of tests that passed | `string` | `145` |
| `tests-failed` | Number of tests that failed | `string` | `8` |
| `tests-skipped` | Number of tests that were skipped | `string` | `3` |
| `execution-time` | Total test execution time | `string` | `42.5s` |
| `results-path` | Path to test results directory | `string` | `./test-results` |

## 🔗 Related Actions

| Action | Purpose | Repository |
|--------|---------|------------|
| 🚀 **dotnet** | Execute .NET CLI commands | `laerdal/github_actions/dotnet` |
| 📊 **generate-badge** | Generate test result badges | `laerdal/github_actions/generate-badge` |
| 🔧 **dotnet-tool-install** | Install .NET tools | `laerdal/github_actions/dotnet-tool-install` |

## 💡 Examples

### Unit Tests with Coverage

```yaml
- name: "Run unit tests with coverage"
  uses: laerdal/github_actions/dotnet-test@main
  with:
    projects: "./tests/unit/**/*.csproj"
    filter: "Category=Unit"
    collect: "XPlat Code Coverage;Format=opencover"
    logger: "trx;LogFileName=unit-tests.trx"
    results-directory: "./coverage"
```

### Integration Tests with Environment

```yaml
- name: "Run integration tests"
  uses: laerdal/github_actions/dotnet-test@main
  with:
    projects: "./tests/integration/**/*.csproj"
    filter: "Category=Integration"
    environment: "DATABASE_URL=test://localhost;API_KEY=test-key"
    blame: "true"
    blame-hang: "true"
    blame-hang-timeout: "20m"
```

### Matrix Testing Across Frameworks

```yaml
strategy:
  matrix:
    framework: ["net6.0", "net8.0"]
    os: ["ubuntu-latest", "windows-latest"]

steps:
  - name: "Test on ${{ matrix.framework }}"
    uses: laerdal/github_actions/dotnet-test@main
    with:
      projects: "./tests/**/*.csproj"
      framework: ${{ matrix.framework }}
      configuration: "Release"
      logger: "trx;LogFileName=tests-${{ matrix.framework }}-${{ matrix.os }}.trx"
```

### Blame Mode for Debugging

```yaml
- name: "Run tests with blame analysis"
  uses: laerdal/github_actions/dotnet-test@main
  with:
    projects: "./tests/**/*.csproj"
    blame: "true"
    blame-crash: "true"
    blame-crash-dump-type: "full"
    blame-crash-collect-always: "true"
    blame-hang: "true"
    blame-hang-timeout: "15m"
    diag: "./logs/test-diagnostics.log"
```

### Performance and Load Tests

```yaml
- name: "Run performance tests"
  uses: laerdal/github_actions/dotnet-test@main
  with:
    projects: "./tests/performance/**/*.csproj"
    filter: "Category=Performance"
    configuration: "Release"
    environment: "DOTNET_TieredCompilation=1;DOTNET_ReadyToRun=0"
    blame-hang: "true"
    blame-hang-timeout: "1h"
```

## 📊 Test Filtering

### Filter Expression Examples

| Filter | Description | Example Tests |
|--------|-------------|---------------|
| `Category=Unit` | Tests with Unit category | Unit tests only |
| `Priority=High` | High priority tests | Critical functionality |
| `Name~Integration` | Tests with "Integration" in name | Integration test methods |
| `FullyQualifiedName~MyNamespace` | Tests in specific namespace | Namespace-specific tests |
| `TestCategory!=Slow` | Exclude slow tests | Fast-running tests only |
| `Category=Unit&Priority=High` | Multiple conditions (AND) | High priority unit tests |
| `Category=Unit\|Category=Integration` | Multiple conditions (OR) | Unit or integration tests |

### Trait-Based Filtering

```yaml
filter: "TestCategory=Fast&Owner=TeamA"
```

```yaml
filter: "Category!=Slow&Category!=Manual"
```

## 📈 Code Coverage Options

### Coverage Collectors

| Collector | Description | Output Format |
|-----------|-------------|---------------|
| `XPlat Code Coverage` | Cross-platform coverage | Cobertura XML |
| `Code Coverage` | Windows-specific coverage | .coverage files |
| `coverlet.collector` | Coverlet-based collection | Multiple formats |

### Coverage Configuration

```yaml
collect: "XPlat Code Coverage;Format=cobertura,opencover;Include=[*]*;Exclude=[*.Tests]*"
```

## 🐛 Troubleshooting

### Common Issues

#### Tests Not Found

**Problem**: No tests discovered in specified projects

**Solution**: Verify project paths and test framework references:

```yaml
- name: "List test projects"
  run: find . -name "*.csproj" -exec grep -l "Microsoft.NET.Test.Sdk" {} \;

- name: "Run tests"
  uses: laerdal/github_actions/dotnet-test@main
  with:
    projects: "./tests/**/*.csproj"
    list-tests: "true"
```

#### Build Failures Before Tests

**Problem**: Projects fail to build before testing

**Solution**: Ensure dependencies are restored and build separately:

```yaml
- name: "Restore dependencies"
  uses: laerdal/github_actions/dotnet@main
  with:
    command: "restore"

- name: "Build projects"
  uses: laerdal/github_actions/dotnet@main
  with:
    command: "build"
    configuration: "Release"

- name: "Run tests"
  uses: laerdal/github_actions/dotnet-test@main
  with:
    projects: "./tests/**/*.csproj"
    no-build: "true"
    configuration: "Release"
```

#### Hanging Tests

**Problem**: Tests hang or run indefinitely

**Solution**: Enable blame mode with hang detection:

```yaml
- name: "Run tests with hang detection"
  uses: laerdal/github_actions/dotnet-test@main
  with:
    projects: "./tests/**/*.csproj"
    blame: "true"
    blame-hang: "true"
    blame-hang-timeout: "10m"
    verbosity: "diagnostic"
```

#### Coverage Collection Issues

**Problem**: Code coverage data is not collected

**Solution**: Verify coverage collector configuration:

```yaml
- name: "Run tests with coverage"
  uses: laerdal/github_actions/dotnet-test@main
  with:
    projects: "./tests/**/*.csproj"
    collect: "XPlat Code Coverage"
    results-directory: "./coverage"

- name: "Verify coverage files"
  run: find ./coverage -name "*.xml" -o -name "*.json"
```

### Debug Tips

1. **Enable Diagnostic Logging**: Set `verbosity: "diagnostic"`
2. **Use Blame Mode**: Enable `blame` for crash analysis
3. **Save Diagnostic Logs**: Use `diag` to capture detailed logs
4. **List Tests First**: Use `list-tests: "true"` to verify test discovery

## 📝 Requirements

- GitHub Actions runner (Windows, Linux, or macOS)
- .NET SDK installed (use `actions/setup-dotnet`)
- Test projects with test framework references
- Optional: Test settings file (.runsettings)

## 🔧 Advanced Features

### Custom Run Settings

```xml
<!-- test.runsettings -->
<?xml version="1.0" encoding="utf-8"?>
<RunSettings>
  <RunConfiguration>
    <MaxCpuCount>2</MaxCpuCount>
    <ResultsDirectory>./test-results</ResultsDirectory>
  </RunConfiguration>
  <DataCollectionRunSettings>
    <DataCollectors>
      <DataCollector friendlyName="XPlat code coverage" />
    </DataCollectors>
  </DataCollectionRunSettings>
</RunSettings>
```

### Multi-Framework Testing

```yaml
- name: "Test multiple frameworks"
  uses: laerdal/github_actions/dotnet-test@main
  with:
    projects: "./tests/**/*.csproj"
    framework: "net6.0;net8.0"
    configuration: "Release"
```

## 📄 License

This action is part of the GitHub Actions collection by Francois Raminosona.

---

> 💡 **Tip**: Combine this action with our build and coverage reporting actions for complete CI/CD test workflows.
