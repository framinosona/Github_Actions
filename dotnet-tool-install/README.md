# 🔧 Install .NET Tool Action

Installs a .NET global or local tool with automatic tool manifest creation and comprehensive error handling.

## Features

- 📦 Install global or local .NET tools
- 📝 Automatic tool manifest creation for local tools
- 🔍 Version detection and reporting
- ⚙️ Comprehensive input validation
- 🚀 Leverages the robust dotnet action for execution
- 📊 Detailed summary reporting
- 🔧 Support for custom sources, configurations, and frameworks

## Usage

### Basic Usage - Install Global Tool

```yaml
- name: Install Entity Framework Core CLI
  uses: ./dotnet-tool-install
  with:
    tool-name: 'dotnet-ef'
    global: 'true'
```

### Basic Usage - Install Local Tool

```yaml
- name: Install local development tools
  uses: ./dotnet-tool-install
  with:
    tool-name: 'dotnet-outdated-global'
    global: 'false'
```

### Advanced Usage - Specific Version with Custom Source

```yaml
- name: Install specific tool version from custom feed
  uses: ./dotnet-tool-install
  with:
    tool-name: 'my-custom-tool'
    tool-version: '1.2.3'
    global: 'false'
    prerelease: 'true'
    add-source: 'https://my-nuget-feed.com/v3/index.json'
    framework: 'net8.0'
    verbosity: 'detailed'
    working-directory: './src'
```

### Enterprise Usage - With Configuration File

```yaml
- name: Install tool with custom NuGet config
  uses: ./dotnet-tool-install
  with:
    tool-name: 'enterprise-tool'
    global: 'true'
    configfile: './nuget.config'
    tool-path: './custom-tools'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `tool-name` | Name of the .NET tool to install (e.g., 'dotnet-ef', 'dotnet-outdated') | ✅ Yes | |
| `tool-version` | Specific version of the tool to install (optional, uses latest if not specified) | ❌ No | `""` |
| `global` | Install as global tool (true) or local tool (false) | ❌ No | `"false"` |
| `prerelease` | Include prerelease versions when searching for the tool | ❌ No | `"false"` |
| `working-directory` | Working directory for the installation (only relevant for local tools) | ❌ No | `"."` |
| `tool-path` | Custom tool path for global tool installation | ❌ No | `""` |
| `add-source` | Additional NuGet source to use when installing the tool | ❌ No | `""` |
| `configfile` | NuGet configuration file to use | ❌ No | `""` |
| `framework` | Target framework for the tool | ❌ No | `""` |
| `verbosity` | Verbosity level (quiet, minimal, normal, detailed, diagnostic) | ❌ No | `""` |
| `show-summary` | Whether to show the action summary | ❌ No | `"true"` |

## Outputs

| Output | Description |
|--------|-------------|
| `exit-code` | Exit code of the tool installation command |
| `executed-command` | The actual command that was executed |
| `tool-manifest-created` | Whether a new tool manifest was created (true/false) |
| `installed-version` | The version of the tool that was installed |

## Examples

### Example 1: Install Global Entity Framework CLI

```yaml
name: Setup EF Core Tools
on: [push]

jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Install EF Core CLI
        uses: ./dotnet-tool-install
        with:
          tool-name: 'dotnet-ef'
          global: 'true'

      - name: Verify installation
        run: dotnet ef --version
```

### Example 2: Install Local Development Tools

```yaml
name: Setup Development Environment
on: [push]

jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Install local tools
        uses: ./dotnet-tool-install
        with:
          tool-name: 'dotnet-outdated-global'
          global: 'false'

      - name: Install another local tool
        uses: ./dotnet-tool-install
        with:
          tool-name: 'dotnet-format'
          global: 'false'

      - name: Run tools
        run: |
          dotnet tool list
          dotnet outdated
```

### Example 3: Install from Custom Feed with Specific Version

```yaml
name: Install Enterprise Tools
on: [push]

jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Install enterprise tool
        uses: ./dotnet-tool-install
        with:
          tool-name: 'my-enterprise-tool'
          tool-version: '2.1.0-preview.1'
          global: 'true'
          prerelease: 'true'
          add-source: 'https://enterprise-feed.company.com/v3/index.json'
          verbosity: 'detailed'
        env:
          NUGET_AUTH_TOKEN: ${{ secrets.ENTERPRISE_FEED_TOKEN }}
```

### Example 4: Matrix Installation for Multiple Tools

```yaml
name: Install Multiple Tools
on: [push]

jobs:
  install-tools:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        tool:
          - { name: 'dotnet-ef', global: 'true' }
          - { name: 'dotnet-outdated-global', global: 'false' }
          - { name: 'dotnet-format', global: 'false' }
          - { name: 'dotnet-reportgenerator-globaltool', global: 'true' }

    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Install ${{ matrix.tool.name }}
        uses: ./dotnet-tool-install
        with:
          tool-name: ${{ matrix.tool.name }}
          global: ${{ matrix.tool.global }}
```

## Requirements

- ✅ .NET SDK must be installed (use `actions/setup-dotnet`)
- ✅ Valid .NET tool name
- ✅ Network access to NuGet feeds
- ✅ Write permissions for tool installation locations

## Tool Manifest Behavior

### Local Tools

- 📝 **Automatic Creation**: If installing a local tool and no `.config/dotnet-tools.json` exists, one will be created automatically
- 📍 **Location**: Tool manifest is created in the working directory under `.config/dotnet-tools.json`
- 🔍 **Detection**: The action reports whether a new manifest was created via the `tool-manifest-created` output

### Global Tools

- 🌍 **No Manifest**: Global tools don't require or use tool manifests
- 📦 **System-wide**: Installed to the user's global tool location
- 🛤️ **Custom Path**: Use `tool-path` input to specify a custom installation directory

## Error Handling

The action includes comprehensive error handling:

- 🔍 **Input Validation**: All inputs are validated before execution
- 📁 **Path Verification**: Working directories and config files are checked for existence
- ⚙️ **Command Validation**: Ensures dotnet tool commands are properly formed
- 🚨 **Installation Failures**: Clear error messages for failed installations
- 📊 **Summary on Failure**: Action summary is shown even when installation fails

## Integration with dotnet Action

This action leverages the powerful `dotnet` action for command execution, providing:

- 🔧 **Smart Verbosity**: Automatic verbosity handling based on debug settings
- ⚡ **Optimized Execution**: Efficient command building and execution
- 📋 **Detailed Logging**: Comprehensive command logging and output
- 🚀 **Consistent Interface**: Same reliable execution engine across all dotnet actions

## Troubleshooting

### Common Issues

1. **Tool Already Installed**

   ```
   Tool 'dotnet-ef' is already installed.
   ```

   - This is normal and not an error
   - The action will still complete successfully
   - Use `dotnet tool update` if you need to update the version

2. **Permission Denied**

   ```
   Access to the path '/usr/local/share/dotnet/tools' is denied.
   ```

   - Common with global tool installation on Linux/macOS
   - Use `sudo` in a separate step or install as local tool instead

3. **Tool Not Found**

   ```
   No executable found matching command "dotnet-mytool"
   ```

   - Verify the tool name is correct
   - Check if the tool supports your target framework
   - Ensure the tool source is accessible

4. **NuGet Authentication**

   ```
   Unable to load the service index for source
   ```

   - Configure authentication for private feeds
   - Use environment variables or `configfile` input

### Debug Mode

Enable detailed logging by setting verbosity:

```yaml
- name: Install tool with debug output
  uses: ./dotnet-tool-install
  with:
    tool-name: 'my-tool'
    verbosity: 'detailed'
```

Or enable GitHub Actions debug logging:

```yaml
env:
  ACTIONS_STEP_DEBUG: true
```

## Version Compatibility

| .NET Version | Supported |
|--------------|-----------|
| .NET 8.0 | ✅ Full Support |
| .NET 7.0 | ✅ Full Support |
| .NET 6.0 | ✅ Full Support |
| .NET 5.0 | ✅ Full Support |
| .NET Core 3.1 | ✅ Full Support |

## Security Considerations

- 🔒 **Source Validation**: Only install tools from trusted sources
- 🔑 **Authentication**: Use secure authentication for private feeds
- 📝 **Manifest Control**: Review tool manifests in source control
- 🚫 **Prerelease Caution**: Use prerelease versions carefully in production

## Contributing

When contributing to this action, please ensure:

- ✅ Follow the Actions structure principles
- 🧪 Test with both global and local tool scenarios
- 📝 Update documentation for new features
- 🔍 Validate all inputs thoroughly
- 📊 Maintain comprehensive summary reporting
