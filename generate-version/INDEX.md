# 📁 Generate Version - File Structure

This folder contains both the standalone action and reusable workflow for version generation.

## 📂 Files

| File | Purpose | Description |
|------|---------|-------------|
| **`action.yml`** | 🔧 **Standalone Action** | Core action for custom integrations |
| **`workflow.yml`** | 🚀 **Reusable Workflow** | Complete workflow with checkout + artifacts |
| **`README.md`** | 📖 **Action Documentation** | Full documentation for the standalone action |
| **`WORKFLOW.md`** | 📚 **Workflow Documentation** | Complete guide for the reusable workflow |

## 🎯 Quick Start

### Option 1: Reusable Workflow (Recommended)

```yaml
jobs:
  version:
    uses: framinosona/github_actions/generate-version/workflow.yml@main
    with:
      major: "1"
      minor: "0"
```

### Option 2: Standalone Action

```yaml
steps:
  - uses: actions/checkout@v4
    with:
      fetch-depth: 0
  - uses: framinosona/github_actions/generate-version@main
    with:
      major: "1"
      minor: "0"
```

## 🔗 Documentation Links

- 🚀 [**Reusable Workflow Guide**](./WORKFLOW.md) - For most users
- 🔧 [**Standalone Action Guide**](./README.md) - For custom integrations
