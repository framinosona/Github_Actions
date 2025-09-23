# 🚀 Run .NET Command Action

A comprehensive GitHub Action that runs .NET commands with automatic verbosity handling, intelligent argument parsing, and smart option detection based on command compatibility.

## Features

- 🚀 **Smart Command Execution** - Automatically detects which options are supported by each .NET command
- 🔧 **Auto-Verbosity Detection** - Adjusts verbosity based on debug settings or manual override
- 📋 **Flexible Arguments** - Supports both string and YAML array formats for complex arguments
- 🎯 **Command Validation** - Comprehensive input validation with helpful error messages
- ⚡ **Performance Optimized** - Cached command support maps for fast execution
- 📊 **Detailed Reporting** - Rich summaries with execution metrics and applied options
- 🛡️ **Cross-Platform** - Works on Windows, Linux, and macOS runners

## Usage

### Basic Usage

```yaml
- name: Build project
  uses: framinosona/Github_Actions/dotnet@main
  with:
    command: 'build'
```

### Build with Configuration

```yaml
- name: Build release
  uses: framinosona/Github_Actions/dotnet@main
  with:
    command: 'build'
    configuration: 'Release'
    path: './src/MyProject.csproj'
```

### Run Tests

```yaml
- name: Run tests
  uses: framinosona/Github_Actions/dotnet@main
  with:
    command: 'test'
    framework: 'net8.0'
    no-build: 'true'
    arguments: '--collect:"XPlat Code Coverage"'
```

### Complex Arguments with YAML Array

```yaml
- name: Publish with complex arguments
  uses: framinosona/Github_Actions/dotnet@main
  with:
    command: 'publish'
    path: './src/WebApp.csproj'
    configuration: 'Release'
    runtime: 'linux-x64'
    arguments: |
      - --self-contained
      - --output
      - ./publish
      - /p:PublishSingleFile=true
      - /p:IncludeNativeLibrariesForSelfExtract=true
```

### Custom Working Directory

```yaml
- name: Restore packages
  uses: framinosona/Github_Actions/dotnet@main
  with:
    command: 'restore'
    working-directory: './backend'
    force-verbosity: 'detailed'
```

### Complete CI/CD Workflow

```yaml
name: .NET CI/CD Pipeline
on: [push, pull_request]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'

      - name: Restore dependencies
        id: restore
        uses: framinosona/Github_Actions/dotnet@main
        with:
          command: 'restore'

      - name: Build solution
        uses: framinosona/Github_Actions/dotnet@main
        with:
          command: 'build'
          configuration: 'Release'
          no-restore: 'true'

      - name: Run unit tests
        uses: framinosona/Github_Actions/dotnet@main
        with:
          command: 'test'
          configuration: 'Release'
          no-build: 'true'
          arguments: '--collect:"XPlat Code Coverage" --logger trx'

      - name: Publish application
        if: github.ref == 'refs/heads/main'
        uses: framinosona/Github_Actions/dotnet@main
        with:
          command: 'publish'
          path: './src/WebApp/WebApp.csproj'
          configuration: 'Release'
          runtime: 'linux-x64'
          output: './dist'

      - name: Show execution details
        run: |
          echo "Exit code: ${{ steps.restore.outputs.exit-code }}"
```

## Inputs

| Input | Description | Required | Default | Example |
|-------|-------------|----------|---------|---------|
| `command` | The dotnet command to run | `true` | - | `build`, `test`, `restore`, `publish` |
| `path` | Path to project/solution file or directory | `false` | `''` | `./src/MyProject.csproj`, `./MySolution.sln` |
| `arguments` | Additional arguments (string or YAML array) | `false` | `''` | `--no-dependencies`, see examples below |
| `working-directory` | Working directory for the command | `false` | `.` | `./backend`, `./src` |
| `force-verbosity` | Force specific verbosity level | `false` | `''` | `quiet`, `minimal`, `normal`, `detailed`, `diagnostic` |
| `configuration` | Build configuration | `false` | `Release` | `Debug`, `Release` |
| `no-logo` | Suppress Microsoft logo and startup info | `false` | `true` | `true`, `false` |
| `framework` | Target framework | `false` | `''` | `net8.0`, `net6.0`, `netstandard2.1` |
| `runtime` | Target runtime | `false` | `''` | `win-x64`, `linux-x64`, `osx-arm64` |
| `no-restore` | Skip automatic restore | `false` | `false` | `true`, `false` |
| `no-build` | Skip building before running | `false` | `false` | `true`, `false` |
| `output` | Output directory path | `false` | `''` | `./bin`, `./publish` |
| `show-summary` | Whether to show action summary | `false` | `true` | `true`, `false` |

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `exit-code` | Exit code of the dotnet command | `0`, `1` |
| `executed-command` | The actual command that was executed | `dotnet build --configuration Release --verbosity minimal` |

## Command Support Matrix

The action automatically detects which options are supported by each .NET command:

| Command | Verbosity | Configuration | Framework | Runtime | No-Restore | No-Build | Output | No-Logo |
|---------|-----------|---------------|-----------|---------|------------|----------|--------|---------|
| `build` | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| `restore` | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| `test` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ |
| `publish` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `pack` | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| `run` | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ |
| `clean` | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |

## Verbosity Levels

The action automatically adjusts verbosity based on:

1. **Manual Override**: When `force-verbosity` is specified
2. **Debug Mode**: Uses `detailed` when `ACTIONS_STEP_DEBUG` or `ACTIONS_RUNNER_DEBUG` is `true`
3. **Default**: Uses `minimal` for normal operations

Available verbosity levels:
- `quiet` - Minimal output
- `minimal` - Essential information only
- `normal` - Standard output
- `detailed` - Verbose output with additional details
- `diagnostic` - Maximum verbosity for troubleshooting

## Argument Formats

### String Format (Simple)
```yaml
arguments: '--no-dependencies --force'
```

### YAML Array Format (Complex)
```yaml
arguments: |
  - --no-dependencies
  - --force
  - --property:Configuration=Release
  - /p:Version=1.0.0
```

### Mixed Examples
```yaml
# Package with version and symbols
arguments: |
  - --include-symbols
  - --include-source
  - /p:PackageVersion=1.2.3

# Test with coverage and filters
arguments: '--collect:"XPlat Code Coverage" --filter "TestCategory=Unit"'

# Publish self-contained
arguments: |
  - --self-contained
  - /p:PublishSingleFile=true
  - /p:PublishTrimmed=true
```

## Examples

### Building Different Configurations

```yaml
- name: Build Debug
  uses: framinosona/Github_Actions/dotnet@main
  with:
    command: 'build'
    configuration: 'Debug'

- name: Build Release
  uses: framinosona/Github_Actions/dotnet@main
  with:
    command: 'build'
    configuration: 'Release'
```

### Multi-Framework Testing

```yaml
- name: Test .NET 6.0
  uses: framinosona/Github_Actions/dotnet@main
  with:
    command: 'test'
    framework: 'net6.0'

- name: Test .NET 8.0
  uses: framinosona/Github_Actions/dotnet@main
  with:
    command: 'test'
    framework: 'net8.0'
```

### Cross-Platform Publishing

```yaml
- name: Publish for Windows
  uses: framinosona/Github_Actions/dotnet@main
  with:
    command: 'publish'
    runtime: 'win-x64'
    output: './dist/win'

- name: Publish for Linux
  uses: framinosona/Github_Actions/dotnet@main
  with:
    command: 'publish'
    runtime: 'linux-x64'
    output: './dist/linux'

- name: Publish for macOS
  uses: framinosona/Github_Actions/dotnet@main
  with:
    command: 'publish'
    runtime: 'osx-arm64'
    output: './dist/macos'
```

### NuGet Package Creation

```yaml
- name: Create NuGet package
  uses: framinosona/Github_Actions/dotnet@main
  with:
    command: 'pack'
    path: './src/MyLibrary/MyLibrary.csproj'
    configuration: 'Release'
    output: './packages'
    arguments: |
      - --include-symbols
      - --include-source
      - /p:PackageVersion=1.0.0
      - /p:Authors="My Name"
      - /p:Description="My awesome library"
```

### Performance Testing

```yaml
- name: Run performance tests
  uses: framinosona/Github_Actions/dotnet@main
  with:
    command: 'test'
    path: './tests/PerformanceTests'
    configuration: 'Release'
    arguments: |
      - --filter
      - TestCategory=Performance
      - --logger
      - console;verbosity=detailed
```

## Requirements

- GitHub Actions runner (Windows, Linux, or macOS)
- .NET SDK installed (use `actions/setup-dotnet` first)
- Valid .NET project or solution structure
- Bash shell (available on all GitHub runners)

## Troubleshooting

### Common Issues

#### Command not found
- **Problem**: `dotnet` command not found
- **Solution**: Ensure .NET SDK is installed using `actions/setup-dotnet` before running this action

#### Path not found
- **Problem**: Specified path does not exist
- **Solution**: Verify the path is correct and the file/directory exists in the repository

#### Invalid verbosity level
- **Problem**: Custom verbosity level not recognized
- **Solution**: Use one of the supported levels: `quiet`, `minimal`, `normal`, `detailed`, `diagnostic`

#### Build failures with complex arguments
- **Problem**: Arguments not parsed correctly
- **Solution**: Use YAML array format for complex arguments with special characters

#### Permission denied errors
- **Problem**: Cannot write to output directory
- **Solution**: Ensure the output directory is writable or use a different path

### Debug Tips

1. **Enable Debug Mode**: Set `ACTIONS_STEP_DEBUG: true` to see detailed command construction
2. **Check Outputs**: Use the `executed-command` output to see the exact command run
3. **Force Verbosity**: Use `force-verbosity: diagnostic` for maximum output
4. **Validate Paths**: Ensure all file and directory paths exist before running

### Example Debug Workflow

```yaml
- name: Debug dotnet command
  id: debug-run
  uses: framinosona/Github_Actions/dotnet@main
  with:
    command: 'build'
    force-verbosity: 'diagnostic'
  env:
    ACTIONS_STEP_DEBUG: true

- name: Show debug info
  run: |
    echo "Command executed: ${{ steps.debug-run.outputs.executed-command }}"
    echo "Exit code: ${{ steps.debug-run.outputs.exit-code }}"
```

## Advanced Usage

### Conditional Execution

```yaml
- name: Build only on main branch
  if: github.ref == 'refs/heads/main'
  uses: framinosona/Github_Actions/dotnet@main
  with:
    command: 'build'
    configuration: 'Release'
```

### Matrix Builds

```yaml
strategy:
  matrix:
    dotnet: ['6.0.x', '8.0.x']
    os: [ubuntu-latest, windows-latest, macos-latest]

steps:
  - name: Setup .NET ${{ matrix.dotnet }}
    uses: actions/setup-dotnet@v3
    with:
      dotnet-version: ${{ matrix.dotnet }}

  - name: Test on ${{ matrix.os }}
    uses: framinosona/Github_Actions/dotnet@main
    with:
      command: 'test'
      configuration: 'Release'
```

### Artifact Publishing

```yaml
- name: Publish artifacts
  uses: framinosona/Github_Actions/dotnet@main
  with:
    command: 'publish'
    output: './artifacts'

- name: Upload artifacts
  uses: actions/upload-artifact@v3
  with:
    name: published-app
    path: ./artifacts
```

## Contributing

When contributing to this action, please follow the established patterns:

1. **Input validation**: Always validate inputs in the first step
2. **Error handling**: Provide clear, actionable error messages
3. **Documentation**: Update examples and troubleshooting sections
4. **Testing**: Test with various input combinations using `framinosona/Github_Actions/dotnet@main`
5. **Consistency**: Follow the emoji and naming conventions

## License

This action is available under the same license as the repository.
