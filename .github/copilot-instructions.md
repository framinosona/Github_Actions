# GitHub Actions - Actions Copilot Instructions

## 🎯 Action Structure Principles

When creating or modifying GitHub Actions in this repository, follow these core principles:

### 📋 Required Structure
All actions must follow this exact structure:

1. **ℹ️ Environment information** - (When relevant) Gather useful environment details (OS, versions, tools ...)
2. **🔒 Sensitive Data Masking** - (When relevant) Mask sensitive data
3. **📁 Normalize File Paths and arguments** - (When relevant) Use normalized file paths (e.g., absolute paths) to avoid issues with relative paths, and normalize multi-line inputs
4. **✅ Parameter Validation Step** - Validate all inputs, except if the input is sent directly to an underlying tool that will handle validation itself.
5. **🏗️ Argument Building Step** - (When relevant) Build command-line arguments based on inputs. Input aggregation should happen here.
6. **🚀 Main Action Steps** - One or more functional steps that perform the work
7. **🔍 Check/Verify results** - (When relevant) Implement checks to verify the results of the action
8. **📊 Action Summary Step** - Always last, provides detailed summary output

### 📝 Action Metadata Standards

#### Basic Structure
```yaml
name: '🎯 Action Name'
description: 'Clear, concise description of what the action does'
author: 'Francois Raminosona' # or appropriate author name

inputs:
  # Always include clear descriptions, required flags, and sensible defaults
  parameter-name:
    description: 'Clear description of what this parameter does'
    required: true|false
    default: 'sensible-default-value'
  show-summary:
    description: 'Whether to show the action summary'
    required: false
    default: 'false'

outputs:
  # Provide meaningful outputs that other actions can use
  output-name:
    description: 'Clear description of what this output contains'
    value: ${{ steps.step-id.outputs.output-name }}

runs:
  using: "composite"
  steps:
    # Follow the patterns outlined in the Step Patterns section below

branding:
  icon: 'appropriate-feather-icon'
  color: 'blue'  # Consistent branding color
```

## 🔧 Step Patterns

### ℹ️ Environment Information Step

At the begining of the steps in this section, include the following:
```yaml
# ================== ℹ️ ==================
```

```yaml
- name: "ℹ️ Gather environment information"
  shell: bash
  run: |
    echo "::group::ℹ️ Environment Information"
    echo "::debug::Operating System: $(uname -a)"
    echo "::debug::GitHub Runner OS: $RUNNER_OS"
    echo "::debug::GitHub Runner Version: $RUNNER_VERSION"
    echo "::debug::.NET SDK Version: $(dotnet --version || echo 'Not installed')"
    echo "::endgroup::"
```

### 🔒 Sensitive Data Masking Step

At the begining of the steps in this section, include the following:
```yaml
# ================== 🔒 ==================
```

```yaml
- name: "🔒 Mask sensitive data"
  shell: bash
  run: |
    if [ -n "${{ inputs.api-key }}" ]; then
      echo "::add-mask::${{ inputs.api-key }}"
    fi
    if [ -n "${{ inputs.symbol-api-key }}" ]; then
      echo "::add-mask::${{ inputs.symbol-api-key }}"
    fi

    echo "✅ Masked sensitive inputs"
```

Can also be empty :
```yaml
- name: "🔒 Mask sensitive data"
  shell: bash
  run: |
    # No sensitive inputs to mask in this action
    echo "✅ No sensitive data to mask"
```

### 📁 Normalize File Paths Step

At the begining of the steps in this section, include the following:
```yaml
# ================== 📁 ==================
```

```yaml
- name: "💯 Normalize arguments"
  id: normalize-arguments
  uses: framinosona/github_actions/normalize-path@main
  with:
    path: ${{ inputs.arguments }}

- name: "📁 Normalize output"
  id: normalize-output
  uses: framinosona/github_actions/normalize-path@main
  with:
    path: ${{ inputs.output }}
```

This means that for any input that is a file path or multi-line argument, you should include a normalization step like above.

In the next steps, always refer to the normalized paths/arguments using `${{ steps.normalize-arguments.outputs.normalized }}` or `${{ steps.normalize-output.outputs.normalized }}`.

### ✅ Validation Step

At the begining of the steps in this section, include the following:
```yaml
# ================== ✅ ==================
```

Validation should be skipped for inputs that are sent directly, as-is, to an underlying tool belonging to framinosona/github_actions (e.g., dotnet, nuget, etc.), as those tools will handle validation themselves.

Can be 1 big validation step or multiple smaller steps.
Boolean validations is often bundled into a single step would be :

```yaml
- name: "✅ Validate input : booleans"
  shell: bash
  run: |
    echo "::debug::Validating boolean inputs..."
    for param in nologo no-restore no-build; do
      case $param in
        nologo) value="${{ inputs.nologo }}" ;;
        no-restore) value="${{ inputs.no-restore }}" ;;
        no-build) value="${{ inputs.no-build }}" ;;
      esac
      if [ -n "$value" ] && [ "$value" != "true" ] && [ "$value" != "false" ]; then
        echo "::error::Parameter $param must be 'true' or 'false', got: $value"
        exit 1
      fi
    done

    echo "✅ Boolean inputs validation completed successfully"
```

When value can be anything, but can't be null or empty:

```yaml
- name: "✅ Validate input : required parameters"
  shell: bash
  run: |
    echo "::debug::Validating required inputs..."
    for param in command; do
      value="${{ inputs.$param }}"
      if [ -z "$value" ]; then
        echo "::error::Parameter $param is required but was not provided."
        exit 1
      fi
    done
```

Can also just be empty if no validation is needed :
```yaml
- name: "✅ Validate inputs"
  shell: bash
  run: |
    echo "::debug::No input validation needed"
    echo "✅ Input validation completed successfully"
```

### 🏗️ Build argument list

At the begining of the steps in this section, include the following:
```yaml
# ================== 🏗️ ==================
```

Some actions are simple enough to not need an argument building step.
When needed, this step should aggregate inputs into a single argument string. This is used to prepare the command line for the main action step. Refer to the documentation of the command-line tool being wrapped for specific argument formats (often provided at the end of the file).

```yaml
- name: "🏗️ Build argument list"
  id: build-args
  shell: bash
  run: |
    echo "::debug::Building argument list..."
    ARGUMENTS=""

    # Boolean flags
    for param in nologo no-restore no-build; do
      case $param in
        nologo) value="${{ inputs.nologo }}" ;;
        no-restore) value="${{ inputs.no-restore }}" ;;
        no-build) value="${{ inputs.no-build }}" ;;
      esac
      if [ "$value" = "true" ]; then
        ARGUMENTS="$ARGUMENTS --${param}"
      fi
    done

    # Key-value options
    for param in verbosity configuration framework runtime output arch artifacts-path; do
      case $param in
        verbosity) value="${{ steps.validate-verbosity.outputs.verbosity }}" ;;
        configuration) value="${{ inputs.configuration }}" ;;
        framework) value="${{ inputs.framework }}" ;;
        runtime) value="${{ inputs.runtime }}" ;;
        output) value="${{ steps.normalize-output.outputs.normalized }}" ;;
        arch) value="${{ inputs.arch }}" ;;
        artifacts-path) value="${{ steps.normalize-artifacts-path.outputs.normalized }}" ;;
      esac
      if [ -n "$value" ]; then
        ARGUMENTS="$ARGUMENTS --$param '$value'"
      fi
    done

    # Trim leading space
    ARGUMENTS="${ARGUMENTS# }"

    # Add more arguments based on other inputs as needed

    echo "✅ Argument list built successfully"
    echo "arguments=$ARGUMENTS" >> $GITHUB_OUTPUT
```

### 🚀 Main Action Steps

At the begining of the steps in this section, include the following:
```yaml
# ================== 🚀 ==================
```

These steps will vary widely depending on the action's purpose. Always ensure proper error handling and logging using GitHub workflow commands.

### 🔍 Output Validation

At the begining of the steps in this section, include the following:
```yaml
# ================== 🔍 ==================
```

```yaml
- name: "🔍 Validate output file"
  shell: bash
  run: |
    echo "::debug::Validating output file..."
    if [ ! -f "${{ steps.build-args.outputs.output-file }}" ]; then
      echo "::error::Output file not found: ${{ steps.build-args.outputs.output-file }}"
      exit 1
    fi
    echo "output-file=${{ steps.build-args.outputs.output-file }}" >> $GITHUB_OUTPUT
    echo "::notice::Output file validation completed successfully"
```

### 📊 Summary Step (Always Last)

At the begining of the steps in this section, include the following:
```yaml
# ================== 📊 ==================
```

```yaml
- name: "📊 Action Summary"
  if: always() && inputs.show-summary == 'true'
  shell: bash
  run: |
    cat >> $GITHUB_STEP_SUMMARY << 'EOF'
    <details><summary>Expand for details - 📊 [Action Name] Summary</summary>

    ## 🔧 Input Parameters
    | Parameter | Value |
    |-----------|-------|
    | 📝 Parameter Name | `${{ inputs.parameter-name }}` |

    ## 📤 Action Results
    | Metric | Value |
    |--------|-------|
    | 🎯 Output Name | `${{ steps.step-id.outputs.output-name }}` |
    | ✅ Status | `${{ steps.step-id.outcome }}` |

    ## ⚙️ Process Details
    | Step | Status |
    |------|--------|
    | ✅ Input Validation | `✅ Completed` |
    | 🔧 Main Process | `${{ steps.step-id.outcome == 'success' && '✅ Completed' || '❌ Failed' }}` |

    </details>
    EOF
```

## 🎨 Style Guidelines

### 🔤 Naming Conventions
- **Action names**: Use emoji + descriptive name (e.g., "🔢 Calculate Project Version")
- **Step names**: Use emoji + clear action description (e.g., "🔍 Validate inputs")
- **Parameter names**: Use kebab-case (e.g., `file-path`, `output-directory`)
- **Output names**: Use kebab-case (e.g., `exit-code`, `file-path`)

### 📝 Documentation Standards
- **Descriptions**: Always clear, concise, and helpful
- **Examples**: Provide both basic and advanced usage examples
- **Default values**: Use sensible defaults that work in most scenarios
- **Required flags**: Only mark as required if absolutely necessary

### 🎯 Error Handling
- **Validation**: Always validate inputs upfront
- **Error messages**: Clear, actionable error messages with ❌ emoji
- **Success messages**: Positive confirmation with ✅ emoji
- **Exit codes**: Use proper exit codes (0 for success, 1 for failure)

### 📝 GitHub Workflow Commands
**IMPORTANT**: Always use GitHub's native workflow commands for logging instead of plain echo statements. This provides better integration with GitHub's UI and enhanced functionality.

#### Required Workflow Commands Usage
```bash
echo "::error::Invalid parameter value"
echo "::warning::Unusual configuration"
echo "::notice::Validation completed successfully"
echo "::debug::Processing file"
```

#### Workflow Commands Reference
- **`::error::`** - Creates error annotations visible in GitHub UI
  - Use for validation failures, missing files, invalid configurations
  - Example: `echo "::error file=config.json::Configuration file not found"`

- **`::warning::`** - Creates warning annotations
  - Use for non-fatal issues, deprecated features, unusual values
  - Example: `echo "::warning::Using deprecated parameter format"`

- **`::notice::`** - Highlights important information
  - Use for successful completion, important status updates
  - Example: `echo "::notice::Package uploaded successfully"`

- **`::debug::`** - Debug information (only visible when ACTIONS_STEP_DEBUG=true)
  - Use for detailed execution information, variable values
  - Example: `echo "::debug::Using configuration: $CONFIG_VALUE"`

#### Log Organization with Groups
Always organize complex operations into collapsible groups:
```bash
echo "::group::🔍 Input Validation"
# validation steps...
echo "::notice::Input validation completed successfully"
echo "::endgroup::"

echo "::group::🔧 Building Arguments"
# argument building steps...
echo "::debug::Generated arguments: $ARGS"
echo "::endgroup::"
```

#### Sensitive Data Masking
**CRITICAL**: Always mask sensitive data before any logging:
```bash
# Mask ALL sensitive inputs immediately
if [ -n "${{ inputs.api-key }}" ]; then
  echo "::add-mask::${{ inputs.api-key }}"
fi
if [ -n "${{ inputs.password }}" ]; then
  echo "::add-mask::${{ inputs.password }}"
fi
if [ -n "${{ inputs.certificate-data }}" ]; then
  echo "::add-mask::${{ inputs.certificate-data }}"
fi
```

### 🔧 Tool Management
- **Reuse existing actions**: Use `framinosona/github_actions/dotnet-tool-install@main` for .NET tools, `framinosona/github_actions/dotnet@main` for .NET CLI commands, `framinosona/github_actions/normalize-arguments@main` for argument normalization, etc.
- **Tool installation**: Check if tool exists before installing
- **Cross-platform**: Ensure compatibility with Windows, Linux, and macOS, use `framinosona/github_actions/normalize-path@main` for path normalization

## 📊 Output Standards

### Required Outputs
All actions should provide these standard outputs where applicable:
- **Status indicators**: `success`, `failed`, `completed`
- **File paths**: Absolute paths to generated files
- **Metrics**: Counts, sizes where relevant
- **Configuration**: Key configuration values used

### Summary Requirements
- **Always use `if: always()`** to ensure summary runs even on failure
- **Use collapsible details** with descriptive summary text
- **Include emoji** for visual clarity and consistency
- **Provide tables** for structured information
- **Show both inputs and outputs** for transparency

## 📚 Documentation Template

Each action must include a comprehensive README.md with:

```markdown
# 🎯 Action Name Action

Brief description of what the action does.

## Features

- 📋 Key feature 1
- ⚙️ Key feature 2
- 🔧 Key feature 3

## Usage

### Basic Usage
[Simple example]

### Advanced Usage
[Complex example with all options]

## Inputs
[Detailed input table]

## Outputs
[Detailed output table]

## Examples
[Multiple real-world examples]

## Requirements
[Prerequisites and dependencies]

## Troubleshooting
[Common issues and solutions]
```

## 🔄 Action Dependencies

### Tool Installation Pattern
```yaml
- name: "📦 Install [Tool Name]"
  uses: ./dotnet-tool-install
  with:
    tool-name: 'tool-name'
    tool-version: '1.0.0'  # Optional, uses latest if not specified
    prerelease: 'false'     # Optional, default false
```

### Cross-Platform Compatibility
- Always use `bash` shell for cross-platform compatibility
- Handle path differences appropriately
- Test on multiple platforms (Windows, Linux, macOS)
- Use appropriate file path separators

This structure ensures all actions are consistent, reliable, and maintainable while following enterprise-grade best practices.
