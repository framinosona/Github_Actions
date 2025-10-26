# � Normalize Arguments Action

Normalizes arguments passed as multi-line or single-line strings into a clean, properly formatted argument string for command concatenation. Handles all YAML multi-line formats including literal (`|`), folded (`>`), and single-line arguments.

## Features

- � **Multi-format Support**: Handles literal (`|`), folded (`>`), and single-line argument formats
- ✂️ **Smart Trimming**: Removes empty lines and whitespace with configurable options
- 🔗 **Flexible Separation**: Customizable separator between arguments (space, comma, etc.)
- � **Detailed Outputs**: Provides normalized string, argument count, and empty status
- �️ **Input Validation**: Validates all inputs with helpful error messages
- � **Command Integration**: Perfect for building complex command lines from YAML inputs

## Usage

### Basic Usage

```yaml
- name: Normalize build arguments
  id: args
  uses: framinosona/github_actions/normalize-arguments@main
  with:
    arguments: |
      -p:Version_Props_Path=${{ github.workspace }}/${{ env.PROJECT_NAME }}.Output/Version/version.props
      -p:GeneratePackageOnBuild=true
      -p:PackageOutputPath=${{ github.workspace }}/${{ env.PROJECT_NAME }}.Output/Packages

- name: Build with normalized arguments
  run: |
    dotnet build ${{ steps.args.outputs.normalized }}
```

### Advanced Usage with Custom Separator

```yaml
- name: Normalize compiler flags
  id: flags
  uses: framinosona/github_actions/normalize-arguments@main
  with:
    arguments: >
      -Wall
      -Werror
      -O2
      -std=c++17
    separator: ' '
    show-summary: 'true'

- name: Compile with flags
  run: |
    gcc ${{ steps.flags.outputs.normalized }} main.c
    g++ ${{ steps.flags.outputs.normalized }} main.cpp -o app
```

### Single Argument Processing

```yaml
- name: Normalize single argument
  id: single
  uses: framinosona/github_actions/normalize-arguments@main
  with:
    arguments: '--nologo'

- name: Run command
  run: |
    myapp ${{ steps.single.outputs.normalized }}
    dotnet ${{ steps.single.outputs.normalized }} --version
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `arguments` | Arguments to normalize (supports single-line, multi-line with `\|`, or folded with `>`) - can be empty | ❌ No | ` ` (empty) |
| `separator` | Separator to use between normalized arguments | ❌ No | ` ` (space) |
| `show-summary` | Whether to show the action summary | ❌ No | `false` |

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `normalized` | The normalized arguments as a single string | `-p:Version=1.0.0 -p:Configuration=Release` |

## YAML Multi-line Format Examples

### Literal Block Scalar (`|`)
Preserves line breaks and leading whitespace:
```yaml
arguments: |
  -p:Version_Props_Path=${{ github.workspace }}/version.props
  -p:GeneratePackageOnBuild=true
  -p:PackageOutputPath=${{ github.workspace }}/packages
```
**Result**: Each line becomes a separate argument

### Folded Block Scalar (`>`)
Converts line breaks to spaces:
```yaml
arguments: >
  -Wall
  -Werror
  -O2
  -std=c++17
```
**Result**: Arguments are naturally space-separated

### Single Line
Simple single argument:
```yaml
arguments: '--nologo --verbosity quiet'
```
**Result**: Treated as one argument (may need manual parsing if multiple args)

## Real-World Examples

### Example 1: .NET Build with MSBuild Properties

```yaml
- name: Setup build arguments
  id: build-args
  uses: framinosona/github_actions/normalize-arguments@main
  with:
    arguments: |
      -p:Version=${{ steps.version.outputs.version }}
      -p:Configuration=Release
      -p:Platform=AnyCPU
      -p:OutputPath=${{ github.workspace }}/output
      -p:TreatWarningsAsErrors=true
    show-summary: 'true'

- name: Build solution
  run: |
    dotnet build MySolution.sln ${{ steps.build-args.outputs.normalized }}
```

### Example 2: Docker Build Arguments

```yaml
- name: Normalize Docker build args
  id: docker-args
  uses: framinosona/github_actions/normalize-arguments@main
  with:
    arguments: |
      --build-arg VERSION=${{ github.ref_name }}
      --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
      --build-arg COMMIT_SHA=${{ github.sha }}
      --tag myapp:${{ github.ref_name }}

- name: Build Docker image
  run: |
    docker build ${{ steps.docker-args.outputs.normalized }} .
```

### Example 3: Test Arguments with Custom Separator

```yaml
- name: Setup test arguments
  id: test-args
  uses: framinosona/github_actions/normalize-arguments@main
  with:
    arguments: |
      --logger:trx
      --results-directory:TestResults
      --collect:"XPlat Code Coverage"
      --blame-hang-timeout:2m
    separator: ' '

- name: Run tests
  run: |
    dotnet test ${{ steps.test-args.outputs.normalized }}
```

### Example 4: Conditional Argument Building

```yaml
- name: Base arguments
  id: base-args
  uses: framinosona/github_actions/normalize-arguments@main
  with:
    arguments: |
      --configuration Release
      --no-restore

- name: Debug arguments (conditional)
  if: github.event_name == 'pull_request'
  id: debug-args
  uses: framinosona/github_actions/normalize-arguments@main
  with:
    arguments: |
      --verbosity detailed
      --diagnostic

- name: Build with conditional args
  run: |
    ARGS="${{ steps.base-args.outputs.normalized }}"
    ${{ github.event_name == 'pull_request' && format('ARGS="$ARGS {0}"', steps.debug-args.outputs.normalized) || '' }}
    dotnet build $ARGS
```

### Example 5: Package Manager Arguments

```yaml
- name: NPM install arguments
  id: npm-args
  uses: framinosona/github_actions/normalize-arguments@main
  with:
    arguments: |
      --production
      --silent
      --no-audit
      --no-fund

- name: Install dependencies
  run: |
    npm install ${{ steps.npm-args.outputs.normalized }}
```

### Example 6: Compiler Flags for Multiple Languages

```yaml
# C++ Compilation
- name: C++ compiler flags
  id: cpp-flags
  uses: framinosona/github_actions/normalize-arguments@main
  with:
    arguments: >
      -Wall -Werror -std=c++17 -O2
      -I./include -L./lib

- name: Compile C++
  run: |
    g++ ${{ steps.cpp-flags.outputs.normalized }} src/*.cpp -o app

# Rust Compilation
- name: Rust build flags
  id: rust-flags
  uses: framinosona/github_actions/normalize-arguments@main
  with:
    arguments: |
      --release
      --target x86_64-unknown-linux-gnu
      --features production

- name: Build Rust project
  run: |
    cargo build ${{ steps.rust-flags.outputs.normalized }}
```

## Separator Options

### Space Separator (Default)
```yaml
separator: ' '
# Result: "-p:Version=1.0.0 -p:Configuration=Release"
```

### Custom Separators
```yaml
# Comma separation
separator: ', '
# Result: "-p:Version=1.0.0, -p:Configuration=Release"

# Newline separation (for complex commands)
separator: ' \
'
# Result: Multi-line command with line continuations
```

## Input Format Handling

### Empty Line Handling
Empty lines and excessive whitespace are automatically removed during normalization:
```yaml
arguments: |
  -p:Version=1.0.0

  -p:Configuration=Release

# Result: Two arguments, empty lines removed
```

### Whitespace Trimming
Leading and trailing whitespace is automatically trimmed from each line:
```yaml
arguments: |
    -p:Version=1.0.0
       -p:Configuration=Release
# Automatically trims leading/trailing whitespace from each line
```

### Mixed Format Support
```yaml
# Single line with multiple args
arguments: '--nologo --verbosity quiet'

# Multi-line literal
arguments: |
  --configuration Release
  --output ./bin

# Folded multi-line
arguments: >
  --logger trx
  --results-directory TestResults
```

## Integration Patterns

### With Environment Variables
```yaml
- name: Build arguments with env vars
  id: args
  uses: framinosona/github_actions/normalize-arguments@main
  with:
    arguments: |
      -p:Version=${{ env.VERSION }}
      -p:Configuration=${{ env.BUILD_CONFIG }}
      -p:OutputPath=${{ env.OUTPUT_DIR }}

- name: Build
  run: dotnet build ${{ steps.args.outputs.normalized }}
```

### Command Chaining
```yaml
- name: Base command args
  id: base
  uses: framinosona/github_actions/normalize-arguments@main
  with:
    arguments: |
      --configuration Release
      --no-restore

- name: Additional args
  id: extra
  uses: framinosona/github_actions/normalize-arguments@main
  with:
    arguments: |
      --verbosity detailed
      --logger console

- name: Execute with combined args
  run: |
    dotnet build \
      ${{ steps.base.outputs.normalized }} \
      ${{ steps.extra.outputs.normalized }}
```

### Conditional Arguments
```yaml
- name: Production arguments
  if: github.ref == 'refs/heads/main'
  id: prod-args
  uses: framinosona/github_actions/normalize-arguments@main
  with:
    arguments: |
      --configuration Release
      --optimize

- name: Development arguments
  if: github.ref != 'refs/heads/main'
  id: dev-args
  uses: framinosona/github_actions/normalize-arguments@main
  with:
    arguments: |
      --configuration Debug
      --verbosity detailed

- name: Build with environment-specific args
  run: |
    ARGS="${{ github.ref == 'refs/heads/main' && steps.prod-args.outputs.normalized || steps.dev-args.outputs.normalized }}"
    dotnet build $ARGS
```

## Requirements

- Bash shell (available on all GitHub Actions runners)
- No external dependencies
- Cross-platform compatible (Linux, macOS, Windows)

## Troubleshooting

### Common Issues

**Issue: Arguments not properly separated**
- Check that you're using the correct YAML multi-line format
- Verify the `separator` parameter matches your needs
- Enable `show-summary: 'true'` to see the parsing results

**Issue: Empty result when arguments expected**
- Ensure `arguments` parameter is not empty
- Verify YAML formatting is correct (proper indentation)

**Issue: Extra whitespace in arguments**
- Whitespace is automatically trimmed during normalization
- Check your YAML indentation and trailing spaces
- Consider using folded (`>`) format for space-separated args

**Issue: Special characters not handled correctly**
- Ensure proper quoting in YAML when using special characters
- Use literal (`|`) format for complex strings with special chars
- Test with simple arguments first, then add complexity

### Debug Information

Enable debug logging for detailed processing information:
```yaml
env:
  ACTIONS_STEP_DEBUG: true
```

This shows:
- Original input arguments
- Line-by-line processing
- Trimming and normalization steps
- Final output construction

### Performance Notes

- Very fast processing (< 10ms for typical argument lists)
- Memory efficient (processes line by line)
- No external dependencies or network calls
- Temporary file cleanup is automatic
