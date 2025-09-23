# GitHub Actions - Actions Copilot Instructions

## 🎯 Action Structure Principles

When creating or modifying GitHub Actions in this repository, follow these core principles:

### 📋 Required Structure
All actions must follow this exact structure:

1. **🔍 Parameter Validation Step** - Always first, validates all inputs
2. **⚙️ Main Action Steps** - One or more functional steps that perform the work
3. **📊 Action Summary Step** - Always last, provides detailed summary output

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
    # Follow the three-step pattern below

branding:
  icon: 'appropriate-feather-icon'
  color: 'blue'  # Consistent branding color
```

## 🔧 Step Patterns

### 1. ✅ Validation Step (Always First)
```yaml
- name: "✅ Validate inputs"
  shell: bash
  run: |
    echo "🔍 Validating inputs..."

    # Validate required parameters
    if [ -z "${{ inputs.required-param }}" ]; then
      echo "❌ Error: Required parameter cannot be empty"
      exit 1
    fi

    # Validate file/directory paths if applicable
    if [ -n "${{ inputs.file-path }}" ] && [ ! -f "${{ inputs.file-path }}" ]; then
      echo "❌ Error: File not found: ${{ inputs.file-path }}"
      exit 1
    fi

    # Validate enum values if applicable
    if [ -n "${{ inputs.enum-param }}" ]; then
      case "${{ inputs.enum-param }}" in
        value1|value2|value3) ;;
        *) echo "❌ Error: Invalid value. Must be one of: value1, value2, value3"; exit 1 ;;
      esac
    fi

    echo "✅ Input validation passed"
```

### 2. ⚙️ Main Action Steps
```yaml
- name: "🔧 Main action step"
  id: step-id
  shell: bash
  run: |
    echo "🚀 Starting main action..."

    # Tool installation if needed (use existing tool actions)
    # Main functionality implementation
    # Set outputs for downstream use

    if [success_condition]; then
      echo "✅ Action completed successfully"
      echo "output-name=value" >> $GITHUB_OUTPUT
    else
      echo "❌ Action failed"
      exit 1
    fi
```

### 3. 📊 Summary Step (Always Last)
```yaml
- name: "📊 Action Summary"
  if: ${{ inputs.show-summary == 'true' }}
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

### 🔧 Tool Management
- **Reuse existing actions**: Use `../dotnet-tool-install` for .NET tools
- **Tool installation**: Check if tool exists before installing
- **Cross-platform**: Ensure compatibility with Windows, Linux, and macOS

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

## 🚀 Best Practices

### 🔍 Input Validation
- Validate **all** inputs, even optional ones
- Check file/directory existence before processing
- Validate enum values against allowed options
- Provide helpful error messages with context

### ⚙️ Process Management
- Use descriptive echo statements for progress tracking
- Set outputs immediately when values are determined
- Use conditional logic to handle different scenarios
- Implement proper cleanup when needed

### 🛡️ Security Considerations
- Never log sensitive information (tokens, passwords)
- Use secure file permissions when handling keys/certificates
- Validate file contents when processing untrusted input
- Clean up temporary files containing sensitive data

### 🧪 Testing Considerations
- Design for testability with clear inputs/outputs
- Provide meaningful error messages for debugging
- Include troubleshooting sections in documentation

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
  uses: ../dotnet-tool-install
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

## 🎯 Quality Checklist

Before submitting any action, verify:

- [ ] ✅ Validation step is first and comprehensive
- [ ] 📊 Summary step is last with `if: always()`
- [ ] 🎨 Consistent emoji usage throughout
- [ ] 📝 Clear, helpful descriptions for all inputs/outputs
- [ ] 🔧 Proper error handling with meaningful messages
- [ ] 📋 Comprehensive README.md documentation
- [ ] 🧪 Examples provided for basic and advanced usage
- [ ] 🛡️ Security considerations addressed
- [ ] 🔄 Consistent with existing action patterns
- [ ] 🎯 Branding section with appropriate icon and blue color

This structure ensures all actions are consistent, reliable, and maintainable while following enterprise-grade best practices.
