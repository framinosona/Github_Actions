# 📁 Normalize Path Action

Normalizes file paths according to the runner OS and provides both relative and absolute path formats with existence checking.

## Features

- 📁 Cross-platform path normalization using Node.js built-in `path` module
- 🔄 Automatic path separator conversion (converts `\` to `/` on Unix, `/` to `\` on Windows)
- 🎯 Provides both normalized and absolute path outputs
- ✅ Checks path existence on filesystem
- 🌟 Supports wildcard patterns (`*`, `**`, `?`) - checks parent directory existence
- 🛡️ Validates input paths and warns about potential issues
- 📊 Optional detailed summary output
- 🔧 Works with relative and absolute paths
- 🚀 Pure Node.js implementation without temporary files

## Usage

### Basic Usage

```yaml
- name: Normalize project path
  uses: laerdal/github_actions/normalize-path@main
  with:
    path: 'src/components/../utils/helper.js'
```

### Advanced Usage with Summary

```yaml
- name: Normalize and validate paths
  id: normalize
  uses: laerdal/github_actions/normalize-path@main
  with:
    path: './docs/../README.md'
    show-summary: 'true'

- name: Use normalized path
  run: |
    echo "Normalized: ${{ steps.normalize.outputs.normalized }}"
    echo "Absolute: ${{ steps.normalize.outputs.absolute }}"
    echo "Exists: ${{ steps.normalize.outputs.exists }}"
```

### Multiple Path Processing

```yaml
- name: Normalize source path
  id: src-path
  uses: laerdal/github_actions/normalize-path@main
  with:
    path: 'src/main/../lib/index.ts'

- name: Normalize output path
  id: out-path
  uses: laerdal/github_actions/normalize-path@main
  with:
    path: './dist/bundle.js'

- name: Process files
  if: steps.src-path.outputs.exists == 'true'
  run: |
    cp "${{ steps.src-path.outputs.absolute }}" "${{ steps.out-path.outputs.absolute }}"
```

### Path Validation Workflow

```yaml
- name: Validate configuration file
  id: config
  uses: laerdal/github_actions/normalize-path@main
  with:
    path: 'config/app.json'

- name: Load config if exists
  if: steps.config.outputs.exists == 'true'
  run: |
    echo "Loading config from: ${{ steps.config.outputs.normalized }}"
    cat "${{ steps.config.outputs.absolute }}"

- name: Create default config
  if: steps.config.outputs.exists == 'false'
  run: |
    mkdir -p "$(dirname "${{ steps.config.outputs.absolute }}")"
    echo '{}' > "${{ steps.config.outputs.absolute }}"
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `path` | Path to normalize (can be relative or absolute) | ✅ Yes | - |
| `show-summary` | Whether to show the action summary | ❌ No | `false` |

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `normalized` | Normalized path adjusted for the current OS | `src/utils/helper.js` |
| `absolute` | Absolute path resolved from the normalized path | `/home/user/project/src/utils/helper.js` |
| `exists` | Whether the normalized path exists on the filesystem | `true` or `false` |

## Examples

### Example 1: Clean up relative paths

```yaml
- name: Normalize complex relative path
  id: cleanup
  uses: laerdal/github_actions/normalize-path@main
  with:
    path: './src/../docs/./api/../guide.md'
# Output normalized: docs/guide.md
```

### Example 2: Convert to absolute path

```yaml
- name: Get absolute path
  id: absolute
  uses: laerdal/github_actions/normalize-path@main
  with:
    path: 'config.json'

- name: Use absolute path
  run: |
    echo "Config located at: ${{ steps.absolute.outputs.absolute }}"
```

### Example 3: Conditional file processing

```yaml
- name: Check if package.json exists
  id: package
  uses: laerdal/github_actions/normalize-path@main
  with:
    path: 'package.json'

- name: Install dependencies
  if: steps.package.outputs.exists == 'true'
  run: npm install

- name: Initialize project
  if: steps.package.outputs.exists == 'false'
  run: npm init -y
```

### Example 4: Build path construction

```yaml
- name: Normalize source directory
  id: src
  uses: laerdal/github_actions/normalize-path@main
  with:
    path: './src'

- name: Normalize build directory
  id: build
  uses: laerdal/github_actions/normalize-path@main
  with:
    path: './dist'

- name: Build project
  run: |
    echo "Building from: ${{ steps.src.outputs.absolute }}"
    echo "Building to: ${{ steps.build.outputs.absolute }}"
    mkdir -p "${{ steps.build.outputs.absolute }}"
```

### Example 5: Wildcard pattern support

```yaml
- name: Normalize wildcard path
  id: wildcard
  uses: laerdal/github_actions/normalize-path@main
  with:
    path: 'src/**/*.js'

- name: Process matched files
  if: steps.wildcard.outputs.exists == 'true'
  run: |
    # Parent directory exists, can use wildcard pattern
    echo "Processing files matching: ${{ steps.wildcard.outputs.normalized }}"
    # Use with tools that support wildcards (e.g., find, glob)
```

## Platform Behavior

The action automatically normalizes path separators to match the current platform.

### Windows
- Converts all path separators (forward slashes `/`) to backslashes (`\`)
- Handles drive letters correctly (`C:\`, `D:\`)
- Warns about reserved characters (`<>:"|?*`)
- Example: `src/utils/../lib/index.js` → `src\lib\index.js`
- Example: `src\utils\..\lib` → `src\lib`

### Linux/macOS
- Converts all path separators (backslashes `\`) to forward slashes (`/`)
- Resolves symbolic links in absolute paths
- Handles case-sensitive filesystems
- Example: `src/utils/../lib/index.js` → `src/lib/index.js`
- Example: `src\utils\..\lib` → `src/lib/index.js`

### Cross-Platform Examples

| Input Path | Windows Output | Linux/macOS Output |
|------------|----------------|-------------------|
| `./src/../docs/readme.md` | `docs\readme.md` | `docs/readme.md` |
| `src\utils\..\lib` | `src\lib` | `src/lib` |
| `/tmp/../var/log` | `\var\log` | `/var/log` |

## Requirements

- Node.js runtime (available by default in GitHub Actions runners)
- Access to the filesystem for path existence checking
- No external dependencies beyond Node.js built-ins

## Implementation Details

### Path Normalization Process
1. **Input Validation**: Checks for empty paths and potential security issues
2. **Normalization**: Uses Node.js `path.normalize()` to resolve `.` and `..` segments
3. **Resolution**: Uses `path.resolve()` to get absolute path from current working directory
4. **Existence Check**: Uses `fs.accessSync()` to verify if path exists on filesystem

### Security Considerations
- Validates input paths for safety
- Warns about parent directory traversal (`..`) patterns
- Does not follow symbolic links for security
- Only reads filesystem metadata, not file contents
- No path sanitization beyond standard Node.js normalization

## Troubleshooting

### Common Issues

**Issue: Path contains `..` segments**
```
Warning: Path contains parent directory references (..), ensure this is intentional
```
- This is normal for relative paths with parent references
- The action processes them correctly but warns for security awareness
- Use the `absolute` output if you need clean paths without `..`

**Issue: Path doesn't exist**
```
Warning: Path does not exist on filesystem
```
- Check the `exists` output to verify: `${{ steps.normalize.outputs.exists }}`
- Ensure the path is relative to the current working directory
- Use absolute paths if working directory is uncertain
- Create the path if needed before using it

**Issue: Invalid characters on Windows**
```
Warning: Path contains characters that may be invalid on Windows
```
- Windows restricts certain characters: `<>:"|?*`
- Consider sanitizing paths before normalization
- Some characters valid on Linux/macOS are invalid on Windows

**Issue: Different path separators**
- Windows uses backslashes (`\`), Unix systems use forward slashes (`/`)
- The action automatically uses correct separators for the current OS
- Always use the normalized output for file operations

### Debug Information

Enable debug logging to see detailed path processing:

```yaml
env:
  ACTIONS_STEP_DEBUG: true
```

This shows:
- Original input path
- Normalized result
- Absolute path resolution
- Existence check results
- Processing steps and timing

### Performance Notes

- Path normalization is very fast (< 1ms per path)
- Filesystem existence checks add minimal overhead (< 5ms)
- No external dependencies or network calls
- Memory usage is minimal (< 1MB)

### Integration Examples

**With file upload actions:**
```yaml
- name: Normalize artifact path
  id: artifact
  uses: laerdal/github_actions/normalize-path@main
  with:
    path: './build/artifacts'

- name: Upload artifacts
  if: steps.artifact.outputs.exists == 'true'
  uses: actions/upload-artifact@v3
  with:
    name: build-artifacts
    path: ${{ steps.artifact.outputs.absolute }}
```

**With Docker builds:**
```yaml
- name: Normalize Dockerfile path
  id: dockerfile
  uses: laerdal/github_actions/normalize-path@main
  with:
    path: './docker/Dockerfile'

- name: Build Docker image
  if: steps.dockerfile.outputs.exists == 'true'
  run: |
    docker build -f "${{ steps.dockerfile.outputs.absolute }}" .
```

**With cache actions:**
```yaml
- name: Normalize cache path
  id: cache-path
  uses: laerdal/github_actions/normalize-path@main
  with:
    path: '~/.npm'

- name: Cache dependencies
  uses: actions/cache@v3
  with:
    path: ${{ steps.cache-path.outputs.absolute }}
    key: npm-${{ hashFiles('package-lock.json') }}
```
